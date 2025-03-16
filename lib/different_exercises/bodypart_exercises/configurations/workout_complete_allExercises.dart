import 'package:exercai_mobile/different_exercises/choose_bodyparts.dart';
import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart'; // Make sure to add this dependency in pubspec.yaml
import 'dart:math'; // Needed for the blast direction

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
  const WorkoutCompleteAllexercises({Key? key, required this.exercise})
      : super(key: key);

  @override
  State<WorkoutCompleteAllexercises> createState() =>
      _WorkoutCompleteAllexercisesState();
}

class _WorkoutCompleteAllexercisesState extends State<WorkoutCompleteAllexercises> {
  // Declare as late final to ensure it is initialized in initState
  late final ConfettiController _confettiController;

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          // Confetti animation
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirection: -pi / 2,
            emissionFrequency: 0.05,
            numberOfParticles: 50,
            gravity: 0.2,
          ),
          Column(
            children: [
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      'assets/congrats.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey.shade300,
                          child: const Center(
                            child: Icon(Icons.broken_image,
                                color: Colors.grey, size: 40),
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
                  width: double.infinity,
                  padding:
                  const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.orange.shade400, Colors.yellow.shade300],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 10,
                        offset: Offset(0, -3),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '🎉 Congratulations! 🎉',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'You have successfully completed your workout!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          String bodyPart = widget.exercise['bodyPart']
                              ?.toString()
                              .toLowerCase() ??
                              'neck';
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  getExerciseListPage(bodyPart),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.supersolidPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 50),
                          shadowColor: AppColor.supersolidPrimary,
                          elevation: 10,
                        ),
                        child: const Text(
                          'Next Workout',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
