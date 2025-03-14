import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:exercai_mobile/pages/arcade_mode_page.dart';
import 'package:exercai_mobile/pages/home.dart';
import 'package:exercai_mobile/pages/realtime_2.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/utils/constant.dart';
import '../../utils/constant.dart';

class ThirtyDaysChallenge extends StatefulWidget {
  const ThirtyDaysChallenge({super.key});

  @override
  State<ThirtyDaysChallenge> createState() => _ThirtyDaysChallengeState();
}

class _ThirtyDaysChallengeState extends State<ThirtyDaysChallenge> {
  var peopleBox = Hive.box("Box");
  int days = 0;

  @override
  void initState() {
    super.initState();
    peopleBox = Hive.box("Box");
    days = peopleBox.get(ExerciseName, defaultValue: 0);
  }

  final List<Map<String, dynamic>> exercises = List.generate(
    30,
    (index) => {"day": "Day ${index + 1}", "Counts": (index + 1) * 100},
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // appBar: AppBar(
      //   leading: IconButton(
      //     onPressed: () {
      //       Navigator.pushReplacement(
      //         context,
      //         MaterialPageRoute(builder: (context) => ArcadeModePage()),
      //       );
      //     },
      //     icon: Icon(Icons.arrow_back, color: AppColor.textwhite),
      //   ),
      //   title: Text("", style: TextStyle(color: AppColor.textwhite)),
      //   backgroundColor: Colors.transparent,
      //   centerTitle: true,
      //   elevation: 5.0,
      // ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 35, bottom: 10, left: 20),
            child: IconButton(
              onPressed: () {
                seconds = 60;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => ArcadeModePage()),
                );
              },
              icon: Icon(Icons.arrow_back_ios, color: AppColor.primary),
            ),
          ),
          if (ExerciseName == "squat")
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    image: AssetImage('assets/image/squat.gif'),
                    fit: BoxFit.cover,
                  ),
                ),
                margin: EdgeInsets.all(15),
                height: 250,
                width: 250,
              ),
            )
          else if (ExerciseName == "legraises")
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    image: AssetImage('assets/image/legraises.gif'),
                    fit: BoxFit.cover,
                  ),
                ),
                margin: EdgeInsets.all(15),
                height: 250,
                width: 250,
              ),
            )
          else if (ExerciseName == "pushup")
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    image: AssetImage('assets/image/pushup.gif'),
                    fit: BoxFit.cover,
                  ),
                ),
                margin: EdgeInsets.all(15),
                height: 250,
                width: 250,
              ),
            )
          else if (ExerciseName == "situp")
            Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  image: DecorationImage(
                    image: AssetImage('assets/image/situp.gif'),
                    fit: BoxFit.cover,
                  ),
                ),
                margin: EdgeInsets.all(15),
                height: 250,
                width: 250,
              ),
            ),
         
          // Container(
          //   decoration: BoxDecoration(
          //     borderRadius: BorderRadius.circular(5),
          //     image: DecorationImage(
          //       image: AssetImage('assets/image/poseestimation2.jpg'),
          //       fit: BoxFit.cover,
          //     ),
          //   ),
          //   margin: EdgeInsets.all(15),
          //   height: 170,
          //   width: 400,
          //   child: Center(
          //     child: Text(
          //       '"100 $ExerciseName 30 Days Challenge"',
          //       style: TextStyle(
          //         color: AppColor.yellowtext,
          //         fontWeight: FontWeight.bold,
          //         fontSize: 23,
          //       ),
          //     ),
          //   ),
          // ),
          Center(
            child: Text(
              '"100 $ExerciseName 30 Days Challenge"',
              style: TextStyle(
                color: AppColor.bottonPrimary.withOpacity(0.7),
                fontWeight: FontWeight.bold,
                fontSize: 23,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: ListView.builder(
                itemCount: exercises.length,
                itemBuilder: (context, index) {
                  final exercise = exercises[index];
                  final isCompleted = days >= exercise["Counts"];
                  final isAvailable = days + 100 >= exercise["Counts"];

                  return GestureDetector(
                    onDoubleTap:
                        isAvailable
                            ? () {
                              if (!isCompleted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MyHomePage(),
                                  ),
                                );
                              }
                            }
                            : null,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color:
                            isCompleted
                                ? AppColor.primary.withOpacity(0.7)
                                : Colors.white,
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 3,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            exercise["day"]!,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color:
                                  isCompleted
                                      ? AppColor.textwhite
                                      : AppColor.bottonPrimary.withOpacity(.4),
                            ),
                          ),
                          isAvailable
                              ? IconButton(
                                onPressed: () {
                                  peopleBox.put("counts", 20);
                                  setState(
                                    () => days = peopleBox.get("counts"),
                                  );
                                },
                                icon: Icon(
                                  isCompleted
                                      ? Icons.check_circle
                                      : Icons.fitness_center,
                                  color:
                                      isCompleted
                                          ? const Color.fromARGB(255, 1, 255, 1)
                                          : AppColor.bottonPrimary.withOpacity(
                                            .6,
                                          ),
                                  size: 30,
                                ),
                              )
                              : Icon(
                                Icons.lock,
                                color: AppColor.bottonPrimary.withOpacity(0.4),
                                size: 30,
                              ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
