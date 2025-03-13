import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:exercai_mobile/pages/repsCounter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:exercai_mobile/pages/home.dart';
import 'package:exercai_mobile/pages/realtime_2.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/utils/constant.dart';
import '../../utils/constant.dart';

import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:exercai_mobile/pages/repsCounter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:exercai_mobile/pages/home.dart';
import 'package:exercai_mobile/pages/realtime_2.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/utils/constant.dart';
import '../../utils/constant.dart';


class Trypage extends StatefulWidget {
  const Trypage({super.key});

  @override
  State<Trypage> createState() => _TrypageState();
}

class _TrypageState extends State<Trypage> {
  FlutterTts _flutterTts = FlutterTts();

  final List<Map<String, String>> exercises = [
    {"name": "squat", "image": "squat.gif", "PrimaryName": "Squat"},
    {"name": "pushup", "image": "pushup.gif", "PrimaryName": "Push-Up"},
    {
      "name": "jumpingjacks",
      "image": "jumpingjacks.gif",
      "PrimaryName": "Jumping Jacks",
    },
    {
      "name": "legraises",
      "image": "legraises.gif",
      "PrimaryName": "Leg Raises",
    },
    {"name": "situp", "image": "situp.gif", "PrimaryName": "Sit-Up"},
    {"name": "lunges", "image": "lunges.gif", "PrimaryName": "Lunges"},
    {"name": "plank", "image": "plank.jpg", "PrimaryName": "Plank"},
    {
      "name": "rightplank",
      "image": "sideplank.gif",
      "PrimaryName": "Right Plank",
    },
    {
      "name": "leftplank",
      "image": "sideplank.gif",
      "PrimaryName": "Left Plank",
    },
    {
      "name": "mountainclimbers",
      "image": "mountainclimbers.gif",
      "PrimaryName": "Mountain Climbers",
    },
        {
      "name": "highknees",
      "image": "highknee.gif",
      "PrimaryName": "High-Knees",
    },
  ];

  void _startExercise(
    String exerciseName,
    String imageName,
    String primaryName,
  ) {
    setState(() {
      ExerciseName = exerciseName;
      PrimaryExerciseName = primaryName;
      image = imageName;
    });
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => AgeSelectorScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // appBar: AppBar(
      //   leading: IconButton(
      //     onPressed: () {
      //       seconds = 60;
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => MainLandingPage()),
      //       );
      //     },
      //     icon: Icon(Icons.arrow_back_ios, color: AppColor.primary),
      //   ),

      // ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30),
              child: IconButton(
                onPressed: () {
                  seconds = 60;
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainLandingPage()),
                  );
                },
                icon: Icon(Icons.arrow_back_ios, color: AppColor.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom:20),
              child: Container(
                padding: EdgeInsets.only(right: 30),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      "Pick an exercise that suits your goal.",textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        
                      ),
                    ),
                    largeGap,
                    Row(
                      children: [
                        Text(
                          "Click exercise to proceed",
                          style: TextStyle(
                            color: AppColor.bottonPrimary,
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            SizedBox(height: 10),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  return GestureDetector(
                    onTap:
                        () => _startExercise(
                          exercise["name"]!,
                          exercise["image"]!,
                          exercise["PrimaryName"]!,
                        ),
                    child: Card(
                      color: Colors.white,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              'assets/image/${exercise["image"]}',
                              height: 70,
                              width: 70,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            exercise["PrimaryName"]!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColor.buttonPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}




























