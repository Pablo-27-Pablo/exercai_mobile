import 'package:cloud_firestore/cloud_firestore.dart';
import 'reps_page_allExercises.dart';
import 'package:exercai_mobile/different_exercises/choose_bodyparts.dart';
import 'package:exercai_mobile/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/show_firestore_exercises_download/proceed_to_exercise/reps_page.dart';

// Import the exercise list pages for different body parts
import '../neck_allExercises.dart';
import '../back_allExercises.dart';
import '../cardio_allExercises.dart';
import '../chest_allExercises.dart';
import '../lower_arms_allExercises.dart';
import '../lower_legs_allExercises.dart';
import '../shoulders_allExercises.dart';
import '../upper_arms_allExercises.dart';
import '../upper_legs_allExercises.dart';
import '../waist_allExercises.dart';

class ShowRepsAllexercises extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ShowRepsAllexercises({Key? key, required this.exercise}) : super(key: key);

  @override
  _ShowRepsAllexercisesState createState() => _ShowRepsAllexercisesState();
}

class _ShowRepsAllexercisesState extends State<ShowRepsAllexercises> {
  late Stream<DocumentSnapshot> _exerciseStream;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _initializeExerciseStream();
  }

  // Now using the "AllExercises" collection and the document ID (preferably "firestoreId")
  void _initializeExerciseStream() {
    String docKey = widget.exercise['name'].toString();
    _exerciseStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser.email)
        .collection('AllExercises')
        .doc(docKey)
        .snapshots();
  }

  String _formatDuration(int? totalSecs) {
    final safeSecs = totalSecs ?? 0;
    if (safeSecs >= 60) {
      int minutes = safeSecs ~/ 60;
      int seconds = safeSecs % 60;
      String result = "$minutes minute${minutes != 1 ? 's' : ''}";
      if (seconds > 0) result += " $seconds second${seconds != 1 ? 's' : ''}";
      return result;
    }
    return "$safeSecs second${safeSecs != 1 ? 's' : ''}";
  }

  // Helper function to return the corresponding list page based on bodyPart.
  Widget getExerciseListPage(String bodyPart) {
    switch (bodyPart) {
      case 'neck':
        return NeckAllexercises();
      case 'back':
        return BackAllexercises();
      case 'cardio':
        return CardioAllexercises();
      case 'chest':
        return ChestAllexercises();
      case 'lower arms':
        return LowerArmsAllexercises();
      case 'lower legs':
        return LowerLegsAllexercises();
      case 'shoulders':
        return ShouldersAllexercises();
      case 'upper arms':
        return UpperArmsAllexercises();
      case 'upper legs':
        return UpperLegsAllexercises();
      case 'waist':
        return WaistAllexercises();
      default:
        return ChooseBodyparts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColor.backgroundgrey,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              // Determine the originating body part from the exercise details
              String bodyPart =
                  widget.exercise['bodyPart']?.toString().toLowerCase() ?? 'neck';
              Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (context) => getExerciseListPage(bodyPart)));
            },
            icon: Icon(Icons.arrow_back),
          ),
          title: Text(widget.exercise['name'] ?? 'Unnamed Exercise'),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: _exerciseStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Exercise data not found'));
            }

            final exercise = snapshot.data!.data() as Map<String, dynamic>;
            final baseSetsReps = exercise['baseSetsReps'] as int?;
            final baseReps = exercise['baseReps'] as int?;
            final baseSetsSecs = exercise['baseSetsSecs'] as int?;
            final baseSecs = exercise['baseSecs'] as int?;
            final baseRepsConcat = exercise['baseRepsConcat'] as List<dynamic>?;
            final baseSecConcat = exercise['baseSecConcat'] as List<dynamic>?;

            final isRepBased = baseSetsReps != null && baseReps != null;
            final isTimeBased = baseSetsSecs != null && baseSecs != null;
            final isSingleDuration = baseSecs != null && !isTimeBased;
            final restTime = exercise['restTime'];

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        exercise['gifPath'] ?? 'assets/exercaiGif/fallback.gif',
                        height: 200,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error_outline, size: 100),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Exercise Details',
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.bold),
                  ),
                  ListTile(
                    title: Text(
                      'Target Muscle: ${exercise['target'] ?? 'N/A'}',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (isRepBased)
                            Column(
                              children: [
                                Text(
                                  '${baseSetsReps ?? 0} Sets',
                                  style: const TextStyle(
                                      fontSize: 18, color: AppColor.primary),
                                ),
                                Text(
                                  '${baseReps ?? 0} Reps',
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.primary),
                                ),
                                if (baseRepsConcat != null)
                                  Text(
                                    'Reps per Set: ${baseRepsConcat.join(', ')}',
                                    style: const TextStyle(
                                        fontSize: 14, color: AppColor.primary),
                                  ),
                              ],
                            ),
                          if (isTimeBased || isSingleDuration)
                            Column(
                              children: [
                                const Icon(Icons.timer, size: 30),
                                if (isTimeBased)
                                  Text(
                                    '${baseSetsSecs ?? 0} Sets',
                                    style: const TextStyle(
                                        fontSize: 18, color: AppColor.primary),
                                  ),
                                Text(
                                  _formatDuration(baseSecs),
                                  style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      color: AppColor.primary),
                                ),
                                if (baseSecConcat != null)
                                  Text(
                                    'Seconds per Set: ${baseSecConcat.join(', ')}',
                                    style: const TextStyle(
                                        fontSize: 14, color: AppColor.primary),
                                  ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  // New widget to show the saved rest time for time-based exercises
                  if (!isRepBased && restTime != null)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Center(
                        child: Text(
                          'Rest Time: $restTime seconds',
                          style: const TextStyle(
                              fontSize: 18, color: AppColor.primary),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  const Center(
                    child: Text(
                      'Estimated Burn Calories',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  Center(
                    child: Chip(
                      backgroundColor: Colors.white,
                      label: Text(
                            () {
                          final exerciseData =
                          snapshot.data!.data() as Map<String, dynamic>;
                          final dynamicCalories = exerciseData['baseCalories'] ??
                              widget.exercise['baseCalories'];
                          return '${(dynamicCalories is num) ? dynamicCalories.toStringAsFixed(2) : 'N/A'} kcal';
                        }(),
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.primary),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text("Instructions:", style: _headerStyle()),
                  const SizedBox(height: 10),
                  ...List.generate(
                    exercise['instructions']?.length ?? 0,
                        (index) => Text("• ${exercise['instructions'][index]}",
                        style: TextStyle(color: Colors.white)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              RepsPageAllexercises(exercise: exercise),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                    ),
                    child: const Text('Proceed to Exercise'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  TextStyle _headerStyle() => const TextStyle(
      fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white);
}
