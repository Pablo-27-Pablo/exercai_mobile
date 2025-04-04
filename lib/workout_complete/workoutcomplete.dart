import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/show_firestore_exercises_download/show_with_reps_kcals/filter_reps_kcal.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:audioplayers/audioplayers.dart';

class CompleteWorkout extends StatefulWidget {
  const CompleteWorkout({Key? key}) : super(key: key);

  @override
  State<CompleteWorkout> createState() => _CompleteWorkoutState();
}

class _CompleteWorkoutState extends State<CompleteWorkout> {
  late final ConfettiController _confettiController;
  late final AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();

    // Initialize and play confetti animation
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 3));
    _confettiController.play();

    // Initialize the audio player and play the congrats audio
    _audioPlayer = AudioPlayer();
    _audioPlayer.play(AssetSource('audio/Congrats.mp3'));

    // Start the skipping process after ensuring playback starts.
    _skipAudio();
  }

  Future<void> _skipAudio() async {
    // Wait for 1 second to ensure playback starts
    await Future.delayed(Duration(milliseconds: 1000));
    // Skip to 7 seconds in the track (effectively skipping the first 5 seconds)
    await _audioPlayer.seek(Duration(seconds: 7));
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          alignment: Alignment.center,
          children: [
            // Confetti animation to celebrate the completion
            ConfettiWidget(
              confettiController: _confettiController,
              blastDirection: -pi / 2,
              emissionFrequency: 0.05,
              numberOfParticles: 50,
              gravity: 0.2,
            ),
            Column(
              children: [
                // Top section: Congratulatory image
                Expanded(
                  flex: 2,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 30),
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
                // Middle section: Congratulations text with gradient background
                Expanded(
                  flex: 1,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 30),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.orange.shade400,
                          Colors.yellow.shade300
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(30)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 10,
                          offset: const Offset(0, -3),
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
                          'You have finished your workout',
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
                // Bottom section: Button to go to the next workout
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => FilterRepsKcal()),
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
      ),
    );
  }
}
