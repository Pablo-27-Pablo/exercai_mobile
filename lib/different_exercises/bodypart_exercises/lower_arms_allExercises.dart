import 'package:exercai_mobile/different_exercises/bodypart_exercises/configurations/show_reps_allExercises.dart';
import 'package:exercai_mobile/different_exercises/choose_bodyparts.dart';
import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercai_mobile/different_exercises/list_all_exercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/list_allowed_exercise_age.dart';

class LowerArmsAllexercises extends StatefulWidget {
  @override
  _LowerArmsAllexercisesState createState() => _LowerArmsAllexercisesState();
}

class _LowerArmsAllexercisesState extends State<LowerArmsAllexercises>
    with AutomaticKeepAliveClientMixin<LowerArmsAllexercises> {
  Stream<QuerySnapshot> _exercisesStream = const Stream.empty();
  bool isLoading = true;
  User? _currentUser;
  Map<String, double> finalBurnCalMap = {};
  int? userAge;

  int _getDailySeed() {
    final now = DateTime.now();
    final daysSinceEpoch =
        now.millisecondsSinceEpoch ~/ (1000 * 60 * 60 * 24);
    return _currentUser!.email.hashCode + daysSinceEpoch;
  }

  Map<String, List<Map<String, dynamic>>> groupExercisesByBodyPart(
      List<Map<String, dynamic>> exercises) {
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

        setState(() {
          userAge = updatedUserAge;
        });

        _initializeExercisesStream();
        await fetchFinalBurnCalValues();
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }


  void _initializeExercisesStream() {
    if (_currentUser != null) {
      setState(() {
        _exercisesStream = FirebaseFirestore.instance
            .collection('Users')
            .doc(_currentUser!.email)
            .collection('AllExercises')
            .where('isActive', isEqualTo: true)
            .where('bodyPart', isEqualTo: 'lower arms')
            .snapshots();
      });
    }
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
            if ((doc.data() as Map<String, dynamic>)
                .containsKey('FinalTotalBurnCalRep'))
              doc.id: (doc['FinalTotalBurnCalRep'] as num).toDouble()
        };
      });
    } catch (e) {
      print('Error fetching FinalTotalBurnCalRep values: $e');
    }
  }


  // If none are found, fetch from BodyweightExercises and store them.
  Future<void> checkAndFetchNeckExercises() async {
    if (_currentUser == null) return;
    try {
      QuerySnapshot neckSnapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentUser!.email)
          .collection('AllExercises')
          .where('bodyPart', isEqualTo: 'lower arms')
          .get();

      if (neckSnapshot.docs.isEmpty) {
        print("No lwoer arms exercises found in AllExercises. Fetching from BodyweightExercises...");
        await fetchExercisesFromFirestoreInBackground();
      } else {
        print("lower arms exercises already exist. Using real-time stream.");
      }
    } catch (e) {
      print("Error checking lower arms exercises: $e");
    }
  }

  // This function merges data from the "BodyweightExercises" collection
  // and writes it to the "AllExercises" collection.
  Future<void> fetchExercisesFromFirestoreInBackground() async {
    if (_currentUser == null) return;

    try {
      print("Fetching exercises from BodyweightExercises...");
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('BodyweightExercises')
          .where('bodyPart', isEqualTo: 'lower arms')
          .get();

      print("Found ${snapshot.docs.length} exercises in BodyweightExercises");

      for (var doc in snapshot.docs) {
        final firestoreExercise = doc.data() as Map<String, dynamic>;
        final exerciseName = firestoreExercise['name']?.toString() ?? '';
        final exerciseId = doc.id;

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
            'gifPath': localData['gifPath'],
            'completed': false,
            'restTime': 30,
            'isActive': true,
          });

        // Update or merge the exercise data in Firestore
        DocumentReference docRef = FirebaseFirestore.instance
            .collection('Users')
            .doc(_currentUser!.email)
            .collection('AllExercises')
            .doc(exerciseName);
        await docRef.set(mergedData, SetOptions(merge: true));
        print("✅ Merged exercise: $exerciseName");
      }

      print("Successfully merged lower arms exercises into AllExercises");
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
    return 'assets/exercaiGif/fallback.gif';
  }

  Future<void> updateCaloriesBurned(String exerciseId, double caloriesBurned, bool isRepBased) async {
    if (_currentUser == null) return;

    final userExerciseRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.email)
        .collection('AllExercises')
        .doc(exerciseId);

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

  Future<bool> areAllExercisesCompleted() async {
    if (_currentUser == null) return true;

    List<String> targetBodyParts = [
      'back',
      'chest',
      'cardio',
      'lower arms',
      'lower legs',
      'neck',
      'shoulders',
      'upper arms',
      'upper legs',
      'waist'
    ];

    QuerySnapshot snapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.email)
        .collection('AllExercises')
        .where('bodyPart', whereIn: targetBodyParts)
        .get();

    return snapshot.docs.every((doc) => doc['completed'] == true);
  }

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _initializeData();
  }

  Future<void> _initializeData() async {
    await fetchUserData();

    await checkAndFetchNeckExercises();
    // Reinitialize the stream (in case new data was added)
    _initializeExercisesStream();
    if (mounted) setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.backgroundWhite,
        appBar: AppBar(
          backgroundColor: AppColor.backgroundWhite,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: AppColor.supersolidPrimary),
            onPressed: () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                    builder: (context) => ChooseBodyparts())),
          ),
          title: Text(
            "Lower Arms Exercises",
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppColor.supersolidPrimary),
          ),
        ),
        body: isLoading
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Loading Your Exercise\nPlease wait a moment...',
                style: TextStyle(
                    color: Colors.black87,
                    fontWeight: FontWeight.bold,
                    fontSize: 18),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15),
              CircularProgressIndicator(),
            ],
          ),
        )
            : _currentUser == null
            ? Center(child: Text("Please log in"))
            : StreamBuilder<QuerySnapshot>(
          stream: _exercisesStream,
          builder: (context, exercisesSnapshot) {
            if (exercisesSnapshot.hasError) {
              return Center(
                  child: Text('Error: ${exercisesSnapshot.error}'));
            }
            if (exercisesSnapshot.connectionState ==
                ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }

            final exercises = exercisesSnapshot.data!.docs.map((doc) {
              return doc.data() as Map<String, dynamic>;
            }).toList();

            return exercises.isEmpty
                ? Center(
                child: Text("No Lower arms exercises found. Tap reload if needed.",
                    style: TextStyle(color: Colors.black87)))
                : ListView(
              children: groupExercisesByBodyPart(exercises)
                  .entries
                  .map((entry) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    Column(
                      children: exercises.map((exercise) {
                        final isCompleted =
                            exercise['completed'] == true;
                        final exerciseName =
                        exercise['name'].toString();

                        bool isRepBased = exercise[
                        'baseSetsReps'] != null &&
                            exercise['baseReps'] != null;
                        bool isTimeBased = exercise[
                        'baseSetsSecs'] != null ||
                            exercise['baseSecs'] != null;

                        // Use preloaded FinalTotalBurnCalRep values from finalBurnCalMap
                        double? finalTotalBurnCalRep =
                        finalBurnCalMap[exerciseName];
                        print('Exercise Name: $exerciseName, FinalTotalBurnCalRep: $finalTotalBurnCalRep');

                        String burnCaloriesDisplay = isRepBased
                            ? "${finalTotalBurnCalRep?.toStringAsFixed(2) ?? '0.00'} kcal"
                            : isTimeBased
                            ? "${exercise['TotalCalBurnSec']?.toStringAsFixed(2) ?? '0.0'} kcal"
                            : "N/A";

                        return Card(
                          color: AppColor.backgroundWhite,
                          margin: EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          elevation: 3,
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius:
                              BorderRadius.circular(12),
                              child: AspectRatio(
                                aspectRatio: 1,
                                child: Image.asset(
                                  _getLocalGifPath(
                                      exercise['name']),
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error,
                                      stackTrace) =>
                                  const Icon(
                                      Icons.download_for_offline,
                                      size: 60),
                                ),
                              ),
                            ),
                            title: Text(
                              exercise['name']
                                  .toString()
                                  .toUpperCase(),
                              style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.supersolidPrimary),
                            ),
                            subtitle: Text.rich(
                              TextSpan(
                                children: [
                                  TextSpan(
                                    text: "TARGET: ${exercise['target'].toString().toUpperCase()}\n",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  TextSpan(
                                    text:
                                    "Reps/Time: ${getRepsTimeDisplay(exercise)}\nBurn Calories: $burnCaloriesDisplay\n",
                                    style: TextStyle(
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            trailing: isCompleted
                                ? Icon(Icons.check_circle,
                                color: Colors.green)
                                : null,
                            onTap: () async {
                              // Get the document ID from the exercise data.
                              final exerciseId = exercise['firestoreId'] ??
                                  exercise['id'];
                              String bodyPart = (exercise['bodyPart'] ??
                                  '')
                                  .toLowerCase();

                              if (userAge != null) {
                                String ageGroup =
                                determineAgeGroup(userAge!);
                                if (ageGroup != 'adults') {
                                  String exerciseNameLower =
                                  exercise['name']
                                      .toString()
                                      .toLowerCase();
                                  List<String>? allowedList =
                                  allowedExercises[ageGroup]?[bodyPart];
                                  if (allowedList != null &&
                                      !allowedList
                                          .contains(exerciseNameLower)) {
                                    bool proceedAge =
                                        await showDialog<bool>(
                                          context: context,
                                          builder: (context) =>
                                              AlertDialog(
                                                title: Text("Age Suitability Warning",
                                                    style: TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        color: Colors.red)),
                                                content: Text(
                                                    "This exercise might not be suitable for your age group. Do you want to continue?"),
                                                actions: [
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(false),
                                                    child: Text("Cancel"),
                                                  ),
                                                  TextButton(
                                                    onPressed: () =>
                                                        Navigator.of(context)
                                                            .pop(true),
                                                    child: Text("Continue"),
                                                  ),
                                                ],
                                              ),
                                        ) ??
                                            false;
                                    if (!proceedAge) return;
                                  }
                                }
                              }
                              // Navigate to exercise details.
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ShowRepsAllexercises(
                                      exercise: exercise),
                                ),
                              );
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
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
