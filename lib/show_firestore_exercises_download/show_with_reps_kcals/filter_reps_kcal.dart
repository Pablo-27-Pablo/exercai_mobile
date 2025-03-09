import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'show_reps_kcal.dart';
import 'list_map_exercises.dart';
import '../../homepage/mainlandingpage.dart';
import 'dart:math';

class FilterRepsKcal extends StatefulWidget {
  @override
  _FilterRepsKcalState createState() => _FilterRepsKcalState();
}

class _FilterRepsKcalState extends State<FilterRepsKcal> {
  late Stream<QuerySnapshot> _exercisesStream;
  bool isLoading = true;
  String? selectedDifficulty;
  String? selectedBMI;
  User? _currentUser;
  Map<String, double> finalBurnCalMap = {};
  int _currentDay = 1;

  // Add this function for daily exercise rotation
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

    //This is the latest that shows all infos in the card
  /*String getRepsTimeDisplay(Map<String, dynamic> exercise) {
    String repsTimeDisplay = 'N/A';
    String burnCaloriesInfo = '';

    if (exercise['baseSetsReps'] != null && exercise['baseReps'] != null) {
      repsTimeDisplay = "${exercise['baseSetsReps']} sets × ${exercise['baseReps']} reps";
      if (exercise['burnCalperRep'] != null) {
        burnCaloriesInfo = "\nBurn Calories per Rep: ${exercise['burnCalperRep']} kcal/rep";
      }
    } else if (exercise['baseSetsSecs'] != null && exercise['baseSecs'] != null) {
      repsTimeDisplay = _formatTimeDisplay(exercise['baseSetsSecs'], exercise['baseSecs']);
      if (exercise['burnCalperSec'] != null) {
        burnCaloriesInfo = "\nBurn Calories per Sec: ${exercise['burnCalperSec']} kcal/sec";
      }
    } else if (exercise['baseSecs'] != null) {
      repsTimeDisplay = _formatSingleDuration(exercise['baseSecs']);
      if (exercise['burnCalperSec'] != null) {
        burnCaloriesInfo = "\nBurn Calories per Second: ${exercise['burnCalperSec']} kcal/sec";
      }
    }

    return "$repsTimeDisplay$burnCaloriesInfo";
  }*/

  //This is the experiment to only shows 3 infos in the card
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
    String time = _secondsToTimeString(totalSecs);
    return "$sets sets × $time";
  }

  String _formatSingleDuration(int totalSecs) {
    return _secondsToTimeString(totalSecs);
  }

  String _secondsToTimeString(int totalSecs) {
    if (totalSecs >= 60) {
      int minutes = totalSecs ~/ 60;
      int seconds = totalSecs % 60;
      String result = "$minutes min";
      if (seconds > 0) result += " $seconds sec";
      return result;
    }
    return "$totalSecs sec";
  }

  String _formatTotalTime(int totalSeconds) {
    if (totalSeconds >= 60) {
      int minutes = totalSeconds ~/ 60;
      int seconds = totalSeconds % 60;
      return "$minutes:${seconds.toString().padLeft(2, '0')}";
    } else {
      return "$totalSeconds sec";
    }
  }



  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    fetchUserData();

  }
  // Add this variable in _FilterRepsKcalState class
  List<String> _userInjuries = [];

  // Modify fetchUserData to include injuryArea
  Future<void> fetchUserData() async {
    if (_currentUser == null) return;

    try {
      setState(() => isLoading = true);

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentUser!.email)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        setState(() {
          selectedBMI = userData['bmiCategory'] ?? 'normal';
          selectedDifficulty = userData['workoutLevel'] ?? 'beginner';
          // Fetch injury areas
          String injuryArea = userData['injuryArea'] ?? '';
          _userInjuries = injuryArea.split(', ').where((s) => s.isNotEmpty).toList();
          // Clear if "none of them" is selected
          if (_userInjuries.contains('none of them')) {
            _userInjuries.clear();
          }
        });

        await _initializeExercisesStream();
        await fetchFinalBurnCalValues();
      }

      setState(() => isLoading = false);
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  Future<String> _fetchExerciseGifUrl(String exerciseId) async {
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
  }


  Future<void> fetchFinalBurnCalValues() async {
    if (_currentUser == null) return;

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentUser!.email)
          .collection('UserExercises')
          .get();

      Map<String, double> fetchedData = {};
      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('FinalTotalBurnCalRep')) {
          fetchedData[doc.id] = (data['FinalTotalBurnCalRep'] as num).toDouble();
        }
      }

      setState(() {
        finalBurnCalMap = fetchedData;
      });

      // Debug log
      print('FinalBurnCalMap: $finalBurnCalMap');
    } catch (e) {
      print('Error fetching FinalTotalBurnCalRep values: $e');
    }
  }

  Future<void> updateCaloriesBurned(String exerciseName, double caloriesBurned, bool isRepBased) async {
    if (_currentUser == null) return;

    final userExerciseRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.email)
        .collection('UserExercises')
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


  Future<void> _initializeExercisesStream() async {
    if (selectedDifficulty == null || selectedBMI == null || _currentUser == null) return;

    setState(() {
      _exercisesStream = FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentUser!.email)
          .collection('UserExercises')
          .where('difficulty', isEqualTo: selectedDifficulty)
          .where('bmiCategory', isEqualTo: selectedBMI)
          .where('isActive', isEqualTo: true)
          .snapshots();
    });
  }




  Future<void> _archiveCurrentExercises() async {
    if (_currentUser == null) return;

    // Get current day number as an array
    _currentDay = await _updateCurrentDayArray();

    // Get current exercises
    final exercisesSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.email)
        .collection('UserExercises')
        .where('isActive', isEqualTo: true)
        .get();

    // Get current exercise times
    final timesSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.email)
        .collection('UserExerciseTimes')
        .get();

    // Calculate total exercise time for the day
    int totalExerciseTime = 0;
    List<String> exercisesPerformed = [];

    for (var dayDoc in timesSnapshot.docs) {
      final timesCollection = await dayDoc.reference.collection('times').get();
      for (var timeDoc in timesCollection.docs) {
        totalExerciseTime += (timeDoc['totalExerciseTime'] as int? ?? 0);
      }
    }

    for (var doc in exercisesSnapshot.docs) {
      exercisesPerformed.add(doc['name']); // Collect exercise names
    }

    // Archive exercises
    final batch = FirebaseFirestore.instance.batch();
    final dayCollectionRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.email)
        .collection('UserExercises')
        .doc('Day$_currentDay')
        .collection('exercises');

    // Archive exercise times
    final dayTimesRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.email)
        .collection('UserExerciseTimes')
        .doc('Day$_currentDay')
        .collection('times');

    for (var doc in exercisesSnapshot.docs) {
      final newDocRef = dayCollectionRef.doc(doc.id);
      batch.set(newDocRef, doc.data());
    }

    for (var doc in timesSnapshot.docs) {
      final newTimeRef = dayTimesRef.doc(doc.id);
      batch.set(newTimeRef, doc.data());
    }

    // Mark current exercises as inactive
    for (var doc in exercisesSnapshot.docs) {
      batch.update(doc.reference, {'isActive': false});
    }

    // Delete original exercise times
    for (var doc in timesSnapshot.docs) {
      batch.delete(doc.reference);
    }

    await batch.commit();
  }

// NEW FUNCTION: Updates currentDay to an array in metadata
  Future<int> _updateCurrentDayArray() async {
    final userRef = FirebaseFirestore.instance.collection('Users').doc(_currentUser!.email);
    final metaRef = userRef.collection('UserExercises').doc('--metadata--');

    final metaDoc = await metaRef.get();
    List<dynamic> days = [];
    int newDay = 1; // Default to Day1 if no previous data

    if (metaDoc.exists) {
      days = List.from(metaDoc.data()?['currentDay'] ?? []);
      newDay = days.isNotEmpty ? days.last + 1 : 1;
      days.add(newDay); // Append new day to array
    } else {
      days = [newDay];
    }

    await metaRef.set({'currentDay': days});
    return newDay;
  }



  Future<void> _deleteCurrentExercises() async {
    final query = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.email)
        .collection('UserExercises')
        .where('isActive', isEqualTo: false)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    for (var doc in query.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();
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
        .collection('UserExercises')
        .where('bodyPart', whereIn: targetBodyParts)
        .get();

    // Check if all exercises in the target body parts are marked as completed
    return snapshot.docs.every((doc) => doc['completed'] == true);
  }




  // Modified fetchExercisesFromFirestore to only create new exercises

  Future<void> fetchExercisesFromFirestore({bool isTest = false}) async {
    if (selectedDifficulty == null || selectedBMI == null || _currentUser == null) return;

    try {
      final difficultyMap = exerciseData[selectedDifficulty!] ?? {};
      final bmiMap = difficultyMap[selectedBMI!] ?? {};

      int exerciseLimit = selectedDifficulty == 'beginner' ? 1
          : selectedDifficulty == 'intermediate' ? 2
          : 3;

      List<String> targetBodyParts = [
        'back', 'chest', 'cardio', 'lower arms', 'lower legs', 'neck',
        'shoulders', 'upper arms', 'upper legs', 'waist'
      ];

      final seed = isTest ? DateTime.now().millisecondsSinceEpoch : _getDailySeed();
      final random = Random(seed);

      for (var bodyPart in targetBodyParts) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('BodyweightExercises')
            .where('bodyPart', isEqualTo: bodyPart)
            .get();

        List<Map<String, dynamic>> allExercises = List<Map<String, dynamic>>.from(bmiMap[bodyPart] ?? []);

        if (allExercises.isNotEmpty) {
          allExercises.shuffle(random);
          final selectedExercises = allExercises.take(exerciseLimit).toList();

          for (var doc in snapshot.docs) {
            final data = doc.data() as Map<String, dynamic>;
            final match = selectedExercises.firstWhere(
                  (ex) => (ex['name']?.toLowerCase() ?? '') == (data['name']?.toString().toLowerCase() ?? ''),
              orElse: () => <String, dynamic>{},
            );

            if (match.isNotEmpty) {
              final mergedData = Map<String, dynamic>.from(data)
                ..addAll({
                  'baseSetsReps': match['baseSetsReps'],
                  'baseReps': match['baseReps'],
                  'baseSetsSecs': match['baseSetsSecs'],
                  'baseSecs': match['baseSecs'],
                  'baseCalories': match['baseCalories'],
                  'burnCalperRep': match['burnCalperRep'],
                  'burnCalperSec': match['burnCalperSec'],
                  'difficulty': selectedDifficulty,
                  'bmiCategory': selectedBMI,
                  'completed': false,
                  'restTime': 30,
                  'isActive': true,
                });

              DocumentReference userExerciseRef = FirebaseFirestore.instance
                  .collection('Users')
                  .doc(_currentUser!.email)
                  .collection('UserExercises')
                  .doc(mergedData['name'].toString());

              await userExerciseRef.set(mergedData, SetOptions(merge: true));
            }
          }
        }
      }
    } catch (e) {
      print('Error generating new exercises: $e');
    }
  }

  // Update testDailyExerciseRotation
  Future<void> testDailyExerciseRotation() async {
    setState(() => isLoading = true);
    await _archiveCurrentExercises();
    await _deleteCurrentExercises();
    await fetchExercisesFromFirestore(isTest: true);
    setState(() => isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.backgroundgrey,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back,color: Colors.white,),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainLandingPage()),
              );
            },
          ),
          title: Text(
            /*selectedDifficulty == null || selectedBMI == null
                ? "Loading..."
                : "Exercises for $selectedDifficulty ($selectedBMI)",*/
            "Recommended Exercises",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),
          ),backgroundColor: AppColor.backgroundgrey,
        ),
        floatingActionButton: FloatingActionButton(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30), // Adjust the radius as needed
          ),
          onPressed: (){testDailyExerciseRotation();
            /*
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => FilterRepsKcal()), // Replace with the same page
          );*/
            },
          tooltip: 'Test Exercise Rotation',
          child: Icon(Icons.autorenew_rounded),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : _currentUser == null || selectedDifficulty == null || selectedBMI == null
            ? Center(child: Text("Please log in and select preferences"))
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
                  .collection('UserExerciseTimes')
                  .snapshots(),
              builder: (context, timesSnapshot) {
                if (timesSnapshot.hasError) {
                  return Center(child: Text('Error: ${timesSnapshot.error}'));
                }

                if (timesSnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                // Create a map of exerciseId to totalExerciseTime
                final exerciseTimes = {
                  for (var doc in timesSnapshot.data!.docs)
                    if (doc.data() != null && (doc.data() as Map<String, dynamic>).containsKey('exerciseId'))
                      (doc['exerciseId'] ?? '').toString(): doc['totalExerciseTime'] ?? 0
                };



                final exercises = exercisesSnapshot.data!.docs.map((doc) {
                  final exercise = doc.data() as Map<String, dynamic>;
                  final totalTime = exerciseTimes[exercise['id'].toString()] ?? 0;

                  // DYNAMIC CALORIE UPDATE FOR TIME-BASED
                  if (exercise['baseSetsSecs'] != null) {
                    exercise['TotalCalBurnSec'] = totalTime * (exercise['burnCalperSec']?.toDouble() ?? 0.0);

                    // Save the calculated TotalCalBurnSec to Firebase
                    FirebaseFirestore.instance
                        .collection('Users')
                        .doc(_currentUser!.email)
                        .collection('UserExercises')
                        .doc(exercise['name'].toString())
                        .update({'TotalCalBurnSec': exercise['TotalCalBurnSec']});
                  }

                  return exercise;
                }).toList();

                return exercises.isEmpty
                    ? Center(child: Text("Tap Reload Button if there's no Exercise Showing",style: TextStyle(color: Colors.white),))
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
                            bodyPart.toUpperCase(), // Display body part title
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

                            // Determine if exercise is Rep-Based or Time-Based
                            bool isRepBased = exercise['baseSetsReps'] != null && exercise['baseReps'] != null;
                            bool isTimeBased = exercise['baseSetsSecs'] != null || exercise['baseSecs'] != null;

                            // Use preloaded FinalTotalBurnCalRep values from finalBurnCalMap
                            double? finalTotalBurnCalRep = finalBurnCalMap[exerciseName];
                            print('Exercise Name: $exerciseName, FinalTotalBurnCalRep: $finalTotalBurnCalRep');

                            // Choose correct burn calories value
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
                                    aspectRatio: 1, // Adjust as needed
                                    child: Image.network(
                                      exercise['gifUrl'],
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                      const Icon(Icons.download_for_offline, size: 60),
                                    ),
                                  ),
                                ),

                                title: Text(
                                  exercise['name'].toString().toUpperCase(),
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
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
                                  //start of remove gifurl
                                  String exerciseId = exercise['id'].toString();
                                  String latestGifUrl = await _fetchExerciseGifUrl(exerciseId);

                                  if (latestGifUrl.isNotEmpty) {
                                    exercise['gifUrl'] = latestGifUrl; // Update the gifUrl before navigation
                                  }
                                  //end of remove gifurl
                                  String bodyPart = (exercise['bodyPart'] ?? '').toLowerCase();
                                  if (_userInjuries.contains(bodyPart)) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: Text("Injury Warning"),
                                          content: Text("You have an injury in your $bodyPart. Proceeding may aggravate it. Continue?"),
                                          actions: <Widget>[
                                            TextButton(
                                              child: Text("Cancel"),
                                              onPressed: () => Navigator.of(context).pop(),
                                            ),
                                            TextButton(
                                              child: Text("Proceed"),
                                              onPressed: () {
                                                Navigator.of(context).pop();
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) => ShowRepsKcal(exercise: exercise),
                                                  ),
                                                );
                                              },
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  } else {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ShowRepsKcal(exercise: exercise),
                                      ),
                                    );
                                  }
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