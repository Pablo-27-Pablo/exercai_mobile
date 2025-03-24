import 'dart:math';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:exercai_mobile/utils/music_background.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'package:hive_flutter/hive_flutter.dart';

import '../pages/Awarding_Page.dart';

final musicPlayer2 = MusicPlayerService();

FlutterTts _flutterTts = FlutterTts();
speak(text) async {
  _flutterTts.setLanguage("en-US");
  _flutterTts.setPitch(1.5);
  await _flutterTts.setVoice({
    "name": "en-us-x-sfg#female_1-local",
    "locale": "en-US",
  });
  await _flutterTts.speak(text);
}

Formula() {
  for (int i = 0; i < exercises.length; i++) {
    if (exercises[i]["name"] == ExerciseName) {
      print("Exercise found: ${exercises[i]}");
      double formula =
          (((exercises[i]["MET"]).toDouble() * weight * raise.toDouble()) /
              1000);
      totalCaloriesBurn = totalCaloriesBurn + formula;
      totalCaloriesBurnDatabase =
          (peopleBox.get("finalcoloriesburn", defaultValue: 0)).toDouble();
      double daysDatabase =
          (peopleBox.get("daychallenge", defaultValue: 0)).toDouble();
      double totaldayschallenge = daysDatabase + totalCaloriesBurn;
      double total = totalCaloriesBurn + totalCaloriesBurnDatabase;
      peopleBox.put("finalcoloriesburn", total);
      peopleBox.put("daychallenge", totaldayschallenge);

      print(peopleBox.get("finalcoloriesburn"));

      print(
        "         $ExerciseName                " + totalCaloriesBurn.toString(),
      );
      print("                         " + totalCaloriesBurn.toString());
      print("                         " + totalCaloriesBurn.toString());
      print("                         " + totalCaloriesBurn.toString());
      print("                         " + totalCaloriesBurn.toString());
    }
  }
}

// Function to detect squat exercise movements
void squatExercise(
  BuildContext context,
  leftHip,
  leftKnee,
  leftAnkle,
  averageShoulder,
  averageHips,
  averageShoulderY,
  averageHipsY,
  rightKneeY,
  leftKneeY,
  rightAnkleY,
  leftAnkleY,
  leftHipsX,
  rightHipsX,
  leftShoulderX,
  rightShoulderX,
  averageKneeY,
  rightKneeX,
  leftKneeX,
) {
  double kneeAngle = calculateKneeAngle(leftHip, leftKnee, leftAnkle);
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  // Ensure proper posture

  if ((averageShoulderY + 20 < averageHipsY && leftAnkle.y > averageHips) &&
      (rightKneeY + 10 < rightAnkleY && leftKneeY + 10 < leftAnkleY)) {
    // print(leftAnkle.y);
    if (kneeAngle < 50) {
      if (currentTime - lastUpdateTime3 >= 2000) {
        warningIndicatorTextExercise = "Too low";
        speak(warningIndicatorTextExercise);
        warningIndicatorScreen = false;
      }
    }

    if (leftHipsX >= leftKneeX + 30 ||
        leftHipsX <= leftKneeX - 30 ||
        rightHipsX >= rightKneeX + 30 ||
        rightHipsX <= rightKneeX - 30) {
    } else {
      StandStraight(averageShoulder, averageHips);
    }

    // Detect "down" position
    if (kneeAngle < 140 && !staticIsDown) {
      warningIndicatorScreen = true;
      // warningIndicatorText = "";
      // warningIndicatorTextExercise = "";
      if (!staticIsDown) {
        staticIsDown = true;
        staticIsUp = false;
        print("Squat: Down position detected");
      }
    }

    // Detect "up" position
    if (kneeAngle > 150 && !staticIsUp) {
      // print("body not alignalign");
      warningIndicatorTextExercise = "";
      if (staticIsDown && !staticIsUp) {
        staticIsUp = true;
        staticIsDown = false;
        if (Mode == "dayChallenge") {
          days = peopleBox.get(ExerciseName, defaultValue: 0);
          print(ExerciseName);
          int TotalCount = 1 + days;

          if (TotalCount % 100 == 0 &&
              TotalCount >= 100 &&
              TotalCount <= 3000) {
            Formula();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CongratsApp()),
            );
          }
          peopleBox.put(ExerciseName, TotalCount);
          checkRepetitionSpeed();
          raise = peopleBox.get(ExerciseName) % 100;
          //speak(raise);
        } else {
          checkRepetitionSpeed();
          raise++;
          //String repsCount = raise.toString();
          //speak(repsCount);
        }
        print("Squat count: $raise");
      }
    }
  }
}

void pushupExercise(
  BuildContext context,
  avgWristY,
  avgShoulderY,
  avgElbowY,
  averageHipsY,
  averageKneeY,
  averageAnkleY,
) {
  if (avgWristY + 30 > averageAnkleY) {
    // Detect "down" position (elbows near shoulders)
    if (avgElbowY < avgShoulderY + 30 && avgWristY > avgShoulderY) {
      print(
        "Down position detected: Shoulder: $avgShoulderY Elbow: $avgElbowY  Hips: " +
            averageHipsY.toString(),
      );
      print("                     ");

      if (!staticIsDown) {
        staticIsDown = true;
        staticIsUp = false;
        warningIndicatorScreen = true;
        warningIndicatorTextExercise = "";
      }
    }
    pushupError(
      averageHipsY,
      avgShoulderY,
      avgWristY,
      averageKneeY,
      averageAnkleY,
    );

    // Detect "up" position (wrists and elbows higher than shoulders)
    if (avgWristY > avgShoulderY &&
        avgElbowY < avgWristY &&
        avgShoulderY < avgElbowY - 45 &&
        !staticIsUp) {
      print("up");
      warningIndicatorScreen = true;
      warningIndicatorTextExercise = "";

      if (staticIsDown && !staticIsUp) {
        staticIsUp = true;
        staticIsDown = false;
        print(staticIsUp);

        if (Mode == "dayChallenge") {
          days = peopleBox.get(ExerciseName, defaultValue: 0);
          print(ExerciseName);
          int TotalCount = 1 + days;
          if (TotalCount % 100 == 0 &&
              TotalCount >= 100 &&
              TotalCount <= 3000) {
            Formula();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CongratsApp()),
            );
          }
          peopleBox.put(ExerciseName, TotalCount);
          checkRepetitionSpeed();
          raise = peopleBox.get(ExerciseName) % 100;
        } else {
          checkRepetitionSpeed();
          raise++;
        }
        print("Push-up count: $raise");
      }
    }
  }
}

pushupError(
  averageHipsY,
  avgShoulderY,
  avgWristY,
  averageKneeY,
  averageAnkleY,
) {
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  print(" Hips ${averageHipsY}  >  Shoulder ${avgShoulderY + 20}");
  if (averageHipsY < avgShoulderY - 20  && (avgShoulderY < avgWristY - 100)) {
    // Hips are too low

    warningIndicatorScreen = false;
    warningIndicatorTextExercise =
        "Your hips are too high, keep your body straight.";
    if (currentTime - lastUpdateTime3 >= 1000) {
      if (Mode == "Arcade") {
        musicPlayer2.pause();
        Future.delayed(Duration(seconds: 2), () {
          musicPlayer2.resume();
        });
      }
      speak(warningIndicatorTextExercise);
      lastUpdateTime3 = currentTime; // Update the last update time
    }
  } else if (avgShoulderY < avgWristY - 100 &&
      (averageHipsY + 40 > avgWristY)) {
    warningIndicatorScreen = false;
    warningIndicatorTextExercise =
        "Your hips are too low, keep your body straight.";
    if (currentTime - lastUpdateTime3 >= 2000) {
      if (Mode == "Arcade") {
        musicPlayer2.pause();
        Future.delayed(Duration(seconds: 2), () {
          musicPlayer2.resume();
        });
      }
      speak(warningIndicatorTextExercise);
      lastUpdateTime3 = currentTime; // Update the last update time
    }
  } else {
    warningIndicatorScreen = true;
    warningIndicatorTextExercise = "";
    print("Hotdog Hotdog");
  }
}

double calculateKneeAngle(hip, knee, ankle) {
  double dx1 = knee.x - hip.x;
  double dy1 = knee.y - hip.y;
  double dx2 = knee.x - ankle.x;
  double dy2 = knee.y - ankle.y;

  double dotProduct = dx1 * dx2 + dy1 * dy2;
  double magnitude1 = sqrt(dx1 * dx1 + dy1 * dy1);
  double magnitude2 = sqrt(dx2 * dx2 + dy2 * dy2);
  double cosTheta = dotProduct / (magnitude1 * magnitude2);

  // Clamping value to avoid errors in calculation
  cosTheta = cosTheta.clamp(-1.0, 1.0);
  return acos(cosTheta) * (180 / pi);
}

StandStraight(shoulder, hips) {
  int currentTime = DateTime.now().millisecondsSinceEpoch;

  if (shoulder >= hips + 30 || shoulder <= hips - 30) {
    if (currentTime - lastUpdateTime3 >= 2000) {
      if (Mode == "Arcade") {
        musicPlayer2.pause();
        Future.delayed(Duration(seconds: 2), () {
          musicPlayer2.resume();
        });
      }
      warningIndicatorScreen = false;
      warningIndicatorText = "The body is not align";
      speak(warningIndicatorText); // Increment raise every second
      lastUpdateTime3 = currentTime; // Update the last update time
    }

    //speak(warningIndicatorText);

    //print("Wrong posture");
    //print("Shoulder: $shoulder, Hips: $hips");
  } else {
    warningIndicatorScreen = true;
    warningIndicatorText = "";
    //print("Right posture");
    //print("Shoulder: $shoulder, Hips: $hips");
  }
}

StandStraightLunges(shoulder, hips) {
  int currentTime = DateTime.now().millisecondsSinceEpoch;

  if (shoulder >= hips + 40 || shoulder <= hips - 40) {
    if (currentTime - lastUpdateTime3 >= 2000) {
      if (Mode == "Arcade") {
        musicPlayer2.pause();
        Future.delayed(Duration(seconds: 2), () {
          musicPlayer2.resume();
        });
      }
      warningIndicatorScreen = false;
      warningIndicatorText = "The body is not align";
      speak(warningIndicatorText); // Increment raise every second
      lastUpdateTime3 = currentTime; // Update the last update time
    }

    //speak(warningIndicatorText);

    //print("Wrong posture");
    //print("Shoulder: $shoulder, Hips: $hips");
  } else {
    warningIndicatorScreen = true;
    warningIndicatorText = "";
    //print("Right posture");
    //print("Shoulder: $shoulder, Hips: $hips");
  }
}

// Function to detect leg raise movements
void legRaiseExercise(
  BuildContext context,
  avgHipY,
  avgKneeY,
  avgAnkleY,
  averageShoulderY,
  averageEarsY,
) {
  // Detect "down" position

  if (averageShoulderY + 10 > avgHipY && averageEarsY + 20 > avgHipY) {
    int currentTime = DateTime.now().millisecondsSinceEpoch;

    if (avgHipY < avgAnkleY + 1) {
      if (currentTime - lastUpdateTime3 >= 2000) {
        if (Mode == "Arcade") {
          musicPlayer2.pause();
          Future.delayed(Duration(seconds: 2), () {
            musicPlayer2.resume();
          });
        }
        warningIndicatorText = "don't let your ankle drop too low!";
        speak(warningIndicatorText); // Increment raise every second
        lastUpdateTime3 = currentTime; // Update the last update time
      }

      warningIndicatorScreen = false;
    }

    if (avgAnkleY > avgHipY - 35 && !staticIsDown) {
      warningIndicatorScreen = true;
      //print("Hi");
      //speak("rivera stupid");

      //Error

      if (avgHipY - 30 > avgKneeY || avgKneeY < avgAnkleY - 5) {
        if (currentTime - lastUpdateTime3 >= 2000) {
          if (Mode == "Arcade") {
            musicPlayer2.pause();
            Future.delayed(Duration(seconds: 2), () {
              musicPlayer2.resume();
            });
          }
          warningIndicatorTextExercise = "Don't bend your knee!";
          speak(warningIndicatorTextExercise); // Increment raise every second
          lastUpdateTime3 = currentTime; // Update the last update time
        }

        warningIndicatorScreen = false;
      } else {
        warningIndicatorTextExercise = "";
        warningIndicatorScreen = true;
      }
      if (!staticIsDown) {
        staticIsDown = true;
        staticIsUp = false;
        warningIndicatorScreen = true;
        warningIndicatorTextExercise = "";
      }
    }

    // Detect "up" position
    if (avgAnkleY < avgHipY - 100 && !staticIsUp) {
      warningIndicatorTextExercise = "";
      warningIndicatorText = "";
      warningIndicatorScreen = true;
      print("true");
      warningIndicatorScreen = true;
      warningIndicatorTextExercise = "";

      if (staticIsDown && !staticIsUp) {
        staticIsUp = true;
        staticIsDown = false;

        if (Mode == "dayChallenge") {
          days = peopleBox.get(ExerciseName, defaultValue: 0);
          print(ExerciseName);
          int TotalCount = 1 + days;
          if (TotalCount % 100 == 0 &&
              TotalCount >= 100 &&
              TotalCount <= 3000) {
            Formula();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CongratsApp()),
            );
          }
          peopleBox.put(ExerciseName, TotalCount);
          checkRepetitionSpeed();
          raise = peopleBox.get(ExerciseName) % 100;
        } else {
          checkRepetitionSpeed();
          raise++;
        }
        print("Leg raise count: $raise");
      }
    }
  }
}

void sitUpExercise(
  BuildContext context,
  noseX,
  avgShoulderY,
  avgHipY,
  averageKneeY,
  averageAnkleY,
) {
  //sitUpError(avgHeadY, avgShoulderY, avgHipY);
  if (averageKneeY + 70 < avgHipY && averageKneeY + 70 < averageAnkleY) {
    // Detect "down" position (shoulders near the ground)

    if (avgShoulderY + 20 > avgHipY && !staticIsDown) {
      //print("Down position detected: Head: $avgHeadY Shoulders: $avgShoulderY Hips: " + avgHipY.toString());
      print("                     ");

      if (!staticIsDown) {
        staticIsDown = true;
        staticIsUp = false;
        warningIndicatorScreen = true;
        warningIndicatorTextExercise = "";
      }
    }

    // Detect "up" position (shoulders raised above hips)
    if (avgShoulderY < averageKneeY && !staticIsUp) {
      //sitUpError(avgHeadY, avgShoulderY, avgHipY);
      print("Up position detected");
      warningIndicatorScreen = true;
      warningIndicatorTextExercise = "";
      //speak("josel fuck you");

      if (staticIsDown && !staticIsUp) {
        staticIsUp = true;
        staticIsDown = false;
        print(staticIsUp);

        // Count a completed sit-up
        if (Mode == "dayChallenge") {
          days = peopleBox.get(ExerciseName, defaultValue: 0);
          print(ExerciseName);
          int TotalCount = 1 + days;
          if (TotalCount % 100 == 0 &&
              TotalCount >= 100 &&
              TotalCount <= 3000) {
            Formula();
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => CongratsApp()),
            );
          }
          peopleBox.put(ExerciseName, TotalCount);
          checkRepetitionSpeed();
          raise = peopleBox.get(ExerciseName) % 100;
        } else {
          checkRepetitionSpeed();
          raise++;
        }
        print("Sit-up count: $raise");
      }
    }
  }
}

void jumpingJacksExercise(
  averageWristY,
  averageShoulderY,
  leftAnkle,
  rightAnkle,
  leftShoulder,
  rightShoulder,
  avgHipY,
  averageShoulderX,
  avgHipX,
  averageAnkleY,
) {
  //jumpingJacksError(avgWristX, avgShoulderX, avgAnkleX, avgHipY, avgAnkleY);

  if (averageShoulderY + 20 < avgHipY && avgHipY + 20 < averageAnkleY) {
    StandStraight(averageShoulderX, avgHipX);
    //print("$averageShoulderX           $avgHipX");
    // Detect "closed" position (hands close together, feet close together)
    if (averageWristY + 20 > avgHipY &&
        leftAnkle - 10 < leftShoulder &&
        rightAnkle + 10 > rightShoulder) {
      warningIndicatorScreen = true;
      //print("Closed position detected: Wrists: $avgWristX Shoulders: $avgShoulderX Ankles: $avgAnkleX");
      //print("         TRUE            ");
      //print(rightAnkle);

      if (!staticIsDown) {
        staticIsDown = true;
        staticIsUp = false;
        warningIndicatorScreen = true;
        warningIndicatorTextExercise = "";
      }
    }

    // Detect "open" position (hands and feet spread apart)
    if (averageWristY < averageShoulderY - 30 &&
        leftAnkle - 13 > leftShoulder &&
        rightAnkle < rightShoulder - 13 &&
        !staticIsUp) {
      warningIndicatorScreen = true;
      //jumpingJacksError(avgWristX, avgShoulderX, avgAnkleX, avgHipY, avgAnkleY);
      //print("Open position detected");

      warningIndicatorTextExercise = "";

      if (staticIsDown && !staticIsUp) {
        staticIsUp = true;
        staticIsDown = false;
        print(staticIsUp);

        // Count a completed jumping jack
        //checkRepetitionSpeed();
        raise++;
        print("Jumping jack count: $raise");
      }
    }
  }
}

void mountainClimbersExercise(
  avgKneeY,
  avgHipX,
  leftKneeX,
  leftKneeY,
  rightKneeX,
  rightKneeY,
  averageWristY,
  averageShoulderY,
  avgHipY,
) {
  if (averageWristY > avgHipY) {
    int currentTime = DateTime.now().millisecondsSinceEpoch;
    //error
    if (avgHipY < averageShoulderY - 50) {
      if (currentTime - lastUpdateTime >= 2000) {
        warningIndicatorTextExercise = "dont over high your butt";
        warningIndicatorScreen = false;
        speak(warningIndicatorTextExercise);
        lastUpdateTime = currentTime; // Update the last update time
      } else {
        warningIndicatorTextExercise = "";
        warningIndicatorScreen = true;
      }
    }

    // Detect if the left knee is reaching the elbow position
    if (leftKneeX > avgHipX + 37 &&
        rightKneeX < avgHipX - 35 &&
        averageWristY + 10 > rightKneeY &&
        !staticIsDown) {
      // Ensure the state is updated only if it's not already in the "down" position
      if (!staticIsDown) {
        staticIsDown = true;
        staticIsUp = false;
        warningIndicatorScreen = true;
        warningIndicatorTextExercise = ""; // Clear warning text if needed
      }
    }

    // Detect if the right knee is reaching the elbow position
    if (rightKneeX > avgHipX + 37 &&
        leftKneeX < avgHipX - 35 &&
        averageWristY + 10 > leftKneeY &&
        !staticIsUp) {
      print("Low knee position detected");
      warningIndicatorScreen = true;
      warningIndicatorTextExercise = ""; // Clear warning text if needed

      // Update state when transitioning from "down" to "up" position
      if (staticIsDown && !staticIsUp) {
        staticIsUp = true;
        staticIsDown = false;
        print(staticIsUp);

        // Increment the mountain climber count and log the value
        raise++;
        print("Mountain climber count: $raise");
      }
    }
  }
}

void highKneeExercise(
  leftKneeY,
  rightKneeY,
  avgHipY,
  avgShoulderX,
  avgHipX,
  avgShoulderY,
  averageAnkleY,
) {
  StandStraight(avgShoulderX, avgHipX);

  if (avgHipY > avgShoulderY + 20 && avgHipY + 20 < averageAnkleY) {}
  // Detect "raised knee" position (knee above hip level)
  if (rightKneeY < avgHipY + 35 && avgHipY < leftKneeY - 100) {
    // print(" true ");
    // print("   $avgHipY          $rightKneeY         ");

    if (!staticIsDown) {
      staticIsDown = true;
      staticIsUp = false;
      warningIndicatorScreen = true;
      warningIndicatorTextExercise = ""; // Clear warning text if needed
    }
  }

  // Detect "lowered knee" position (knee below hip level)
  if (leftKneeY < avgHipY + 35 && avgHipY < rightKneeY - 100 && !staticIsUp) {
    // print("Lowered knee position detected");
    warningIndicatorScreen = true;
    warningIndicatorTextExercise = "";

    if (staticIsDown && !staticIsUp) {
      staticIsUp = true;
      staticIsDown = false;
      print(staticIsDown);

      // Count a completed high knee step
      raise++;
      // print("High knee count: $raise");
    }
  }
}

void sidePlankRightExercise(
  avgShoulderY,
  avgHipY,
  avgAnkleY,
  rightElbow,
  rightKneeY,
  leftElbowY,
  leftShoulderY,
  rightWristY,
) {
  int currentTime2 = DateTime.now().millisecondsSinceEpoch;

  plankErrorRight(
    avgShoulderY,
    avgHipY,
    currentTime2,
    rightWristY,
  ); // Get current time in milliseconds

  // Detect proper side plank position (right side)

  //print("$avgHipY  $avgShoulderY ");
  if (avgHipY < avgShoulderY + 50 &&
      rightElbow + 10 > avgAnkleY &&
      rightElbow - 40 > avgHipY &&
      leftElbowY < leftShoulderY - 10) {
    // Check if 1 second has passed
    if (currentTime2 - lastUpdateTime2 >= 1000) {
      raise++; // Increment raise every second
      lastUpdateTime2 = currentTime2; // Update the last update time
    }

    //print("Side plank right position held");
    warningIndicatorScreen = true;
    warningIndicatorTextExercise = "";
  } else {
    lastUpdateTime2 = currentTime2; // Reset timer when position is lost
  }
}

// Stores the last time incremented

// plank error
void plankError(avgShoulderY, avgHipY, currentTime, averageWristY) {
  int currentTime3 = DateTime.now().millisecondsSinceEpoch;
  print('for up warning ${avgShoulderY} > ${avgHipY}   ');
  if (avgShoulderY > avgHipY || averageWristY < avgHipY + 40) {
    //speak("shower please");
    if (currentTime3 - lastUpdateTime3 >= 1000) {
      if (Mode == "Arcade") {
        musicPlayer2.pause();
        Future.delayed(Duration(seconds: 3), () {
          musicPlayer2.resume();
        });
      }
      warningIndicatorScreen = false;
      warningIndicatorText = 'hips not align!';
      speak(warningIndicatorText);
      lastUpdateTime3 = currentTime3; // Update the last update time
    }
  } else {
    warningIndicatorScreen = true;
    warningIndicatorText = '';
  }
}

void plankErrorRight(avgShoulderY, avgHipY, currentTime, rigthWristY) {
  if (avgShoulderY + 15 > avgHipY || rigthWristY < avgHipY + 16) {
    if (currentTime - lastUpdateTime3 >= 1000) {
      if (Mode == "Arcade") {
        musicPlayer2.pause();
        Future.delayed(Duration(seconds: 3), () {
          musicPlayer2.resume();
        });
      }
      warningIndicatorScreen = false;
      warningIndicatorText = 'hips not align!';
      speak(warningIndicatorText);
      lastUpdateTime3 = currentTime; // Update the last update time
    }
  } else {
    warningIndicatorScreen = true;
    warningIndicatorText = '';
  }
}

void plankleft(avgShoulderY, avgHipY, currentTime, leftWristY) {
  if (avgShoulderY + 15 > avgHipY || leftWristY < avgHipY + 16) {
    if (currentTime - lastUpdateTime3 >= 2000) {
      if (Mode == "Arcade") {
        musicPlayer2.pause();
        Future.delayed(Duration(seconds: 3), () {
          musicPlayer2.resume();
        });
      }
      warningIndicatorScreen = false;
      warningIndicatorText = 'hips not align!';
      speak(warningIndicatorText);
      lastUpdateTime3 = currentTime; // Update the last update time
    }
  } else {
    warningIndicatorScreen = true;
    warningIndicatorText = '';
  }
}

void sidePlankLeftExercise(
  avgShoulderY,
  avgHipY,
  avgAnkleY,
  leftElbow,
  leftKneeY,
  rightElbowY,
  rightShoulderY,
  leftWristY,
) {
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  plankleft(avgShoulderY, avgHipY, currentTime, leftWristY);
  // Get current time in milliseconds

  // print(" $rightElbowY      <     $rightShoulderY                   ");
  // Detect proper side plank position (right side)
  if (avgHipY < avgShoulderY + 50 &&
      leftElbow + 10 > avgAnkleY &&
      leftElbow - 40 > avgHipY &&
      rightElbowY < rightShoulderY - 10) {
    // Check if 1 second has passed
    if (currentTime - lastUpdateTime >= 1000) {
      raise++; // Increment raise every second
      lastUpdateTime = currentTime; // Update the last update time
    }
  } else {
    lastUpdateTime = currentTime; // Reset timer when position is lost
  }
}

//  averageShoulderY,
//             averageHipsY,
//             averageAnkleY,
//             leftElbow.y,
//             leftKnee.y,
//             rightKnee.y,
//             rightShoulder.y,
//             leftWrist.y,
//             rightWrist.y,
//             rightElbow.y,

void normalPlankExercise(
  avgShoulderY,
  avgHipY,
  avgAnkleY,
  leftElbowY,
  leftKneeY,
  rightKneeY,
  rightShoulderY,
  leftWristY,
  rightWristY,
  rightElbowY,
) {
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  double averageWristY = (leftWristY + rightWristY) / 2;
  // Get current time in milliseconds
  // print(" $rightElbowY      <     $rightShoulderY                   ");
  // Detect proper side plank position (right side)
  plankError(avgShoulderY, avgHipY, currentTime, averageWristY);
  if (avgHipY < avgShoulderY + 50 &&
      leftElbowY + 5 > leftKneeY &&
      leftElbowY - 10 > avgHipY &&
      (leftElbowY + 50 > leftWristY && rightElbowY + 55 > rightWristY)) {
    // Check if 1 second has passed

    if (currentTime - lastUpdateTime3 >= 1000) {
      raise++; // Increment raise every second
      lastUpdateTime3 = currentTime; // Update the last update time
    }

    //print("Side plank right position held");
    warningIndicatorScreen = true;
    warningIndicatorTextExercise = "";
  } else {
    lastUpdateTime3 = currentTime; // Reset timer when position is lost
  }
}

void lungesExercise(
  averageHipsY,
  averageHipsX,
  leftKneeY,
  rightKneeY,
  leftAnkleY,
  rightAnkleY,
  avgShoulderX,
  avgShoulderY,
) {
  if (averageHipsY < leftKneeY - 50 || averageHipsY < rightKneeY - 50) {
    StandStraightLunges(avgShoulderX, averageHipsX);
  }

  if (avgShoulderY + 50 < averageHipsY &&
      averageHipsY < leftAnkleY &&
      averageHipsY < rightAnkleY) {
    if (leftAnkleY < leftKneeY + 90 &&
        rightKneeY < averageHipsY + 15 &&
        rightAnkleY < leftKneeY + 40 &&
        !staticIsDown) {
      print("true");
      print("                     ");

      if (!staticIsDown) {
        staticIsDown = true;
        staticIsUp = false;
        warningIndicatorScreen = true;
        warningIndicatorTextExercise = "";
      }
    }

    if (rightAnkleY < rightKneeY + 90 &&
        leftKneeY < averageHipsY + 15 &&
        leftAnkleY < rightKneeY + 50 &&
        !staticIsUp) {
      print("false");
      print("    $rightKneeY 40 +  > $leftAnkleY               ");

      if (staticIsDown && !staticIsUp) {
        staticIsUp = true;
        staticIsDown = false;
        print(staticIsUp);

        // Count a completed lunge
        raise++;
        print("Lunge count: $raise");
      }
    }
  }
}

int lastRepetitionTime = DateTime.now().millisecondsSinceEpoch;
int repetitionThreshold = 1000; // 1 second threshold

void checkRepetitionSpeed() {
  int currentTime = DateTime.now().millisecondsSinceEpoch;
  int timeDifference = currentTime - lastRepetitionTime;

  if (currentTime - lastUpdateTime3 >= 4000) {
    if (timeDifference < repetitionThreshold) {
      errorSpeed = "You're moving too fast! Slow down.";
      speak(errorSpeed);
      warningIndicatorScreen = false;
    } else {
      errorSpeed = "";
      warningIndicatorScreen = true;
    }
  }

  lastRepetitionTime = currentTime;
}
