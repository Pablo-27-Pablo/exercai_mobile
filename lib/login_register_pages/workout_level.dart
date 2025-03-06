import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/login_register_pages/bodyshape.dart';
import 'package:exercai_mobile/login_register_pages/injury_selection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercai_mobile/main.dart';
import 'package:hive/hive.dart';
import 'createaccount.dart';

class WorkoutLevel extends StatefulWidget {
  const WorkoutLevel({super.key});

  @override
  State<WorkoutLevel> createState() => _WorkoutLevelState();
}

class _WorkoutLevelState extends State<WorkoutLevel> {
  String? selectedArea;

  void saveWorkoutLevelToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && selectedArea != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.email)
          .set({
        'workoutLevel': selectedArea,
      }, SetOptions(merge: true));

      print("Target Area saved to Firebase: $selectedArea");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a target area before proceeding.")),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundgrey,
      appBar: AppbarSection(),
      body: Column(
        children: [
          TextSection(),
          TargetSelectionSection(),
          SizedBox(height: 75),
          NextButton(context),
        ],
      ),
    );
  }

  GestureDetector NextButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        saveWorkoutLevelToFirebase();
        // Navigate to the next screen
        Navigator.push(context, MaterialPageRoute(builder: (context) => Bodyshape()));
      },
      child: Container(
        height: 55,
        width: 150,
        decoration: BoxDecoration(
          color: AppColor.buttonPrimary.withOpacity(0.7),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(width: 2, color: AppColor.buttonSecondary),
          boxShadow: [
            BoxShadow(
              color: AppColor.buttonSecondary.withOpacity(0.7),
              blurRadius: 90,
              spreadRadius: 0.1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Next",
            style: TextStyle(
              color: AppColor.textwhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget TargetSelectionSection() {
    return Container(
      height: 300,
      color: AppColor.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
        child: Column(
          children: [
            TargetOption(
              title: "Beginner",
              isSelected: selectedArea == "beginner",
              onTap: () => setState(() {
                selectedArea = "beginner";
              }),
            ),
            SizedBox(height: 30),
            TargetOption(
              title: "Intermediate",
              isSelected: selectedArea == "intermediate",
              onTap: () => setState(() {
                selectedArea = "intermediate";
              }),
            ),
            SizedBox(height: 30),
            TargetOption(
              title: "Advanced",
              isSelected: selectedArea == "advanced",
              onTap: () => setState(() {
                selectedArea = "advanced";
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget TargetOption({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColor.buttonPrimary,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Container(
                height: 20,
                width: 20,
                decoration: BoxDecoration(
                  color: isSelected ? AppColor.buttonPrimary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    width: 2,
                    color: AppColor.buttonPrimary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Container TextSection() {
  return Container(
    height: 210,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              "What is your Preferred Workout Level?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 30,
              ),textAlign: TextAlign.center,
            ),
            SizedBox(height: 40),
            Expanded(
              child: Text(
                "Choose how intense and frequent your workouts are",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                  fontSize: 15,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

AppBar AppbarSection() {
  return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      leading:IconButton(onPressed: (){}, icon: Icon(Icons.arrow_back,color: Colors.yellow,))
  );
}
