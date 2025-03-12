import 'package:exercai_mobile/different_exercises/choose_bodyparts.dart';
import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';

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


class WorkoutCompleteAllexercises extends StatefulWidget {
  final Map<String, dynamic> exercise; // Added this parameter
  const WorkoutCompleteAllexercises({Key? key, required this.exercise}) : super(key: key);

  @override
  State<WorkoutCompleteAllexercises> createState() => _WorkoutCompleteAllexercisesState();
}

class _WorkoutCompleteAllexercisesState extends State<WorkoutCompleteAllexercises> {

  // Helper function to return the corresponding list page based on bodyPart.
  Widget getExerciseListPage(String bodyPart) {
    switch (bodyPart) {
      case 'neck': return NeckAllexercises();
      case 'back': return BackAllexercises();
      case 'cardio': return CardioAllexercises();
      case 'chest': return ChestAllexercises();
      case 'lower arms': return LowerArmsAllexercises();
      case 'lower legs': return LowerLegsAllexercises();
      case 'shoulders': return ShouldersAllexercises();
      case 'upper arms': return UpperArmsAllexercises();
      case 'upper legs': return UpperLegsAllexercises();
      case 'waist': return WaistAllexercises();
      default: return ChooseBodyparts();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Column(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.only(left: 40, top: 0, right: 40, bottom: 40),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.asset(
                  'assets/congrats.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey,
                      child: const Center(
                        child: Icon(Icons.broken_image, color: Colors.white, size: 40),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(
              color: AppColor.yellowtext,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Congratulations!',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'You Have Finished Your Workout',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      String bodyPart =
                          widget.exercise['bodyPart']?.toString().toLowerCase() ?? 'neck';
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => getExerciseListPage(bodyPart),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.purpletext,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40),
                      ),
                      padding: const EdgeInsets.only(left: 50, top: 20, right: 50, bottom: 20),
                    ),
                    child: const Text(
                      'Go to the next workout',
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

