import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:exercai_mobile/pages/Main_Pages/daysChallenge.dart';
import 'package:exercai_mobile/pages/Main_Pages/resttime.dart';
import 'package:exercai_mobile/utils/music_background.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:exercai_mobile/main.dart';
import '../../utils/constant.dart';

void main() {
  runApp(FitnessApp());
}

class FitnessApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: ArcadeModePage(),
    );
  }
}

class ArcadeModePage extends StatefulWidget {
  @override
  _ArcadeModePageState createState() => _ArcadeModePageState();
}

class _ArcadeModePageState extends State<ArcadeModePage> {
  final musicPlayer = MusicPlayerService();

  @override
  void initState() {
    super.initState();
    musicPlayer.stop();
  }

  void startExercise(String exerciseName, String imageName, String Name) {
    Mode = "dayChallenge";


    setState(() {
      ExerciseName = exerciseName;
      image = ExerciseName+".gif";
      PrimaryExerciseName = Name;
    });

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => ThirtyDaysChallenge()),
    );
  }

  int number = 1;
  final List<Map<String, dynamic>> exercises = [
    {
      "index": 0,
      "name": "Arcade",
      "PrimaryName": "Arcade",
      "image": "assets/image/arcade.gif",
      "definition":
          "Welcome! Follow the on-screen guide and match the pose for a fun and effective workout. Let’s begin!",
    },
    {
      "index": 1,
      "name": "Push Up",
      "PrimaryName": "pushup",
      "image": "assets/image/pushup.gif",
      "definition":
          "100 Push Up exercises for a 30-day challenge! Follow the guide and match the pose.",
    },
    {
      "index": 2,
      "name": "Sit Up",
      "PrimaryName": "situp",
      "image": "assets/image/situp.gif",
      "definition":
          "100 Sit Up exercises for a 30-day challenge! Follow the guide and match the pose.",
    },
    {
      "index": 3,
      "name": "Leg Raises",
      "PrimaryName": "legraises",
      "image": "assets/image/legraises.gif",
      "definition":
          "100 Leg Raises exercises for a 30-day challenge! Follow the guide and match the pose.",
    },
    {
      "index": 4,
      "name": "Squat",
      "PrimaryName": "squat",
      "image": "assets/image/squat.gif",
      "definition":
          "100 Squat exercises for a 30-day challenge! Follow the guide and match the pose.",
    },
  ];

  void _onExerciseTap(int index) {
    print("Selected Exercise: \${exercises[index]['name']}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(right: 20, left: 20, top: 10, bottom: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 30, bottom: 30),
              child: IconButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => MainLandingPage()),
                  );
                },
                icon: Icon(Icons.arrow_back_ios, color: AppColor.primary),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 20),
              child: Container(
                padding: EdgeInsets.only(right: 30),
                child: Text(
                  "Choose your challenge: 30-day workout or Arcade mode!",
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            Text(
              "Swipe to explore more challenges.",
              style: TextStyle(fontSize: 15),
            ),
            Expanded(
              child: Swiper(
                itemCount: exercises.length,
                itemWidth: MediaQuery.of(context).size.width * 0.8,
                layout: SwiperLayout.TINDER,
                itemHeight: 390,
                itemBuilder: (context, index) {
                  number = index;
                  return GestureDetector(
                    onTap: () => _onExerciseTap(index),
                    child: planCard(
                      exercises[index]["name"]!,
                      exercises[index]["image"]!,
                      exercises[index]["definition"]!,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (number == 0) {
                    number = 5;
                  }
                  if ("Arcade" == exercises[number - 1]['name']) {
                    Mode = "Arcade";
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => RestimeTutorial(),
                      ),
                    );
                  } else {
                    startExercise(
                      exercises[number - 1]["PrimaryName"]!,
                      exercises[number - 1]["image"]!,
                      exercises[number - 1]["name"]!,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      14,
                    ), // Set border radius here
                  ),
                  backgroundColor: AppColor.primary,
                  padding: EdgeInsets.symmetric(vertical: 15),
                ),
                child: Text(
                  "Next",
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget planCard(String title, String imagePath, String definition) {
    return Container(
      width: 250,
      height: 250,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 10, spreadRadius: 6),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
            child: Image.asset(
              imagePath,
              height: 250,
              width: 250,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Padding(
              padding: const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: AppColor.solidtext.withOpacity(0.7),
                    ),
                  ),
                  smallGap,
                  Text(
                    definition,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColor.backgroundgrey.withOpacity(0.7),
                    ),
                    textAlign: TextAlign.center,
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
