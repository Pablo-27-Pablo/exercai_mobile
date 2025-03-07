import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/login_register_pages/Whatisyour_Goal_page.dart';
import 'package:exercai_mobile/login_register_pages/injury_selection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Nutriactivitylevel extends StatefulWidget {
  const Nutriactivitylevel({super.key});

  @override
  State<Nutriactivitylevel> createState() => _NutriactivitylevelState();
}

class _NutriactivitylevelState extends State<Nutriactivitylevel> {
  String? selectedActivtyLevel;

  @override
  void initState() {
    super.initState();
    _loadSelectedActivityLevel(); // Load stored selection when returning to this page
  }

  // 🔹 Load saved activity level from SharedPreferences
  Future<void> _loadSelectedActivityLevel() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedActivtyLevel = prefs.getString('selectedActivityLevel');
    });
  }

  // 🔹 Save selected activity level to SharedPreferences
  Future<void> _saveSelectedActivityLevel(String activityLevel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedActivityLevel', activityLevel);
  }

  void saveNutriactivitylevelToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && selectedActivtyLevel != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.email)
          .set({
        'nutriActivitylevel': selectedActivtyLevel,
      }, SetOptions(merge: true));

      print("Activity Level saved to Firebase: $selectedActivtyLevel");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a activity level before proceeding.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundgrey,
      appBar: AppbarSection(context),
      body: Column(
        children: [
          TextSection(),
          ActivityLevelNutrition(),
          SizedBox(height: 75),
          NextButton(context),
        ],
      ),
    );
  }

  GestureDetector NextButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        saveNutriactivitylevelToFirebase();
        _saveSelectedActivityLevel(selectedActivtyLevel!); // Save selection before navigation
        navigateWithSlideTransition(context, InjurySelection(), slideRight: true);
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

  Widget ActivityLevelNutrition() {
    return Container(
      height: 380,
      color: AppColor.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
        child: Column(
          children: [
            TargetOption(
              title: "Inactive",
              isSelected: selectedActivtyLevel == "Inactive",
              onTap: () {
                setState(() {
                  selectedActivtyLevel = "Inactive";
                });
                _saveSelectedActivityLevel("Inactive"); // Save selection
              },
            ),
            SizedBox(height: 30),
            TargetOption(
              title: "Low Active",
              isSelected: selectedActivtyLevel == "Low Active",
              onTap: () {
                setState(() {
                  selectedActivtyLevel = "Low Active";
                });
                _saveSelectedActivityLevel("Low Active"); // Save selection
              },
            ),
            SizedBox(height: 30),
            TargetOption(
              title: "Active",
              isSelected: selectedActivtyLevel == "Active",
              onTap: () {
                setState(() {
                  selectedActivtyLevel = "Active";
                });
                _saveSelectedActivityLevel("Active"); // Save selection
              },
            ),

            SizedBox(height: 30),
            TargetOption(
              title: "Very Active",
              isSelected: selectedActivtyLevel == "Very Active",
              onTap: () {
                setState(() {
                  selectedActivtyLevel = "Very Active";
                });
                _saveSelectedActivityLevel("Very Active"); // Save selection
              },
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
    height: 140,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 25),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "What is your Activity Level?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 30,
              ),
            ),
            SizedBox(height: 15),
            Expanded(
              child: Text(
                "Select how active you are throughout the day to get accurate nutrition recommendations!",
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

AppBar AppbarSection(BuildContext context) {
  return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      leading:IconButton(onPressed: (){
        navigateWithSlideTransition(context, WhatGoalPage(), slideRight: false);
      }, icon: Icon(Icons.arrow_back,color: Colors.yellow,))
  );
}