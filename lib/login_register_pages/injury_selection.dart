import 'package:exercai_mobile/login_register_pages/nutriActivitylevel.dart';
import 'package:exercai_mobile/login_register_pages/workout_level.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';
import '../utils/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InjurySelection extends StatefulWidget {
  const InjurySelection({super.key});

  @override
  State<InjurySelection> createState() => _InjurySelectionState();
}

class _InjurySelectionState extends State<InjurySelection> {
  List<String> selectedInjuries = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedInjuries(); // Load stored selections when returning to this page
  }

  // 🔹 Load saved injury selections from SharedPreferences
  Future<void> _loadSelectedInjuries() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedInjuries = prefs.getStringList('selectedInjuries') ?? [];
    });
  }

  // 🔹 Save selected injuries to SharedPreferences
  Future<void> _saveSelectedInjuries() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedInjuries', selectedInjuries);
  }

  // Convert "none of them" -> "None Of Them", etc.
  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  // Map each injury to a corresponding icon
  Widget _getIconForInjury(String injury) {
    switch (injury) {
      case "none of them":
        return Icon(Icons.not_interested, color: AppColor.buttonPrimary, size: 28);
      case "chest":
        return Image.asset('assets/chest.png',height: 28,);
      case "back":
        return Image.asset('assets/back.png',height: 28,);
      case "shoulders":
        return Image.asset('assets/shoulder.png',height: 28,);
      case "neck":
        return Image.asset('assets/neck.png',height: 28,);
      case "lower arms":
        return Image.asset('assets/lower_arm.png',height: 28,);
      case "upper arms":
        return Image.asset('assets/upper_arm.png',height: 28,);
      case "lower legs":
        return Image.asset('assets/lower_leg.png',height: 28,);
      case "upper legs":
        return Image.asset('assets/upper_leg.png',height: 28,);
      case "waist":
        return Image.asset('assets/waist.png',height: 28,);
      default:
        return Icon(Icons.not_interested, color: AppColor.buttonPrimary, size: 28);
    }
  }

  void saveInjuryAreaToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && selectedInjuries.isNotEmpty) {
      // Save the injuries in lowercase
      String injuryAreas = selectedInjuries.join(", ");
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.email)
          .set({'injuryArea': injuryAreas}, SetOptions(merge: true));

      print("Injury Area saved to Firebase: $injuryAreas");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Please select an injury area before proceeding."),
        ),
      );
    }
  }

  void toggleSelection(String injury) {
    setState(() {
      // If "None of Them" is selected, clear all other selections
      if (injury == "none of them") {
        selectedInjuries = ["none of them"];
      } else {
        // Remove "None of Them" if selecting something else
        selectedInjuries.remove("none of them");
        if (selectedInjuries.contains(injury)) {
          selectedInjuries.remove(injury);
        } else {
          selectedInjuries.add(injury);
        }
      }
    });

    _saveSelectedInjuries(); // Save selection after toggling
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeaderSection(),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  child: _buildInjuryOptionsSection(),
                ),
              ),
            ),
            _buildNextButton(),
            SizedBox(height: 20),
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
        icon: Icon(Icons.arrow_back_ios, color: AppColor.supersolidPrimary),
        onPressed: () {
          navigateWithSlideTransition(context, Nutriactivitylevel(),
              slideRight: false);
        },
      ),
      centerTitle: true,
      title: Text(
        "Select Injury Areas",
        style: TextStyle(
            color: AppColor.buttonPrimary, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildHeaderSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20, vertical: 25),
      child: Column(
        children: [
          Text(
            "Any Injured Areas\nNeeding Attention?",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColor.buttonPrimary,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 10),
          Text(
            "We will filter and reduce improper exercises for you.",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInjuryOptionsSection() {
    List<String> injuryOptions = [
      "none of them",
      "chest",
      "back",
      "shoulders",
      "neck",
      "lower arms",
      "upper arms",
      "lower legs",
      "upper legs",
      "waist",
    ];

    return Column(
      children: injuryOptions.map((injury) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: _buildInjuryOption(
            displayTitle: toTitleCase(injury),
            injuryValue: injury,
            isSelected: selectedInjuries.contains(injury),
            onTap: () => toggleSelection(injury),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildInjuryOption({
    required String displayTitle,
    required String injuryValue,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: EdgeInsets.symmetric(horizontal: 20),
        height: 60,
        decoration: BoxDecoration(
          color: isSelected
              ? AppColor.supersolidPrimary.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: isSelected ? AppColor.supersolidPrimary : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: AppColor.supersolidPrimary.withOpacity(0.0),
              offset: Offset(0, 4),
              blurRadius: 8,
            ),
          ]
              : [],
        ),
        child: Row(
          children: [
            // Added icon for body part
            _getIconForInjury(injuryValue),
            SizedBox(width: 15),
            Expanded(
              child: Text(
                displayTitle,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColor.buttonPrimary,
                ),
              ),
            ),
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColor.primary,
                  width: 2,
                ),
                color:
                isSelected ? AppColor.supersolidPrimary : Colors.transparent,
              ),
              child: isSelected
                  ? Icon(
                Icons.check,
                size: 16,
                color: Colors.white,
              )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: () {
        _saveSelectedInjuries(); // Save selections before navigation
        saveInjuryAreaToFirebase();
        navigateWithSlideTransition(context, WorkoutLevel(), slideRight: true);
      },
      child: Container(
        margin: EdgeInsets.symmetric(vertical: 15),
        height: 55,
        width: MediaQuery.of(context).size.width * 0.6,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.supersolidPrimary, AppColor.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: AppColor.buttonSecondary.withOpacity(0.5),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Center(
          child: Text(
            "Next",
            style: TextStyle(
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
