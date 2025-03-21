import 'package:exercai_mobile/exercise/exercise.dart';
import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:exercai_mobile/pages/Main_Pages/Exercises_Page.dart';
import 'package:exercai_mobile/utils/music_background.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/pages/home.dart';
import 'package:exercai_mobile/pages/realtime_2.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:audioplayers/audioplayers.dart';

final musicPlayer1 = MusicPlayerService();

class CongratsApp extends StatelessWidget {
  const CongratsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        backgroundColor: AppColor.backgroundgrey,
        body: Center(child: CongratulationsCard()),
      ),
    );
  }
}

class CongratulationsCard extends StatefulWidget {
  const CongratulationsCard({super.key});

  @override
  _CongratulationsCardState createState() => _CongratulationsCardState();
}

class _CongratulationsCardState extends State<CongratulationsCard> {
  final AudioPlayer _player = AudioPlayer();

  @override
  void initState() {
    super.initState();
    musicPlayer1.playCongrats();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  void onFinishTap() {
    setState(() {
      totalCaloriesBurn = 0;
      if (Mode == "postureCorrection") {
        raise = 0;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Trypage()),
        );
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainLandingPage()),
        );
      }
    });
  }

  void onContinueTap() {
    setState(() {
      totalCaloriesBurn = 0;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MyHomePage()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      padding: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: AppColor.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.pink,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Image.asset("assets/image/trophy.webp"),
          ),
          const SizedBox(height: 40),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                Text(
                  "Congratulations!",
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: AppColor.textwhite,
                  ),
                ),
                const SizedBox(height: 10),
                if (Mode == "dayChallenge")
                  Text(
                    'You have completed the 100 $ExerciseName in 30 Days Challenge. Your total calories burned: $totalCaloriesBurn.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColor.textwhite),
                  )
                else if (Mode == "Arcade")
                  Text(
                    "You have completed the arcade exercise. Your total calories burned: $totalCaloriesBurn.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColor.textwhite),
                  )
                else if (Mode == "postureCorrection")
                  Text(
                    "You have Completed the Pose Estimation Exercise.Your calories burned: ${totalCaloriesBurn.toStringAsFixed(2)}.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColor.textwhite),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 50),
          GestureDetector(
            onTap: onFinishTap,
            child: Container(
              height: 60,
              width: 220,
              decoration: BoxDecoration(
                color: AppColor.bottonPrimary,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(
                child: Text("Finish", style: TextStyle(color: Colors.white)),
              ),
            ),
          ),
          smallGap,
          if (Mode == "dayChallenge")
            GestureDetector(
              onTap: onContinueTap,
              child: Container(
                height: 60,
                width: 220,
                decoration: BoxDecoration(
                  color: AppColor.bottonPrimary,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Text(
                    "Continue",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ),
          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
