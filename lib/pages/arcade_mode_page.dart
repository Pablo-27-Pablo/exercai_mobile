import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:exercai_mobile/pages/Main_Pages/daysChallenge.dart';
import 'package:exercai_mobile/pages/Main_Pages/resttime.dart';
import 'package:exercai_mobile/utils/music_background.dart';
import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import 'package:exercai_mobile/main.dart';
import '../../utils/constant.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  List<String> selectedInjuries = [];
  bool hasInjury = false;

  @override
  void initState() {
    super.initState();
    musicPlayer.stop();
    _loadSelectedInjuries();
  }

  Future<void> _loadSelectedInjuries() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedInjuries = prefs.getStringList('selectedInjuries') ?? [];
    });
    print(selectedInjuries);
  }

  CheckInjurys() {
    for (var exerciseInjury in exercises) {
      if (exerciseInjury["name"] == ExerciseName) {
        // print(exerciseInjury["name"]);
        // print(ExerciseName);
        List<String> bodyparts = exerciseInjury["bodyparts"]?.split(", ") ?? [];
        // print(bodyparts);
        // print(selectedInjuries.toString());
        String bodypartString = selectedInjuries.join(", ");
        //print(bodypartString);
        for (var injury in bodyparts) {
          //print(injury);
          if (injury == bodypartString) {
            hasInjury = true;
            print("have");
            //print(injury.toString());
            //print(selectedInjuries.toString());
            break;
          } else {
            hasInjury = false;
          }
          // print(selectedInjuries);
        }
        break;
      }
    }

    if (hasInjury) {
      print("Injury detected in $ExerciseName!");
      _showInjuryDialog();
    } else {
      _instructionShowDialog(
        instructionsList.firstWhere(
          (exercise) => exercise["image"] == ExerciseName,
        ),
      );
    }

    // if (hasInjury) {
    //   print("Injury detected in $ExerciseName!");
    // } else {
    //   print("no Injury detected in $ExerciseName!");
    // }
  }

  void startExercise(String exerciseName, String imageName, String Name) {
    Mode = "dayChallenge";

    setState(() {
      ExerciseName = exerciseName;
      image = ExerciseName + ".gif";
      PrimaryExerciseName = Name;
    });
    CheckInjurys();

    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => ThirtyDaysChallenge()),
    // );
  }

  List<Map<String, dynamic>> instructionsList = [
    {
      "image": "pushup",
      "steps": [
        "Get into the Starting Position",
        "Lower Your Body",
        "Push Back Up",
      ],
      "instructions": [
        " - Place your hands shoulder-width apart on the floor\n - Extend your legs straight back with your toes on the ground\n - Keep your body in a straight line from head to heels (engage your core)\n - Your hands should be directly under your shoulders",
        " - Bend your elbows and lower your chest toward the floor.\n - Keep your elbows at about a 45-degree angle from your body (not flared out too wide).\n - Lower yourself until your chest is just above the ground.",
        " - Press through your palms and straighten your arms\n - Keep your core engaged and body in a straight line\n - Fully extend your arms without locking your elbows.",
      ],
    },
    {
      "image": "squat",
      "steps": [
        "Stand with Feet Shoulder-Width Apart",
        "Lower Your Body",
        "Push Back Up",
      ],
      "instructions": [
        " - Keep your chest up and back straight\n - Engage your core",
        " - Push your hips back and bend your knees\n - Keep your knees aligned with your toes\n - Lower yourself until your thighs are parallel to the ground",
        " - Drive through your heels to stand back up\n - Keep your core engaged and back straight",
      ],
    },
    {
      "image": "legraises",
      "steps": ["Lie Flat on Your Back", "Lift Your Legs", "Lower Your Legs"],
      "instructions": [
        " - Place your hands under your hips for support\n - Keep your legs straight and together",
        " - Raise your legs towards the ceiling while keeping them straight\n - Engage your core and avoid arching your back",
        " - Slowly lower them back down without touching the ground\n - Repeat while maintaining control",
      ],
    },
    {
      "image": "situp",
      "steps": [
        "Lie on Your Back",
        "Perform the Sit-Up",
        "Lower Yourself Back Down",
      ],
      "instructions": [
        " - Bend your knees and place your feet flat on the ground\n - Cross your arms over your chest or place hands behind your head",
        " - Engage your core and lift your upper body toward your knees\n - Keep your feet planted on the ground",
        " - Lower yourself back down with control",
      ],
    },
    {
      "image": "mountainclimbers",
      "steps": [
        "Get into a Plank Position",
        "Start the Movement",
        "Continue at a Steady Pace",
      ],
      "instructions": [
        " - Hands directly under shoulders\n - Keep your body in a straight line",
        " - Bring one knee toward your chest\n - Quickly switch legs in a running motion",
        " - Keep your core engaged and move at a steady pace",
      ],
    },
    {
      "image": "highknee",
      "steps": ["Stand Tall", "Start the Movement", "Move at a Quick Pace"],
      "instructions": [
        " - Feet hip-width apart\n - Keep your core engaged",
        " - Drive one knee toward your chest\n - Quickly switch legs, bringing the opposite knee up",
        " - Move at a quick pace like running in place",
      ],
    },
    {
      "image": "lunges",
      "steps": ["Stand with Feet Together", "Step Forward", "Push Back Up"],
      "instructions": [
        " - Keep your upper body straight",
        " - Lower your hips until both knees are bent at 90 degrees\n - Keep your front knee above your ankle",
        " - Drive through your front heel to return to starting position\n - Switch legs and repeat",
      ],
    },
    {
      "image": "plank",
      "steps": [
        "Get into a Forearm Plank Position",
        "Hold the Position",
        "Maintain Stability",
      ],
      "instructions": [
        " - Place elbows directly under shoulders",
        " - Keep your body in a straight line",
        " - Engage your core and hold the position",
      ],
    },
    {
      "image": "rightplank",
      "steps": [
        "Lie on Your Right Side",
        "Lift Your Hips",
        "Hold the Position",
      ],
      "instructions": [
        " - Stack your legs on top of each other\n - Place your right elbow under your shoulder",
        " - Lift your hips off the ground",
        " - Keep your body in a straight line and hold",
      ],
    },
    {
      "image": "leftplank",
      "steps": ["Lie on Your Left Side", "Lift Your Hips", "Hold the Position"],
      "instructions": [
        " - Stack your legs on top of each other\n - Place your left elbow under your shoulder",
        " - Lift your hips off the ground",
        " - Keep your body in a straight line and hold",
      ],
    },
    {
      "image": "jumpingjacks",
      "steps": [
        "Start Standing",
        "Perform the Movement",
        "Repeat at a Steady Pace",
      ],
      "instructions": [
        " - Feet together, arms at your sides",
        " - Jump while spreading your legs and raising your arms overhead",
        " - Jump again to return to the starting position",
      ],
    },
  ];

  int number = 1;
  final List<Map<String, dynamic>> exercises7 = [
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

  void _instructionShowDialog(Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              Text("Exercise: "),
              Text("${exercise["image"]}",style: TextStyle(color: AppColor.primary),),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < exercise["steps"].length; i++) ...[
                Text(
                  "Step ${i + 1}: ${exercise["steps"][i]}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(exercise["instructions"][i]),
                SizedBox(height: 8), // Spacing between steps
              ],
              Divider(), // Separator
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ThirtyDaysChallenge(),
                  ),
                );
              },
              child: Text("Continue"),
            ),
          ],
        );
      },
    );
  }

  void _showInjuryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Warning: Injury Detected!"),
          content: Text(
            "This exercise may affect your injury. Proceed with caution or choose another exercise.",
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                if (Mode == "Arcade") {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => RestimeTutorial()),
                  );
                } else {
                  _instructionShowDialog(
                    instructionsList.firstWhere(
                      (exercise) => exercise["image"] == ExerciseName,
                    ),
                  );
                }
              },
              child: Text("Proceed Anyway"),
            ),
          ],
        );
      },
    );
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
                itemCount: exercises7.length,
                itemWidth: MediaQuery.of(context).size.width * 0.8,
                layout: SwiperLayout.TINDER,
                itemHeight: 390,
                itemBuilder: (context, index) {
                  number = index;
                  return GestureDetector(
                    onTap: () => _onExerciseTap(index),
                    child: planCard(
                      exercises7[index]["name"]!,
                      exercises7[index]["image"]!,
                      exercises7[index]["definition"]!,
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
                  if ("Arcade" == exercises7[number - 1]['name']) {
                    Mode = "Arcade";
                    print(selectedInjuries);
                    if (selectedInjuries == []) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RestimeTutorial(),
                        ),
                      );
                    } else {
                      _showInjuryDialog();
                    }
                  } else {
                    startExercise(
                      exercises7[number - 1]["PrimaryName"]!,
                      exercises7[number - 1]["image"]!,
                      exercises7[number - 1]["name"]!,
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
