import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'show_reps_kcal.dart';
//import 'list_map_exercises.dart';
import '../../homepage/mainlandingpage.dart';
import 'dart:math';
import 'package:exercai_mobile/recommendation_exercise/recommendation_list_map.dart';

// NEW: Compute BMR using the Mifflin-St Jeor Equation
double computeBMR({
  required double weight, // in kg
  required double height, // in cm
  required int age,
  required String gender, // "Male" or "Female"
}) {
  if (gender.toLowerCase() == 'male') {
    return 10 * weight + 6.25 * height - 5 * age + 5;
  } else {
    return 10 * weight + 6.25 * height - 5 * age - 161;
  }
}

// NEW: Mapping for computed burn values.
// Keys are the exercise names in lowercase.
// This mapping now includes all 43 unique exercises (from your 45-item list, where two names are duplicates).
final Map<String, Map<String, dynamic>> computedExerciseData = {
  // TIME-BASED Exercises (burn calories per second)
  "neck side stretch": { "type": "time", "MET": 2.0 },
  "side push neck stretch": { "type": "time", "MET": 2.0 },
  "run": { "type": "time", "MET": 9.8 },
  "mountain climber": { "type": "time", "MET": 8.0 },
  "push to run": { "type": "time", "MET": 6.0 },
  "skater hops": { "type": "time", "MET": 7.0 },
  "seated lower back stretch": { "type": "time", "MET": 2.0 },
  "hamstring stretch": { "type": "time", "MET": 1.5 },
  "seated glute stretch": { "type": "time", "MET": 1.5 },
  "calf stretch with hands against wall": { "type": "time", "MET": 1.5 },
  "half knee bends (male)": { "type": "time", "MET": 6.0 },
  "high knee against wall": { "type": "time", "MET": 8.0 },
  "upper back stretch": { "type": "time", "MET": 2.0 },
  "front plank with twist": { "type": "time", "MET": 2.0 },
  "dynamic chest stretch (male)": { "type": "time", "MET": 2.0 },
  "overhead triceps stretch": { "type": "time", "MET": 1.5 },
  "rear deltoid stretch": { "type": "time", "MET": 1.5 },
  "sphinx": { "type": "time", "MET": 1.5 }, // Newly added

  // REP-BASED Exercises (burn calories per rep; repDuration in seconds)
  "wrist circles": { "type": "rep", "MET": 1.5, "repDuration": 3.0 },
  "ankle circles": { "type": "rep", "MET": 1.5, "repDuration": 3.0 },
  "spine stretch": { "type": "rep", "MET": 1.5, "repDuration": 3.0 },
  "standing lateral stretch": { "type": "rep", "MET": 1.5, "repDuration": 3.0 },
  "burpee": { "type": "rep", "MET": 8.0, "repDuration": 3.0 },
  "star jump (male)": { "type": "rep", "MET": 8.0, "repDuration": 3.0 },
  "incline push-up": { "type": "rep", "MET": 6.0, "repDuration": 3.0 },
  "clock push-up": { "type": "rep", "MET": 6.0, "repDuration": 3.0 },
  "push-up": { "type": "rep", "MET": 7.0, "repDuration": 3.0 },
  "shoulder tap push-up": { "type": "rep", "MET": 7.0, "repDuration": 3.0 },
  "push-up (wall)": { "type": "rep", "MET": 4.0, "repDuration": 3.0 },
  "close-grip push-up": { "type": "rep", "MET": 7.0, "repDuration": 3.0 },
  "triceps dips floor": { "type": "rep", "MET": 7.0, "repDuration": 3.0 },
  "lower back curl": { "type": "rep", "MET": 2.5, "repDuration": 3.0 },
  "dead bug": { "type": "rep", "MET": 5.0, "repDuration": 3.0 },
  "curl-up": { "type": "rep", "MET": 5.0, "repDuration": 3.0 },
  "walking lunge": { "type": "rep", "MET": 5.0, "repDuration": 3.0 },
  "split squats": { "type": "rep", "MET": 5.0, "repDuration": 3.0 },
  "bodyweight standing calf raise": { "type": "rep", "MET": 3.5, "repDuration": 2.0 },
  "modified push up to lower arms": { "type": "rep", "MET": 6.0, "repDuration": 3.0 },
  "bench dip (knees bent)": { "type": "rep", "MET": 5.5, "repDuration": 3.0 },
  "squat to overhead reach": { "type": "rep", "MET": 4.0, "repDuration": 3.0 },
  "alternate heel touchers": { "type": "rep", "MET": 4.0, "repDuration": 3.0 },
  "side hip abduction": { "type": "rep", "MET": 4.0, "repDuration": 3.0 },
  "russian twist": { "type": "rep", "MET": 5.0, "repDuration": 3.0 },
};

/// NEW: Compute the burn calories value for a given exercise.
/// For time-based exercises: returns kcal per second.
/// For rep-based exercises: returns kcal per rep.
double computeBurnValue(String exerciseName, double weight, double height, int age, String gender) {
  // Compute the user's BMR.
  double userBMR = computeBMR(weight: weight, height: height, age: age, gender: gender);
  // Define a reference BMR (adjust as needed)
  double referenceBMR = (gender.toLowerCase() == 'male') ? 1700 : 1500;
  double scalingFactor = userBMR / referenceBMR;

  // Look up exercise parameters using the lowercase name.
  final params = computedExerciseData[exerciseName.toLowerCase()];
  if (params == null) return 0.0;

  double met = params['MET'];
  // Calculate calories per minute using the MET formula: (MET * weight * 3.5) / 200.
  double caloriesPerMinute = (met * weight * 3.5) / 200;
  double caloriesPerSecond = caloriesPerMinute / 60;

  if (params['type'] == 'time') {
    return caloriesPerSecond * scalingFactor;
  } else if (params['type'] == 'rep') {
    double repDuration = params['repDuration'] ?? 3.0;
    return caloriesPerSecond * repDuration * scalingFactor;
  }
  return 0.0;
}

class FilterRepsKcal extends StatefulWidget {
  @override
  _FilterRepsKcalState createState() => _FilterRepsKcalState();
}

class _FilterRepsKcalState extends State<FilterRepsKcal> {
  late Stream<QuerySnapshot> _exercisesStream;
  bool isLoading = true;
  String? selectedGoal;
  String? selectedBMI;
  User? _currentUser;
  Map<String, double> finalBurnCalMap = {};
  int _currentDay = 1;
  int? userAge;
  double? userWeight;
  double? userHeight;
  String? userGender;
  List<String> _userInjuries = [];


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

  // Bagong Code Eto buburahin pag nag error
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
          selectedGoal = userData['goal'] ?? 'maintain';
          selectedBMI = userData['bmiCategory'] ?? 'normal';
          userAge = userData['age'];
          userWeight = (userData['weight'] as num?)?.toDouble() ?? 70.0;
          userHeight = double.tryParse(userData['height']?.toString() ?? "") ?? 175.0;
          userGender = userData['gender'] ?? "Male";
          String injuryArea = userData['injuryArea'] ?? '';
          _userInjuries = injuryArea.split(', ').where((s) => s.isNotEmpty).toList();
          if (_userInjuries.contains('none of them')) _userInjuries.clear();
        });
        // Initialize the exercise stream.
        await _initializeExercisesStream();
        // Fetch any previously computed burn values.
        await fetchFinalBurnCalValues();

        // Check if there are any active exercises before fetching new ones.
        QuerySnapshot activeExercisesSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(_currentUser!.email)
            .collection('UserExercises')
            .where('isActive', isEqualTo: true)
            .get();

        if (activeExercisesSnapshot.docs.isEmpty) {
          await fetchExercisesFromFirestore();
        }
      }
      setState(() => isLoading = false);
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }


  Future<String> _fetchExerciseGifUrl(String exerciseId) async {
    // Return the local asset path based on the exercise id/name.
    return _getLocalGifPath(exerciseId);
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
    if (selectedGoal == null || selectedBMI == null || _currentUser == null) return;

    setState(() {
      _exercisesStream = FirebaseFirestore.instance
          .collection('Users')
          .doc(_currentUser!.email)
          .collection('UserExercises')
          .where('goal', isEqualTo: selectedGoal) // Updated field
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




  // NEW: Updated fetchExercisesFromFirestore to compute and overwrite the burn values.
  Future<void> fetchExercisesFromFirestore({bool isTest = false}) async {
    if (selectedGoal == null || selectedBMI == null || _currentUser == null) return;
    if (userWeight == null || userHeight == null || userAge == null || userGender == null) return;
    try {
      final goalMap = exerciseRecommendationData[selectedGoal!] ?? {};
      final bmiMap = goalMap[selectedBMI!] ?? {};
      List<String> sections = ['warmup', 'mainWorkout', 'cooldown'];
      final seed = isTest ? DateTime.now().millisecondsSinceEpoch : _getDailySeed();
      final random = Random(seed);

      for (String section in sections) {
        List<dynamic> sectionExercises = bmiMap[section] ?? [];
        for (var exerciseRecommendationData in sectionExercises) {
          String exerciseName = exerciseRecommendationData['name'].toString();
          QuerySnapshot snapshot = await FirebaseFirestore.instance
              .collection('BodyweightExercises')
              .where('name', isEqualTo: exerciseName)
              .get();

          if (snapshot.docs.isNotEmpty) {
            var doc = snapshot.docs.first;
            var data = doc.data() as Map<String, dynamic>;

            var mergedData = Map<String, dynamic>.from(data)
              ..addAll({
                ...exerciseRecommendationData,
                'goal': selectedGoal,
                'bmiCategory': selectedBMI,
                'section': section,
                'completed': false,
                'restTime': 30,
                'isActive': true,
              });

            // NEW: Update the burn calories field using our computed value.
            if (computedExerciseData.containsKey(exerciseName.toLowerCase())) {
              double computedBurn = computeBurnValue(
                  exerciseName,
                  userWeight!,
                  userHeight!,
                  userAge!,
                  userGender!
              );
              if (exerciseRecommendationData.containsKey('baseSetsSecs') &&
                  exerciseRecommendationData['baseSetsSecs'] != null) {
                mergedData['burnCalperSec'] = computedBurn;
              } else if (exerciseRecommendationData.containsKey('baseSetsReps') &&
                  exerciseRecommendationData['baseSetsReps'] != null) {
                mergedData['burnCalperRep'] = computedBurn;
              }
            }

            DocumentReference userExerciseRef = FirebaseFirestore.instance
                .collection('Users')
                .doc(_currentUser!.email)
                .collection('UserExercises')
                .doc(mergedData['name'].toString());

            await userExerciseRef.set(mergedData, SetOptions(merge: true));
          }
        }
      }
    } catch (e) {
      print('Error generating new exercises: $e');
    }
  }

  String _getLocalGifPath(String exerciseName) {
    // Search all recommendation lists for the exercise
    for (var goalMap in exerciseRecommendationData.values) {
      for (var bmiMap in goalMap.values) {
        for (var section in ['warmup', 'mainWorkout', 'cooldown']) {
          List<dynamic> exercises = bmiMap[section] ?? [];
          for (var exercise in exercises) {
            if (exercise['name'].toString().toLowerCase() == exerciseName.toLowerCase()) {
              String path = exercise['gifPath'].toString();
              if (!path.endsWith('.gif')) path += '.gif';
              return path;
            }
          }
        }
      }
    }
    return 'assets/exercaiGif/fallback.gif';
  }


  // Update testDailyExerciseRotation
  Future<void> testDailyExerciseRotation() async {
    setState(() => isLoading = true);
    await _archiveCurrentExercises();
    await _deleteCurrentExercises();
    await fetchExercisesFromFirestore(isTest: true);
    setState(() => isLoading = false);
  }

  // Determine the age group based on the fetched age.
  String determineAgeGroup(int age) {
    if (age >= 4 && age <= 12) return "children";
    if (age >= 13 && age <= 17) return "teens";
    if (age >= 18 && age <= 59) return "adults";
    if (age >= 60) return "seniors";
    return "unknown";
  }

// Mapping for allowed exercises per age group and body part (all exercise names are in lowercase).
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


// New grouping function that groups exercises by their 'section' field.
  Map<String, List<Map<String, dynamic>>> groupExercisesBySection(List<Map<String, dynamic>> exercises) {
    Map<String, List<Map<String, dynamic>>> groupedExercises = {};
    for (var exercise in exercises) {
      String section = exercise['section'] ?? 'unknown';
      if (!groupedExercises.containsKey(section)) {
        groupedExercises[section] = [];
      }
      groupedExercises[section]!.add(exercise);
    }
    return groupedExercises;
  }

// Function to get the display text for each section.
  String getSectionDisplayText(String section) {
    switch (section) {
      case 'warmup':
        return "Warm-Up Exercises";
      case 'mainWorkout':
        return "Main Workout";
      case 'cooldown':
        return "Cool Down Exercises";
      default:
        return section.toUpperCase();
    }
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.backgroundWhite,
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios,color: AppColor.supersolidPrimary,),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => MainLandingPage()),
              );
            },
          ),
          title:
          Text(
            selectedGoal != null ? selectedGoal!.toUpperCase() : "Loading...",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold, color: AppColor.supersolidPrimary),
          ),
          //OLD TEXT
          /*Text(
            *//*selectedDifficulty == null || selectedBMI == null
                ? "Loading..."
                : "Exercises for $selectedDifficulty ($selectedBMI)",*//*
            "Recommended Exercises",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: AppColor.supersolidPrimary),
          ),*/
          backgroundColor: AppColor.backgroundWhite,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColor.moresolidPrimary,
          foregroundColor: AppColor.backgroundWhite,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
          onPressed: () async {
            bool? confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => Dialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 10,
                backgroundColor: Colors.white,
                child: Container(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header with icon and title
                      Row(
                        children: [
                          const Icon(Icons.info_outline, color: Colors.black87, size: 30),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Reload New Exercises For the Day",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: AppColor.supersolidPrimary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      // Content message
                      const Text(
                        "Do you want to reload new exercises for the day?",
                        style: TextStyle(fontSize: 18, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      // Action buttons
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey[300],
                              foregroundColor: Colors.black,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(false),
                            child: Text("Cancel", style: TextStyle(fontSize: 16)),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.moresolidPrimary,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: () => Navigator.of(context).pop(true),
                            //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>FilterRepsKcal())),
                            child: Text("Confirm", style: TextStyle(fontSize: 16)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
            if (confirmed == true) {
              testDailyExerciseRotation();
            }
          },
          tooltip: 'Test Exercise Rotation',
          child: const Icon(Icons.refresh),
        ),
        body: isLoading
            ? Center(child: CircularProgressIndicator())
            : _currentUser == null || selectedGoal == null || selectedBMI == null
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
                    if (doc.data() != null && (doc.data() as Map<String, dynamic>).containsKey('exerciseName'))
                      (doc['exerciseName'] ?? '').toString(): doc['totalExerciseTime'] ?? 0
                };

                final exercises = exercisesSnapshot.data!.docs.map((doc) {
                  final exercise = doc.data() as Map<String, dynamic>;
                  final totalTime = exerciseTimes[exercise['name'].toString()] ?? 0;

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

                final groupedExercises = groupExercisesBySection(exercises);
                final order = ['warmup', 'mainWorkout', 'cooldown'];

                final sortedEntries = groupedExercises.entries.toList()
                  ..sort((a, b) => order.indexOf(a.key).compareTo(order.indexOf(b.key)));


                return exercises.isEmpty
                    ? Center(
                  child: Text(
                    "Tap Reload Button if there's no Exercise Showing",
                    style: TextStyle(color: Colors.black87),
                  ),
                )
                    : ListView(
                  children: sortedEntries.map((entry) {
                    String section = entry.key;
                    List<Map<String, dynamic>> sectionExercises = entry.value;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                          decoration: BoxDecoration(
                            color: section == 'warmup'
                                ? Colors.green
                                : section == 'mainWorkout'
                                ? Colors.orange
                                : section == 'cooldown'
                                ? Colors.blue
                                : Colors.grey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            getSectionDisplayText(section),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),

                        // Here we use an external counter variable for overall card numbering.
                        Builder(builder: (context) {
                          int cardCounter = 0;
                          return Column(
                            children: sectionExercises.map((exercise) {
                              cardCounter++; // Increment counter for each card
                              final isCompleted = exercise['completed'] == true;
                              final exerciseId = exercise['id'].toString();
                              final exerciseName = exercise['name'].toString();
                              final totalTime = exerciseTimes[exerciseName] ?? 0;

                              return Card(
                                color: AppColor.backgroundWhite,
                                margin:
                                EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                elevation: 3,
                                child: ListTile(
                                  // Updated leading widget: a Row with a CircleAvatar showing the card number and the image.
                                  leading: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      CircleAvatar(
                                        backgroundColor: Colors.grey[300],
                                        child: Text(
                                          '$cardCounter',
                                          style: TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: AspectRatio(
                                          aspectRatio: 1, // Adjust as needed
                                          child: Image.asset(
                                            exercise['gifPath'] ??
                                                'assets/exercaiGif/fallback.gif',
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) =>
                                            const Icon(Icons.download_for_offline,
                                                size: 60),
                                          ),
                                        ),
                                      ),
                                    ],
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
                                  subtitle: StreamBuilder<DocumentSnapshot>(
                                    stream: FirebaseFirestore.instance
                                        .collection('Users')
                                        .doc(_currentUser!.email)
                                        .collection('UserExercises')
                                        .doc(exercise['name'].toString())
                                        .snapshots(),
                                    builder: (context, snapshot) {
                                      if (!snapshot.hasData) {
                                        return Text(
                                          "Loading...",
                                          style: TextStyle(color: Colors.grey.shade500),
                                        );
                                      }
                                      final updatedExercise = snapshot.data!.data() as Map<String, dynamic>;
                                      final repsTime = getRepsTimeDisplay(updatedExercise);
                                      bool isRepBased = updatedExercise['baseSetsReps'] != null &&
                                          updatedExercise['baseReps'] != null;
                                      bool isTimeBased = updatedExercise['baseSetsSecs'] != null ||
                                          updatedExercise['baseSecs'] != null;
                                      String updatedBurnCaloriesDisplay;
                                      if (isRepBased) {
                                        updatedBurnCaloriesDisplay =
                                        "${(updatedExercise['FinalTotalBurnCalRep'] as num?)?.toDouble()?.toStringAsFixed(2) ?? '0.00'} kcal";
                                      } else if (isTimeBased) {
                                        updatedBurnCaloriesDisplay =
                                        "${(updatedExercise['TotalCalBurnSec'] as num?)?.toDouble()?.toStringAsFixed(2) ?? 'N/A'} kcal";
                                      } else {
                                        updatedBurnCaloriesDisplay = "N/A";
                                      }
                                      return Text.rich(
                                        TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "TARGET: ${updatedExercise['target'].toString().toUpperCase()}\n",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "Reps/Time: $repsTime\nBurn Calories: $updatedBurnCaloriesDisplay",
                                              style: TextStyle(
                                                color: Colors.grey.shade500,
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                  trailing: isCompleted
                                      ? Icon(Icons.check_circle, color: Colors.green)
                                      : null,
                                  onTap: () async {
                                    // Update gifUrl as in your original code.
                                    String exerciseId = exercise['id'].toString();
                                    String latestGifUrl =
                                    await _fetchExerciseGifUrl(exerciseId);
                                    if (latestGifUrl.isNotEmpty) {
                                      exercise['gifPath'] = latestGifUrl;
                                    }
                                    String bodyPart = (exercise['bodyPart'] ?? '')
                                        .toLowerCase();

                                    // Age suitability check.
                                    if (userAge != null) {
                                      String ageGroup = determineAgeGroup(userAge!);
                                      // For adults, no warning is needed.
                                      if (ageGroup != 'adults') {
                                        String exerciseNameLower =
                                        exercise['name']
                                            .toString()
                                            .toLowerCase();
                                        List<String>? allowedList =
                                        allowedExercises[ageGroup]?[bodyPart];
                                        if (allowedList != null &&
                                            !allowedList.contains(exerciseNameLower)) {
                                          bool proceedAge =
                                              await showDialog<bool>(
                                                context: context,
                                                builder: (context) =>
                                                    Dialog(
                                                      shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              20)),
                                                      elevation: 10,
                                                      backgroundColor:
                                                      Colors.white,
                                                      child: Container(
                                                        // Increase dialog width for a bigger, more spacious design
                                                        width: MediaQuery.of(context)
                                                            .size
                                                            .width *
                                                            0.85,
                                                        padding:
                                                        EdgeInsets.all(20),
                                                        decoration: BoxDecoration(
                                                          color: Colors.white,
                                                          borderRadius:
                                                          BorderRadius.circular(
                                                              20),
                                                        ),
                                                        child: Column(
                                                          mainAxisSize:
                                                          MainAxisSize.min,
                                                          children: [
                                                            // Header with Icon and Title
                                                            Row(
                                                              children: [
                                                                Icon(
                                                                    Icons
                                                                        .info_outline,
                                                                    color:
                                                                    Colors.red,
                                                                    size: 30),
                                                                SizedBox(
                                                                    width: 10),
                                                                Expanded(
                                                                  child: Text(
                                                                    "Age Suitability Warning",
                                                                    style: TextStyle(
                                                                      fontSize:
                                                                      22,
                                                                      fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                      color: Colors
                                                                          .red,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            SizedBox(height: 20),
                                                            // Content message
                                                            Text(
                                                              "This exercise might not be suitable for your age group. Do you want to continue?",
                                                              style: TextStyle(
                                                                  fontSize: 18,
                                                                  color: Colors
                                                                      .black87),
                                                              textAlign:
                                                              TextAlign.center,
                                                            ),
                                                            SizedBox(height: 30),
                                                            // Action Buttons with Expanded to ensure proper layout
                                                            Row(
                                                              mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                              children: [
                                                                Expanded(
                                                                  child:
                                                                  ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                      Colors
                                                                          .grey[300],
                                                                      foregroundColor:
                                                                      Colors.black,
                                                                      shape:
                                                                      RoundedRectangleBorder(
                                                                        borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                            10),
                                                                      ),
                                                                    ),
                                                                    onPressed: () =>
                                                                        Navigator.of(
                                                                            context)
                                                                            .pop(
                                                                            false),
                                                                    child: Text(
                                                                        "Cancel",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                            16)),
                                                                  ),
                                                                ),
                                                                SizedBox(
                                                                    width: 10),
                                                                Expanded(
                                                                  child:
                                                                  ElevatedButton(
                                                                    style: ElevatedButton
                                                                        .styleFrom(
                                                                      backgroundColor:
                                                                      Colors.red,
                                                                      foregroundColor:
                                                                      Colors.white,
                                                                      shape:
                                                                      RoundedRectangleBorder(
                                                                        borderRadius:
                                                                        BorderRadius
                                                                            .circular(
                                                                            10),
                                                                      ),
                                                                    ),
                                                                    onPressed: () =>
                                                                        Navigator.of(
                                                                            context)
                                                                            .pop(
                                                                            true),
                                                                    child: Text(
                                                                        "Continue",
                                                                        style: TextStyle(
                                                                            fontSize:
                                                                            16)),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                              ) ??
                                                  false;
                                          if (!proceedAge) return;
                                        }
                                      }
                                    }

                                    // Injury warning check (existing logic).
                                    if (_userInjuries.contains(bodyPart)) {
                                      bool proceedInjury =
                                          await showDialog<bool>(
                                            context: context,
                                            builder: (context) => Dialog(
                                              shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                  BorderRadius.circular(20)),
                                              elevation: 10,
                                              backgroundColor: Colors.white,
                                              child: Container(
                                                // Increase the width of the dialog box
                                                width: MediaQuery.of(context).size.width *
                                                    0.85,
                                                padding: EdgeInsets.all(20),
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  borderRadius:
                                                  BorderRadius.circular(20),
                                                ),
                                                child: Column(
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    // Header with Icon and Title
                                                    Row(
                                                      children: [
                                                        Icon(Icons.warning,
                                                            color: Colors.red,
                                                            size: 30),
                                                        SizedBox(width: 10),
                                                        Expanded(
                                                          child: Text(
                                                            "Injury Warning",
                                                            style: TextStyle(
                                                              fontSize: 22,
                                                              fontWeight:
                                                              FontWeight.bold,
                                                              color: Colors.red,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    SizedBox(height: 20),
                                                    // Content message
                                                    Text(
                                                      "You have an injury in your $bodyPart. Proceeding may aggravate it. Continue?",
                                                      style: TextStyle(
                                                          fontSize: 18,
                                                          color: Colors.black87),
                                                      textAlign: TextAlign.center,
                                                    ),
                                                    SizedBox(height: 30),
                                                    // Action Buttons with Expanded to avoid overflow
                                                    Row(
                                                      mainAxisAlignment:
                                                      MainAxisAlignment.spaceEvenly,
                                                      children: [
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor:
                                                            Colors.grey[300],
                                                            foregroundColor:
                                                            Colors.black,
                                                            shape:
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(
                                                                  10),
                                                            ),
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.of(context)
                                                                  .pop(false),
                                                          child: Text("Cancel",
                                                              style: TextStyle(
                                                                  fontSize: 16)),
                                                        ),
                                                        SizedBox(width: 10),
                                                        ElevatedButton(
                                                          style: ElevatedButton.styleFrom(
                                                            backgroundColor: Colors.red,
                                                            foregroundColor:
                                                            Colors.white,
                                                            shape:
                                                            RoundedRectangleBorder(
                                                              borderRadius:
                                                              BorderRadius.circular(
                                                                  10),
                                                            ),
                                                          ),
                                                          onPressed: () =>
                                                              Navigator.of(context)
                                                                  .pop(true),
                                                          child: Text("Proceed",
                                                              style: TextStyle(
                                                                  fontSize: 16)),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ) ??
                                              false;
                                      if (!proceedInjury) return;
                                    }

                                    // If all checks pass, navigate to the exercise screen.
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ShowRepsKcal(exercise: exercise),
                                      ),
                                    );
                                  },
                                ),
                              );
                            }).toList(),
                          );
                        }),
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