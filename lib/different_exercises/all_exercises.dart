import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../homepage/mainlandingpage.dart';
import 'dart:math';
import 'list_all_exercises.dart';



class AllExercises extends StatefulWidget {
  @override
  _AllExercisesState createState() => _AllExercisesState();
}

class _AllExercisesState extends State<AllExercises> {


  Stream<QuerySnapshot> _exercisesStream = const Stream.empty();
  bool isLoading = true;
  User? _currentUser;
  Map<String, double> finalBurnCalMap = {};
  int _currentDay = 1;
  int? userAge;
  List<String> _userInjuries = [];

  int _getDailySeed() {
    final now = DateTime.now();
    final daysSinceEpoch = now.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);
    return _currentUser!.email.hashCode + daysSinceEpoch;
  }

  Map<String, List<Map<String, dynamic>>> groupExercisesByBodyPart(List<Map<String, dynamic>> exercises) {
    Map<String, List<Map<String, dynamic>>> groupedExercises = {};
    for (var exercise in exercises) {
      String bodyPart = exercise['bodyPart'] ?? 'Unknown';
      if (!groupedExercises.containsKey(bodyPart)) {
        groupedExercises[bodyPart] = [];
      }
      groupedExercises[bodyPart]!.add(exercise);
    }
    return groupedExercises;
  }

  String getRepsTimeDisplay(Map<String, dynamic> exercise) {
    if (exercise['baseSetsReps'] != null && exercise['baseReps'] != null) {
      return "${exercise['baseSetsReps']} sets × ${exercise['baseReps']} reps";
    } else if (exercise['baseSetsSecs'] != null && exercise['baseSecs'] != null) {
      return _formatTimeDisplay(exercise['baseSetsSecs'], exercise['baseSecs']);
    } else if (exercise['baseSecs'] != null) {
      return _formatSingleDuration(exercise['baseSecs']);
    }
    return 'N/A';
  }

  String _formatTimeDisplay(int sets, int totalSecs) {
    return "$sets sets × ${_secondsToTimeString(totalSecs)}";
  }

  String _formatSingleDuration(int totalSecs) => _secondsToTimeString(totalSecs);

  String _secondsToTimeString(int totalSecs) {
    if (totalSecs >= 60) {
      int minutes = totalSecs ~/ 60;
      int seconds = totalSecs % 60;
      return "$minutes min${seconds > 0 ? " $seconds sec" : ""}";
    }
    return "$totalSecs sec";
  }



  Future<void> fetchUserData() async {
    if (_currentUser == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentUser!.email)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        final updatedUserAge = userData['age'];
        final injuryArea = userData['injuryArea'] ?? '';

        List<String> updatedInjuries = injuryArea.split(', ').where((s) => s.isNotEmpty).toList();
        if (updatedInjuries.contains('none of them')) updatedInjuries.clear();

        // Batch update state once
        setState(() {
          userAge = updatedUserAge;
          _userInjuries = updatedInjuries;
        });

         _initializeExercisesStream();
        await fetchFinalBurnCalValues();
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }


  void _initializeExercisesStream() {
    _exercisesStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.email)
        .collection('AllExercises')
        .where('isActive', isEqualTo: true)
        .snapshots();
  }



  Future<void> fetchFinalBurnCalValues() async {
    if (_currentUser == null) return;
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentUser!.email)
          .collection('AllExercises')
          .get();

      setState(() {
        finalBurnCalMap = {
          for (var doc in snapshot.docs)
            if ((doc.data() as Map<String, dynamic>).containsKey('FinalTotalBurnCalRep'))
              doc.id: (doc['FinalTotalBurnCalRep'] as num).toDouble()
        };
      });
    } catch (e) {
      print('Error fetching FinalTotalBurnCalRep values: $e');
    }
  }

  Future<void> fetchExercisesFromFirestore({bool isTest = false}) async {
    if (_currentUser == null) return;

    try {
      print("Fetching exercises from BodyweightExercises...");
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('BodyweightExercises')
          .get();

      print("Found ${snapshot.docs.length} exercises in BodyweightExercises");

      final userExercisesRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentUser!.email)
          .collection('AllExercises');

      int mergedCount = 0;
      for (var doc in snapshot.docs) {
        final firestoreExercise = doc.data() as Map<String, dynamic>;
        final exerciseName = firestoreExercise['name']?.toString() ?? '';
        final exerciseId = doc.id; // Get the Firestore document ID

        print("Processing exercise: $exerciseName (ID: $exerciseId)");

        var localData = _getLocalExerciseData(exerciseName);

        if (localData == null) {
          print("⚠️ No local data found for: $exerciseName");
          continue;
        }

        final mergedData = Map<String, dynamic>.from(firestoreExercise)
          ..addAll({
            'firestoreId': exerciseId,
            'baseSetsReps': localData['baseSetsReps'],
            'baseReps': localData['baseReps'],
            'baseSetsSecs': localData['baseSetsSecs'],
            'baseSecs': localData['baseSecs'],
            'burnCalperRep': localData['burnCalperRep'],
            'burnCalperSec': localData['burnCalperSec'],
            'baseCalories': localData['baseCalories'],
            'gifPath': localData['gifPath'], // Add this line
            'completed': false,
            'restTime': 30,
            'isActive': true,
          });

        // Use Firestore's original document ID as the key
        await userExercisesRef
            .doc(exerciseId)
            .set(mergedData, SetOptions(merge: true));

        mergedCount++;
        print("✅ Merged exercise: $exerciseName");
      }

      print("Successfully merged $mergedCount/${snapshot.docs.length} exercises into AllExercises");
    } catch (e) {
      print('🚨 Error generating new exercises: $e');
    }
  }

  Map<String, dynamic>? _getLocalExerciseData(String name) {
    for (var bodyPart in allExercises.keys) {
      for (var exercise in allExercises[bodyPart]!) {
        if (exercise['name'] == name) return exercise;
      }
    }
    return null;
  }


  String determineAgeGroup(int age) {
    if (age >= 4 && age <= 12) return "children";
    if (age >= 13 && age <= 17) return "teens";
    if (age >= 18 && age <= 59) return "adults";
    if (age >= 60) return "seniors";
    return "unknown";
  }

  String _getLocalGifPath(String exerciseName) {
    for (var bodyPart in allExercises.keys) {
      for (var exercise in allExercises[bodyPart]!) {
        if (exercise['name'] == exerciseName) {
          return exercise['gifPath'];
        }
      }
    }
    return 'assets/exercaiGif/fallback.gif'; // Add a fallback image
  }

  Future<void> updateCaloriesBurned(String exerciseName, double caloriesBurned, bool isRepBased) async {
    if (_currentUser == null) return;

    final userExerciseRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.email)
        .collection('AllExercises')
        .doc(exerciseName);

    if (isRepBased) {
      await userExerciseRef.update({
        'FinalTotalBurnCalRep': FieldValue.increment(caloriesBurned),
      });
    } else {
      await userExerciseRef.update({
        'TotalCalBurnSec': FieldValue.increment(caloriesBurned),
      });
    }
  }

  //local notification for exercise complete
  Future<bool> areAllExercisesCompleted() async {
    if (_currentUser == null) return true;

    List<String> targetBodyParts = [
      'back', 'chest', 'cardio', 'lower arms', 'lower legs', 'neck',
      'shoulders', 'upper arms', 'upper legs', 'waist'
    ];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.email)
        .collection('AllExercises')
        .where('bodyPart', whereIn: targetBodyParts)
        .get();

    // Check if all exercises in the target body parts are marked as completed
    return snapshot.docs.every((doc) => doc['completed'] == true);
  }

  final Map<String, Map<String, List<String>>> allowedExercises = {
    'children': {
      'back': ["seated lower back stretch", "standing lateral stretch", "kneeling lat stretch", "side lying floor stretch", "spine stretch", "standing pelvic tilt", "upper back stretch"],
      'cardio': ["high knee against wall", "push to run"],
      'chest': ["push-up (wall)", "dynamic chest stretch (male)"],
      'lower arms': ["side wrist pull stretch", "wrist circles"],
      'lower legs': ["ankle circles", "calf stretch with hands against wall", "standing calves"],
      'neck': ["side push neck stretch", "neck side stretch"],
      'shoulders': ["rear deltoid stretch"],
      'upper legs': ["hug keens to chest", "butterfly yoga pose", "hamstring stretch", "seated glute stretch", "seated wide angle pose sequence"],
    },
    'teens': {
      'back': ["lower back curl", "one arm against wall", "sphinx", "upward facing dog"],
      'cardio': ["mountain climber", "skater hops", "astride jumps (male)", "star jump (male)"],
      'chest': ["incline push-up", "kneeling push-up (male)", "wide hand push-up", "push-up"],
      'lower arms': ["modified push up to lower arms"],
      'lower legs': ["bodyweight standing calf raise", "one leg floor calf raise", "standing calf raise (on a staircase)"],
      'shoulders': ["left hook. boxing"],
      'upper arms': ["triceps stretch", "overhead triceps stretch", "triceps dips floor", "bodyweight side lying biceps curl", "biceps leg concentration curl"],
      'upper legs': ["jump squat", "forward jump", "backward jump", "runners stretch", "squat to overhead reach", "quick feet v. 2", "bodyweight drop jump squat", "lunge with jump"],
    },
    'seniors': {
      'back': ["seated lower back stretch", "standing lateral stretch", "kneeling lat stretch", "side lying floor stretch", "spine stretch", "standing pelvic tilt", "upper back stretch"],
      'cardio': ["high knee against wall", "push to run"],
      'chest': ["push-up (wall)", "isometric chest squeeze"],
      'lower arms': ["side wrist pull stretch", "wrist circles"],
      'lower legs': ["ankle circles", "calf stretch with hands against wall", "standing calves"],
      'neck': ["side push neck stretch", "neck side stretch"],
      'shoulders': ["rear deltoid stretch"],
      'upper arms': ["overhead triceps stretch", "triceps stretch"],
      'upper legs': ["seated glute stretch", "seated wide angle pose sequence", "hamstring stretch", "butterfly yoga pose", "hug keens to chest"],
    }
  };

  /*Future<String> _fetchExerciseGifUrl(String exerciseId) async {
    try {
      DocumentSnapshot exerciseDoc = await FirebaseFirestore.instance
          .collection('BodyweightExercises')
          .doc(exerciseId)
          .get();

      if (exerciseDoc.exists) {
        final data = exerciseDoc.data() as Map<String, dynamic>?;
        return data?['gifUrl'] ?? ''; // Return the latest gifUrl
      }
    } catch (e) {
      print("Error fetching gifUrl: $e");
    }
    return ''; // Return empty string if there's an error
  }*/

  // ... Keep the allowedExercises mapping and other existing code ...
  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _initializeData(); // Call the async helper function
  }

  Future<void> _initializeData() async {
    await fetchUserData();  // Ensure user data is loaded first
    await fetchExercisesFromFirestore();  // Then fetch exercises
    _initializeExercisesStream(); // ✅ Fix 2: Ensures stream is assigned
    if (mounted) setState(() => isLoading = false);  // Update UI only if widget is still active
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.backgroundgrey,
        appBar: AppBar(
          backgroundColor: AppColor.backgroundgrey,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainLandingPage()),
            ),
          ),
          title: Text("Exercises You Can Do",
              style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        body: isLoading
            ? Center(child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Downloading Files For You Exercise\nPlease wait a moment...',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold,fontSize: 18),textAlign: TextAlign.center,),
                SizedBox(height: 15,),
                CircularProgressIndicator(),
              ],
            ))
            : _currentUser == null
            ? Center(child: Text("Please log in"))
            : StreamBuilder<QuerySnapshot>(
          stream: _exercisesStream,
          builder: (context, exercisesSnapshot) {
            if (exercisesSnapshot.hasError) {
              return Center(child: Text('Error: ${exercisesSnapshot.error}'));
            }

            if (exercisesSnapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            return StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(_currentUser!.email)
                  .collection('AllExercises')
                  .snapshots(),
              builder: (context, timesSnapshot) {
                if (timesSnapshot.hasError) {
                  return Center(child: Text('Error: ${timesSnapshot.error}'));
                }

                if (timesSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                final exerciseTimes = {
                  for (var doc in timesSnapshot.data!.docs)
                    if (doc.data() != null && (doc.data() as Map<String, dynamic>).containsKey('exerciseId'))
                      (doc['exerciseId'] ?? '').toString(): doc['totalExerciseTime'] ?? 0
                };

                final exercises = exercisesSnapshot.data!.docs.map((doc) {
                  final exercise = doc.data() as Map<String, dynamic>;
                  final totalTime = exerciseTimes[exercise['id'].toString()] ?? 0;

                  if (exercise['baseSetsSecs'] != null) {
                    exercise['TotalCalBurnSec'] = totalTime * (exercise['burnCalperSec']?.toDouble() ?? 0.0);

                    FirebaseFirestore.instance
                        .collection('Users')
                        .doc(_currentUser!.email)
                        .collection('AllExercises')
                        .doc(doc.id)
                        .update({'TotalCalBurnSec': exercise['TotalCalBurnSec']});
                  }

                  return exercise;
                }).toList();

                return exercises.isEmpty
                    ? Center(child: Text("Tap Reload Button if there's no Exercise Showing",
                    style: TextStyle(color: Colors.white)))
                    : ListView(
                  children: groupExercisesByBodyPart(exercises).entries.map((entry) {
                    String bodyPart = entry.key;
                    List<Map<String, dynamic>> exercisesList = entry.value;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          child: Text(
                            bodyPart.toUpperCase(),
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        Column(
                          children: exercisesList.map((exercise) {
                            final isCompleted = exercise['completed'] == true;
                            final exerciseId = exercise['id'].toString();
                            final exerciseName = exercise['name'].toString();
                            final totalTime = exerciseTimes[exerciseId] ?? 0;

                            bool isRepBased = exercise['baseSetsReps'] != null &&
                                exercise['baseReps'] != null;
                            bool isTimeBased = exercise['baseSetsSecs'] != null ||
                                exercise['baseSecs'] != null;

                            double? finalTotalBurnCalRep = finalBurnCalMap[exerciseName];
                            print('Exercise Name: $exerciseName, FinalTotalBurnCalRep: $finalTotalBurnCalRep');

                            String burnCaloriesDisplay = isRepBased
                                ? "${finalTotalBurnCalRep?.toStringAsFixed(2) ?? '0.00'} kcal"
                                : isTimeBased
                                ? "${exercise['TotalCalBurnSec']?.toStringAsFixed(2) ?? 'N/A'} kcal"
                                : "N/A";

                            return Card(
                              color: AppColor.primary,
                              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                              elevation: 3,
                              child: ListTile(
                                leading: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: AspectRatio(
                                    aspectRatio: 1,
                                    child: Image.asset( // Changed from Image.network
                                      _getLocalGifPath(exercise['name']), // New helper function
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.download_for_offline, size: 60),
                                    ),
                                  ),
                                ),
                                title: Text(
                                  exercise['name'].toString().toUpperCase(),
                                  style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                                subtitle: Text.rich(
                                  TextSpan(
                                    children: [
                                      TextSpan(
                                        text: "TARGET: ${exercise['target'].toString().toUpperCase()}\n",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                      TextSpan(
                                        text: "Reps/Time: ${getRepsTimeDisplay(exercise)}\n"
                                            "Burn Calories: $burnCaloriesDisplay\n",
                                        style: TextStyle(
                                          color: AppColor.backgroundgrey,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: isCompleted
                                    ? Icon(Icons.check_circle, color: Colors.green)
                                    : null,
                                onTap: () async {
                                  /*String exerciseId = exercise['id'].toString();
                                  String latestGifUrl = await _fetchExerciseGifUrl(exerciseId);
                                  if (latestGifUrl.isNotEmpty) {
                                    exercise['gifUrl'] = latestGifUrl;
                                  }*/
                                  String bodyPart = (exercise['bodyPart'] ?? '').toLowerCase();

                                  if (userAge != null) {
                                    String ageGroup = determineAgeGroup(userAge!);
                                    if (ageGroup != 'adults') {
                                      String exerciseNameLower = exercise['name'].toString().toLowerCase();
                                      List<String>? allowedList = allowedExercises[ageGroup]?[bodyPart];
                                      if (allowedList != null && !allowedList.contains(exerciseNameLower)) {
                                        bool proceedAge = await showDialog<bool>(
                                          context: context,
                                          builder: (context) => AlertDialog(
                                            title: Text("Age Suitability Warning",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.bold, color: Colors.red)),
                                            content: Text(
                                                "This exercise might not be suitable for your age group. Do you want to continue?"),
                                            actions: [
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(false),
                                                child: Text("Cancel"),
                                              ),
                                              TextButton(
                                                onPressed: () => Navigator.of(context).pop(true),
                                                child: Text("Continue"),
                                              ),
                                            ],
                                          ),
                                        ) ?? false;
                                        if (!proceedAge) return;
                                      }
                                    }
                                  }

                                  if (_userInjuries.contains(bodyPart)) {
                                    bool proceedInjury = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: Text("Injury Warning",
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold, color: Colors.red)),
                                        content: Text(
                                            "You have an injury in your $bodyPart. Proceeding may aggravate it. Continue?"),
                                        actions: [
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(false),
                                            child: Text("Cancel"),
                                          ),
                                          TextButton(
                                            onPressed: () => Navigator.of(context).pop(true),
                                            child: Text("Proceed"),
                                          ),
                                        ],
                                      ),
                                    ) ?? false;
                                    if (!proceedInjury) return;
                                  }

                                  /*Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ShowRepsKcal(exercise: exercise),
                                    ),
                                  );*/
                                },
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    );
                  }).toList(),
                );
              },
            );
          },
        ),
      ),
    );
  }
}