import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/homepage/starter_page.dart';
import 'package:exercai_mobile/login_register_pages/Whatisyour_target_weight.dart';
import 'package:exercai_mobile/login_register_pages/height_choose.dart';
import 'package:exercai_mobile/login_register_pages/nutriActivitylevel.dart';
import 'package:exercai_mobile/login_register_pages/injury_selection.dart';
import 'package:exercai_mobile/login_register_pages/weight_choose.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercai_mobile/main.dart';
import 'package:hive/hive.dart';
import 'createaccount.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class WhatGoalPage extends StatefulWidget {
  const WhatGoalPage({super.key});

  @override
  State<WhatGoalPage> createState() => _WhatGoalPageState();
}

class _WhatGoalPageState extends State<WhatGoalPage> {
  String? selectedGoal;
  String? bmiCategory;


  @override
  void initState() {
    super.initState();
    _loadSelectedGoal(); // Load stored goal when returning to this page
    _loadBmiCategory(); // Load user's BMI category from Firestore
  }

  // 🔹 Load saved goal from SharedPreferences
  Future<void> _loadSelectedGoal() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedGoal = prefs.getString('selectedGoal');
    });
  }

  // 🔹 Save selected goal to SharedPreferences
  Future<void> _saveSelectedGoal(String goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedGoal', goal);
  }

  // 🔹 Load BMI category from Firebase for current user
  Future<void> _loadBmiCategory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.email)
          .get();
      if (doc.exists && doc.data() != null) {
        setState(() {
          bmiCategory = doc.get('bmiCategory'); // e.g., "normal", "underweight", or "extreme_obese"
        });
      }
    }
  }

  void saveGoalToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && selectedGoal != null) {
      await FirebaseFirestore.instance.collection("Users").doc(user.email).set({
        'goal': selectedGoal,
      }, SetOptions(merge: true));

      print("Goal saved to Firebase: $selectedGoal");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select a goal before proceeding.")),
      );
    }
  }

  // Map each goal to its corresponding image asset
  String _getImageAssetForGoal(String goalValue) {
    switch (goalValue) {
      case "lose weight":
        return "assets/info/lose_weight.png";
      case "muscle mass gain":
        return "assets/info/gain_weight.png";
      case "maintain":
        return "assets/info/maintain_weight.png";
      default:
        return "assets/info/lose_weight.png";
    }
  }

  @override
  Widget build(BuildContext context) {
    // Wait until bmiCategory is loaded
    if (bmiCategory == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(context),
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderText(),
            _buildGoalSelectionSection(),
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
        icon: Icon(Icons.arrow_back_ios, color: Colors.black87),
        onPressed: () {
          navigateWithSlideTransition(context, WeightChoose(), slideRight: false);
        },
      ),
      centerTitle: true,
      title: Image.asset('assets/exercai-front.png', height: 60,width: 100,),
    );
  }

  Widget _buildHeaderText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      child: Column(
        children: [
          Text(
            "What is your Goal?",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 28,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            "Choose whether you want to lose weight, gain muscle, or maintain your current weight!",
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w500,
              color: Colors.grey[700],
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildGoalSelectionSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 15,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildGoalOption(
            title: "Lose Weight",
            goalValue: "lose weight",
          ),
          const SizedBox(height: 20),
          _buildGoalOption(
            title: "Muscle Mass Gain",
            goalValue: "muscle mass gain",
          ),
          const SizedBox(height: 20),
          _buildGoalOption(
            title: "Maintain",
            goalValue: "maintain",
          ),
        ],
      ),
    );
  }

  Widget _buildGoalOption({required String title, required String goalValue}) {
    bool isSelected = selectedGoal == goalValue;

    // Determine if this option should be disabled based on the BMI category.
    bool isDisabled = false;
    if (bmiCategory != null) {
      if (bmiCategory == "underweight" && (goalValue == "lose weight" || goalValue == "maintain")) {
        isDisabled = true;
      } else if (bmiCategory == "extreme_obese" && (goalValue == "muscle mass gain" || goalValue == "maintain")) {
        isDisabled = true;
      }
    }

    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
        setState(() {
          selectedGoal = goalValue;
        });
        _saveSelectedGoal(goalValue); // Save selection
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        decoration: BoxDecoration(
          // If disabled, use a light grey background; otherwise, use selected color if chosen.
          color: isDisabled
              ? Colors.grey.shade300
              : isSelected
              ? AppColor.supersolidPrimary.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDisabled
                ? Colors.grey
                : isSelected
                ? AppColor.supersolidPrimary
                : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected && !isDisabled
              ? [
            BoxShadow(
              color: AppColor.backgroundWhite.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ]
              : [],
        ),
        child: Row(
          children: [
            // Display the image asset beside the choice.
            Opacity(
              opacity: isDisabled ? 0.5 : 1.0,
              child: Image.asset(
                _getImageAssetForGoal(goalValue),
                width: 40,
                height: 40,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isDisabled ? Colors.grey : Colors.black87,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 24,
              width: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isDisabled
                    ? Colors.grey
                    : isSelected
                    ? AppColor.supersolidPrimary
                    : Colors.transparent,
                border: Border.all(
                  color: isDisabled ? Colors.grey : AppColor.lightPrimary,
                  width: 2,
                ),
              ),
              child: isSelected && !isDisabled
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
    // If no goal is selected, the button is considered disabled.
    bool isDisabled = selectedGoal == null;
    return GestureDetector(
      onTap: isDisabled
          ? null
          : () {
        saveGoalToFirebase();
        _saveSelectedGoal(selectedGoal!); // Save selection before navigation
        if (selectedGoal == "maintain") {
          navigateWithSlideTransition(context, Nutriactivitylevel(), slideRight: true);
        } else if (selectedGoal == "lose weight" || selectedGoal == "muscle mass gain") {
          navigateWithSlideTransition(context, WhatisyourTargetWeight(), slideRight: true);
        }
      },
      child: Container(
        height: 55,
        width: 180,
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
              color: AppColor.moresolidPrimary.withOpacity(0.4),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Next",
            style: GoogleFonts.poppins(
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
