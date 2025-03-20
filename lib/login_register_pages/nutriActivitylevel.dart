import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/login_register_pages/Whatisyour_Goal_page.dart';
import 'package:exercai_mobile/login_register_pages/Whatisyour_target_weight.dart';
import 'package:exercai_mobile/login_register_pages/injury_selection.dart';
import 'package:exercai_mobile/login_register_pages/weight_choose.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

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
        SnackBar(content: Text("Please select an activity level before proceeding.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderText(),
            _buildActivityLevelOptions(),
            const Spacer(),
            _buildNextButton(context),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios, color: AppColor.moresolidPrimary),
        onPressed: () {
          // Retrieve the selected goal from SharedPreferences
          SharedPreferences.getInstance().then((prefs) {
            String? selectedGoal = prefs.getString('selectedGoal');
            if (selectedGoal == "maintain") {
              navigateWithSlideTransition(context, WhatGoalPage(), slideRight: false);
            } else if (selectedGoal == "lose weight" || selectedGoal == "muscle mass gain") {
              navigateWithSlideTransition(context, WhatisyourTargetWeight(), slideRight: false);
            } else {
              // Fallback navigation if no goal is stored
              navigateWithSlideTransition(context, WeightChoose(), slideRight: false);
            }
          });
        },
      ),
      centerTitle: true,
      title: Image.asset('assets/exercai-front.png', height: 60, width: 100),
    );
  }


  Widget _buildHeaderText() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Column(
        children: [
          Text(
            "What's your Activity Level?",
            style: GoogleFonts.roboto(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Select how active you are throughout the day to get personalized nutrition recommendations.",
            style: GoogleFonts.roboto(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityLevelOptions() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColor.primary.withOpacity(0.1), AppColor.backgroundWhite.withOpacity(0.1)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildTargetOption(title: "Inactive", value: "Inactive"),
          const SizedBox(height: 20),
          _buildTargetOption(title: "Low Active", value: "Low Active"),
          const SizedBox(height: 20),
          _buildTargetOption(title: "Active", value: "Active"),
          const SizedBox(height: 20),
          _buildTargetOption(title: "Very Active", value: "Very Active"),
        ],
      ),
    );
  }

  // Map each activity level to its image asset
  String _getImageAssetForActivity(String activity) {
    switch (activity) {
      case "Inactive":
        return "assets/info/inactive.png";
      case "Low Active":
        return "assets/info/low_active.png";
      case "Active":
        return "assets/info/active.png";
      case "Very Active":
        return "assets/info/very_active.png";
      default:
        return "assets/info/default.png";
    }
  }

  Widget _buildTargetOption({required String title, required String value}) {
    bool isSelected = selectedActivtyLevel == value;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedActivtyLevel = value;
        });
        _saveSelectedActivityLevel(value); // Save selection
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected ? AppColor.backgroundWhite.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColor.supersolidPrimary : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColor.superlightPrimary.withOpacity(0.3),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ]
              : [],
        ),
        child: Row(
          children: [
            // Display the image asset beside each choice
            Image.asset(
              _getImageAssetForActivity(title),
              width: 40,
              height: 40,
              fit: BoxFit.cover,
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.roboto(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppColor.supersolidPrimary : Colors.transparent,
                border: Border.all(
                  color: AppColor.primary,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                Icons.check,
                color: Colors.white,
                size: 16,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    // Determine if the button should be disabled
    final bool isDisabled = selectedActivtyLevel == null;

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
        saveNutriactivitylevelToFirebase();
        _saveSelectedActivityLevel(selectedActivtyLevel!); // Save selection before navigation
        navigateWithSlideTransition(context, InjurySelection(), slideRight: true);
      },
      child: Container(
        height: 55,
        width: 180,
        margin: const EdgeInsets.symmetric(horizontal: 25),
        decoration: BoxDecoration(
          gradient: isDisabled
              ? LinearGradient(
            colors: [Colors.grey, Colors.grey],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          )
              : LinearGradient(
            colors: [AppColor.supersolidPrimary, AppColor.moresolidPrimary],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: isDisabled
              ? []
              : [
            BoxShadow(
              color: AppColor.superlightPrimary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Next",
            style: GoogleFonts.roboto(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

}
