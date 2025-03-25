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
import 'package:shared_preferences/shared_preferences.dart';

class Trypage extends StatefulWidget {
  const Trypage({super.key});

  @override
  State<Trypage> createState() => _TrypageState();
}

class _TrypageState extends State<Trypage> {
  String bodypartString = "";
  FlutterTts _flutterTts = FlutterTts();
  List<String> selectedInjuries = [];
  bool hasInjury = false;

List<Map<String, dynamic>> instructionsList = [
    {
      "name2": "pushup.gif",
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
      "name2": "squat.gif",
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
      "name2": "legraises.gif",
      "image": "legraises",
      "steps": ["Lie Flat on Your Back", "Lift Your Legs", "Lower Your Legs"],
      "instructions": [
        " - Place your hands under your hips for support\n - Keep your legs straight and together",
        " - Raise your legs towards the ceiling while keeping them straight\n - Engage your core and avoid arching your back",
        " - Slowly lower them back down without touching the ground\n - Repeat while maintaining control",
      ],
    },
    {
      "name2": "situp.gif",
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
      "name2": "mountainclimbers.gif",
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
      "name2": "highknee.gif",
      "image": "highknee",
      "steps": ["Stand Tall", "Start the Movement", "Move at a Quick Pace"],
      "instructions": [
        " - Feet hip-width apart\n - Keep your core engaged",
        " - Drive one knee toward your chest\n - Quickly switch legs, bringing the opposite knee up",
        " - Move at a quick pace like running in place",
      ],
    },
    {
      "name2": "lunges.gif",
      "image": "lunges",
      "steps": ["Stand with Feet Together", "Step Forward", "Push Back Up"],
      "instructions": [
        " - Keep your upper body straight",
        " - Lower your hips until both knees are bent at 90 degrees\n - Keep your front knee above your ankle",
        " - Drive through your front heel to return to starting position\n - Switch legs and repeat",
      ],
    },
    {
      "name2": "plank.jpg",
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
      "name2": "rightplank.png",
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
      "name2": "leftplank.png",
      "image": "leftplank",
      "steps": ["Lie on Your Left Side", "Lift Your Hips", "Hold the Position"],
      "instructions": [
        " - Stack your legs on top of each other\n - Place your left elbow under your shoulder",
        " - Lift your hips off the ground",
        " - Keep your body in a straight line and hold",
      ],
    },
    {
      "name2": "jumpingjacks.gif",
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

  void _instructionShowDialog(Map<String, dynamic> exercise) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Column(
            children: [
              
              Row(
                children: [
                  Text("Exercise: "),
                  Text(
                    "${exercise["image"]}",
                    style: TextStyle(color: AppColor.primary),
                  ),
                ],
              ),
              Row(children: [
                Row(
                  children: [
                    Text("Camera "),
                    Text(
                    "Position: ",
                    style: TextStyle(color: AppColor.primary),
                  ),
                  ],
                  
                ),
                Image.asset("assets/image/${exercise["name2"]}",width: 70,)
              ],),
              Divider()
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (int i = 0; i < exercise["steps"].length; i++) ...[
                Text(
                  "Step ${i + 1}: ${exercise["steps"][i]}",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                Text(exercise["instructions"][i]),
                SizedBox(height: 18), // Spacing between steps
              ],
              // Separator
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: Text("Cancel"),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(16),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AgeSelectorScreen(),
                    ),
                  );
                },
                child: Text("Continue", style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _loadSelectedInjuries() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedInjuries = prefs.getStringList('selectedInjuries') ?? [];
    });
    bodypartString = selectedInjuries.join(", ");
  }

  final List<Map<String, String>> exercises0 = [
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
      "image": "rightplank.png",
      "PrimaryName": "Right Plank",
    },
    {
      "name": "leftplank",
      "image": "leftplank.png",
      "PrimaryName": "Left Plank",
    },
    {
      "name": "mountainclimbers",
      "image": "mountainclimbers.gif",
      "PrimaryName": "Mountain Climbers",
    },
    {"name": "highknee", "image": "highknee.gif", "PrimaryName": "High-Knees"},
  ];
  void _showInjuryDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text("Injury Detected!"),
          content: Container(
            child: Text(
              "This exercise may affect your injury (e.g., ${bodypartString}). Proceed with caution or choose another exercise.",
              style: TextStyle(fontSize: 15),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context), // Close dialog
              child: Text("Cancel", style: TextStyle(color: AppColor.primary)),
            ),
            Container(
              decoration: BoxDecoration(
                color: AppColor.primary,
                borderRadius: BorderRadius.circular(16),
              ),

              child: TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  _instructionShowDialog(
                    instructionsList.firstWhere(
                      (exercise) => exercise["image"] == ExerciseName,
                    ),
                  );
                },
                child: Text(
                  "Proceed anyway",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  CheckInjurys() {
    for (var exerciseInjury in exercises) {
      if (exerciseInjury["name"] == ExerciseName) {
        // print(exerciseInjury["name"]);
        print(ExerciseName);
        List<String> bodyparts = exerciseInjury["bodyparts"]?.split(", ") ?? [];
        // print(bodyparts);
        // print(selectedInjuries.toString());
        bodypartString = selectedInjuries.join(", ");
        print(bodypartString);
        outerLoop:
        for (var injury in bodyparts) {
          for (var databaseInjury in selectedInjuries) {
            if (injury == databaseInjury) {
              print(injury + " == " + databaseInjury);
              hasInjury = true;
              print("have");
              //print(injury.toString());
              //print(selectedInjuries.toString());
              break outerLoop;
            } else {
              hasInjury = false;
            }
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

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadSelectedInjuries();
    _loadUserWeight();
  }

  void _loadUserWeight() async {
    double weight2 = await getUserWeight();
    setState(() {
      weight = weight2;
    });
    print(weight);
  }

  Future<double> getUserWeight() async {
    final prefs = await SharedPreferences.getInstance();
    String savedWeightStr = prefs.getString('weight') ?? "";
    return savedWeightStr.isNotEmpty
        ? double.tryParse(savedWeightStr) ?? 70.0
        : 70.0;
  }

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
    CheckInjurys();
    // Navigator.pushReplacement(
    //   context,
    //   MaterialPageRoute(builder: (context) => AgeSelectorScreen()),
    // );
  }

  @override
  Widget build(BuildContext context) {
    //Dinagdag ng Popscope
    return PopScope(
      canPop: false,
      child: Scaffold(
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
                padding: const EdgeInsets.only(top: 10, bottom: 20),
                child: Container(
                  padding: EdgeInsets.only(right: 30),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Text(
                        "Pick an exercise that suits your goal.",
                        textAlign: TextAlign.start,
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
                  itemCount: exercises0.length,
                  itemBuilder: (context, index) {
                    final exercise = exercises0[index];
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
                              side: BorderSide(color: AppColor.primary, width: 0.1),
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
      ),
    );
  }
}
