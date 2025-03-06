import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'show_reps_kcal.dart';
import 'list_map_exercises.dart';
import '../../homepage/mainlandingpage.dart';
import 'dart:math';

class FilterPerday extends StatefulWidget {
  @override
  _FilterPerdayState createState() => _FilterPerdayState();
}

class _FilterPerdayState extends State<FilterPerday> {
  late Stream<QuerySnapshot> _exercisesStream;
  bool isLoading = true;
  String? selectedDifficulty;
  String? selectedBMI;
  User? _currentUser;
  Map<String, double> finalBurnCalMap = {};
  int _currentDay = DateTime.now().day;

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


  String getRepsTimeDisplay(Map<String, dynamic> exercise) {
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
        burnCaloriesInfo = "\nBurn Calories per Second: ${exercise['burnCalperSec']} kcal/sec";
      }
    } else if (exercise['baseSecs'] != null) {
      repsTimeDisplay = _formatSingleDuration(exercise['baseSecs']);
      if (exercise['burnCalperSec'] != null) {
        burnCaloriesInfo = "\nBurn Calories per Second: ${exercise['burnCalperSec']} kcal/sec";
      }
    }

    return "$repsTimeDisplay$burnCaloriesInfo";
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
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await fetchUserData();

    // Check if it's a new day and reset exercises if needed
    if (_isNewDay()) {
      await _resetExercisesForNewDay();
    }
  }

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
        finalBurnCalMap = fetchedData; // ✅ Storing values in a Map
      });
    } catch (e) {
      print('Error fetching FinalTotalBurnCalRep values: $e');
    }
  }


  Future<void> _initializeExercisesStream() async {
    if (selectedDifficulty == null || selectedBMI == null || _currentUser == null) return;

    _exercisesStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.email)
        .collection('UserExercises')
        .where('difficulty', isEqualTo: selectedDifficulty)
        .where('bmiCategory', isEqualTo: selectedBMI)
        .where('isActive', isEqualTo: true)
        .snapshots();
  }
  bool _isNewDay() {
    final now = DateTime.now();
    return now.day != _currentDay;
  }

  // Add this function to archive current exercises
  // Archive current exercises and generate new ones
  Future<void> _resetExercisesForNewDay() async {
    if (_currentUser == null) return;

    setState(() => isLoading = true);

    // Archive current exercises
    final exercisesSnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.email)
        .collection('UserExercises')
        .where('isActive', isEqualTo: true)
        .get();

    final batch = FirebaseFirestore.instance.batch();
    final dayCollectionRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser!.email)
        .collection('UserExercises')
        .doc('Day${DateTime.now().day}')
        .collection('exercises');

    for (var doc in exercisesSnapshot.docs) {
      final exerciseData = doc.data();
      final newDocRef = dayCollectionRef.doc(doc.id);
      batch.set(newDocRef, exerciseData);
    }

    // Mark current exercises as inactive
    for (var doc in exercisesSnapshot.docs) {
      batch.update(doc.reference, {'isActive': false});
    }

    await batch.commit();

    // Generate new exercises for the new day
    await fetchExercisesFromFirestore();

    // Update the current day
    _currentDay = DateTime.now().day;

    setState(() => isLoading = false);
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

      final seed = _getDailySeed();
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

  // Add this function for testing
  Future<void> testDailyExerciseRotation() async {
    setState(() => isLoading = true);
    await _resetExercisesForNewDay();
    await _deleteCurrentExercises();
    await fetchExercisesFromFirestore(isTest: true);
    setState(() => isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainLandingPage()),
            );
          },
        ),
        title: Text(
          selectedDifficulty == null || selectedBMI == null
              ? "Loading..."
              : "Exercises for $selectedDifficulty ($selectedBMI)",
        ),


      ),
      floatingActionButton: FloatingActionButton(
        onPressed: testDailyExerciseRotation,
        tooltip: 'Test Exercise Rotation',
        child: Icon(Icons.autorenew),
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
                  doc['exerciseId'].toString(): doc['totalExerciseTime'] ?? 0
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
                  ? Center(child: Text("No exercises found for your category."))
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
                            color: Colors.blueAccent,
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

                          // Choose correct burn calories value
                          String burnCaloriesDisplay = isRepBased
                              ? "${finalTotalBurnCalRep?.toStringAsFixed(2) ?? '0.00'} kcal" //Dating N/A yung 0.00
                              : isTimeBased
                              ? "${exercise['TotalCalBurnSec']?.toStringAsFixed(2) ?? 'N/A'} kcal"
                              : "N/A";

                          return Card(
                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            elevation: 3,
                            child: ListTile(
                              leading: Image.network(
                                exercise['gifUrl'],
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.download_for_offline, size: 50),
                              ),
                              title: Text(exercise['name']),
                              subtitle: Text(
                                  "Target: ${exercise['target']}\n"
                                      "Equipment: ${exercise['equipment']}\n"
                                      "Reps/Time: ${getRepsTimeDisplay(exercise)}\n"
                                      "Burn Calories: $burnCaloriesDisplay\n"
                                      "Total Time: ${_formatTotalTime(totalTime)}\n"
                                //"ID: ${exercise['id']}",
                              ),
                              trailing: isCompleted
                                  ? Icon(Icons.check_circle, color: Colors.green)
                                  : null,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShowRepsKcal(exercise: exercise),
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
          );
        },
      ),
    );
  }
}