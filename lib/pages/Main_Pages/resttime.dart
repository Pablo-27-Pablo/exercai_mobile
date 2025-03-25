import 'dart:async';

import 'package:exercai_mobile/utils/music_background.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/pages/arcade_mode_page.dart';
import 'package:exercai_mobile/pages/realtime_2.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/utils/constant.dart';
import '../../utils/constant.dart';

Timer? timer;

class RestimeTutorial extends StatefulWidget {
  const RestimeTutorial({super.key});

  @override
  State<RestimeTutorial> createState() => _RestimeTutorialState();
}

class _RestimeTutorialState extends State<RestimeTutorial> {
  String exerciseImage = "";
  String instructionExercise = "";
  String instructionExercise2 = "";
  String instructionExercise3 = "";
  String instruction = "";
  String instruction2 = "";
  String instruction3 = "";
  String name = "";
  final musicPlayer = MusicPlayerService();

  @override
  void initState() {
    super.initState();
    startTimer();
    ExerciseImage();
    peopleBox.get("musicOnOf", defaultValue: true)
        ? musicPlayer.play()
        : Container();
  }

  calculation() {
    double total = (seconds2 / 20) * 100;
    total = total / 100;
    return total;
  }

  void ArcadePlay() {
    if (1 == arcadeNumber) {
      setState(() {
        PrimaryExerciseName = "Push-Up";
        ExerciseName = "pushup";
        image = "pushup.gif";
      });
    }
    if (2 == arcadeNumber) {
      setState(() {
        PrimaryExerciseName = "Squat";
        ExerciseName = "squat";
        image = "squat.gif";
      });
    }
    if (3 == arcadeNumber) {
      setState(() {
        PrimaryExerciseName = "Leg Raises";
        ExerciseName = "legraises";
        image = "legraises.gif";
      });
    }
    if (4 == arcadeNumber) {
      setState(() {
        PrimaryExerciseName = "Sit-Up";
        ExerciseName = "situp";
        image = "situp.gif";
      });
    }
    if (5 == arcadeNumber) {
      setState(() {
        PrimaryExerciseName = "Mountain Climbers";
        ExerciseName = "mountainclimbers";
        image = "mountainclimbers.gif";
      });
    }
    if (6 == arcadeNumber) {
      setState(() {
        PrimaryExerciseName = "High Knee";
        ExerciseName = "highknee";
        image = "highknee.gif";
      });
    }
    if (7 == arcadeNumber) {
      setState(() {
        PrimaryExerciseName = "Lunges";
        ExerciseName = "lunges";
        image = "lunges.gif";
      });
    }
    if (8 == arcadeNumber) {
      setState(() {
        PrimaryExerciseName = "Plank";
        ExerciseName = "plank";
        image = "plank.jpg";
      });
    }
    if (9 == arcadeNumber) {
      setState(() {
        PrimaryExerciseName = "Right Plank";
        ExerciseName = "rightplank";
        image = "rightplank.png";
      });
    }
    if (10 == arcadeNumber) {
      setState(() {
        PrimaryExerciseName = "Left Plank";
        ExerciseName = "leftplank";
        image = "leftplank.png";
      });
    }
    if (11 == arcadeNumber) {
      setState(() {
        PrimaryExerciseName = "Jumping Jacks";
        ExerciseName = "jumpingjacks";
        image = "jumpingjacks.gif";
      });
    }

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MyHomePage()),
    );
  }

  ExerciseImage() {
    if (1 == arcadeNumber) {
      name = "pushup";
      exerciseImage = "pushup.gif";
      instructionExercise = "Push-Up: Get into the Starting Position";
      instructionExercise2 = "Lower Your Body";
      instructionExercise3 = "Push Back Up";
      instruction =
          " - Place your hands shoulder-width apart on the floor\n - Extend your legs straight back with your toes on the ground\n - Keep your body in a straight line from head to heels (engage your core)\n - Your hands should be directly under your shoulders ";
      instruction2 =
          " - Bend your elbows and lower your chest toward the floor.\n - Keep your elbows at about a 45-degree angle from your body (not flared out too wide).\n - Lower yourself until your chest is just above the ground.";
      instruction3 =
          " - Press through your palms and straighten your arms\n - Keep your core engaged and body in a straight line\n - Fully extend your arms without locking your elbows.";
    }
    if (2 == arcadeNumber) {
      name = "squat";
      exerciseImage = "squat.gif";
      instructionExercise = "Squat: Stand with Feet Shoulder-Width Apart";
      instructionExercise2 = "Lower Your Body";
      instructionExercise3 = "Push Back Up";
      instruction =
          " - Keep your chest up and back straight\n - Engage your core";
      instruction2 =
          " - Push your hips back and bend your knees\n - Keep your knees aligned with your toes\n - Lower yourself until your thighs are parallel to the ground";
      instruction3 =
          " - Drive through your heels to stand back up\n - Keep your core engaged and back straight";
    }
    if (3 == arcadeNumber) {
      name = "legraises";
      exerciseImage = "legraises.gif";
      instructionExercise = "Leg Raises: Lie Flat on Your Back";
      instructionExercise2 = "Lift Your Legs";
      instructionExercise3 = "Lower Your Legs";
      instruction =
          " - Place your hands under your hips for support\n - Keep your legs straight and together";
      instruction2 =
          " - Raise your legs towards the ceiling while keeping them straight\n - Engage your core and avoid arching your back";
      instruction3 =
          " - Slowly lower them back down without touching the ground\n - Repeat while maintaining control";
    }
    if (4 == arcadeNumber) {
      name = "situp";
      exerciseImage = "situp.gif";
      instructionExercise = "Sit-Up: Lie on Your Back";
      instructionExercise2 = "Perform the Sit-Up";
      instructionExercise3 = "Lower Yourself Back Down";
      instruction =
          " - Bend your knees and place your feet flat on the ground\n - Cross your arms over your chest or place hands behind your head";
      instruction2 =
          " - Engage your core and lift your upper body toward your knees\n - Keep your feet planted on the ground";
      instruction3 = " - Lower yourself back down with control";
    }
    if (5 == arcadeNumber) {
      name = "mountainclimbers";
      exerciseImage = "mountainclimbers.gif";
      instructionExercise = "Mountain Climbers: Get into a Plank Position";
      instructionExercise2 = "Start the Movement";
      instructionExercise3 = "Continue at a Steady Pace";
      instruction =
          " - Hands directly under shoulders\n - Keep your body in a straight line";
      instruction2 =
          " - Bring one knee toward your chest\n - Quickly switch legs in a running motion";
      instruction3 = " - Keep your core engaged and move at a steady pace";
    }
    if (6 == arcadeNumber) {
      name = "highknee";
      exerciseImage = "highknee.gif";
      instructionExercise = "High Knees: Stand Tall";
      instructionExercise2 = "Start the Movement";
      instructionExercise3 = "Move at a Quick Pace";
      instruction = " - Feet hip-width apart\n - Keep your core engaged";
      instruction2 =
          " - Drive one knee toward your chest\n - Quickly switch legs, bringing the opposite knee up";
      instruction3 = " - Move at a quick pace like running in place";
    }
    if (7 == arcadeNumber) {
      name = "lunges";
      exerciseImage = "lunges.gif";
      instructionExercise = "Lunges: Stand with Feet Together";
      instructionExercise2 = "Step Forward";
      instructionExercise3 = "Push Back Up";
      instruction = " - Keep your upper body straight";
      instruction2 =
          " - Lower your hips until both knees are bent at 90 degrees\n - Keep your front knee above your ankle";
      instruction3 =
          " - Drive through your front heel to return to starting position\n - Switch legs and repeat";
    }
    if (8 == arcadeNumber) {
      name = "plank";
      exerciseImage = "plank.jpg";
      instructionExercise = "Plank: Get into a Forearm Plank Position";
      instructionExercise2 = "Hold the Position";
      instructionExercise3 = "Maintain Good Form";
      instruction =
          " - Elbows directly under shoulders\n - Keep your body in a straight line";
      instruction2 = " - Engage your core and hold the position";
      instruction3 = " - Avoid arching your back or dropping your hips";
    }
    if (9 == arcadeNumber) {
      name = "rightplank";
      exerciseImage = "rightplank.png";
      instructionExercise = "Right Side Plank: Lie on Your Right Side";
      instructionExercise2 = "Lift Your Body";
      instructionExercise3 = "Hold the Position";
      instruction =
          " - Stack your feet and keep your elbow directly under your shoulder";
      instruction2 = " - Engage your core and lift your hips off the ground";
      instruction3 = " - Maintain a straight line from head to heels";
    }
    if (10 == arcadeNumber) {
      name = "leftplank";
      exerciseImage = "leftplank.png";
      instructionExercise = "Left Side Plank: Lie on Your Left Side";
      instructionExercise2 = "Lift Your Body";
      instructionExercise3 = "Hold the Position";
      instruction =
          " - Stack your feet and keep your elbow directly under your shoulder";
      instruction2 = " - Engage your core and lift your hips off the ground";
      instruction3 = " - Maintain a straight line from head to heels";
    }
    if (11 == arcadeNumber) {
      name = "jumpingjacks";
      exerciseImage = "jumpingjacks.gif";
      instructionExercise = "Jumping Jacks: Stand with Feet Together";
      instructionExercise2 = "Start the Movement";
      instructionExercise3 = "Return to Starting Position";
      instruction =
          " - Stand upright with your feet together and arms at your sides";
      instruction2 =
          " - Jump up while spreading your legs shoulder-width apart and raising your arms overhead";
      instruction3 =
          " - Quickly return to the starting position by jumping back and lowering your arms";
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) {
      if (seconds2 > 0) {
        setState(() {
          seconds2--;
        });
      } else {
        timer?.cancel();
        seconds2 = 20;
        seconds = 30;
        ArcadePlay();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                right: 16.0,
                left: 12.0,
                bottom: 16.0,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          arcadeNumber = 1;
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ArcadeModePage(),
                            ),
                          );
                          seconds2 = 20;
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          color: AppColor.primary,
                        ),
                      ),
                      Text(
                        name,
                        style: TextStyle(
                          color: AppColor.bottonPrimary.withOpacity(0.7),
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5),
                  Text(
                    "Mucsle Gain · Cardio · Physique",
                    style: TextStyle(
                      color: AppColor.bottonPrimary.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                children: [
                  Text(
                    seconds2.toString(),
                    style: TextStyle(
                      color: AppColor.bottonPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 55,
                    ),
                  ),
                  Text(
                    "Break Time",
                    style: TextStyle(
                      color: AppColor.bottonPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: CircularPercentIndicator(
                radius: 150,
                lineWidth: 10,
                percent: calculation(),
                progressColor: AppColor.primary,
                backgroundColor: AppColor.primary.withOpacity(0.3),
                circularStrokeCap: CircularStrokeCap.round,
                center: ClipOval(
                  child: Container(
                    height: 275,
                    child: Image.asset("assets/image/" + exerciseImage),
                  ),
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                "Instruction: ",
                style: TextStyle(
                  color: AppColor.bottonPrimary.withOpacity(0.6),
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: Container(
                padding: EdgeInsets.only(top: 10),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ListView(
                  padding: EdgeInsets.all(16),
                  children: [
                    Text(
                      instructionExercise + ":",
                      style: TextStyle(
                        color: AppColor.primary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    smallGap,
                    Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        instruction,
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 150, 150, 150),
                        ),
                      ),
                    ),
                    smallGap,
                    smallGap,
                    instructionExercise2 == ""
                        ? Container()
                        : Text(
                          instructionExercise2 + ":",
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    smallGap,
                    instruction2 == ""
                        ? Container()
                        : Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            instruction,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 150, 150, 150),
                            ),
                          ),
                        ),
                    smallGap,
                    smallGap,
                    instructionExercise3 == ""
                        ? Container()
                        : Text(
                          instructionExercise3 + ":",
                          style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                    smallGap,
                    instruction3 == ""
                        ? Container()
                        : Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            instruction3,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 150, 150, 150),
                            ),
                          ),
                        ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
