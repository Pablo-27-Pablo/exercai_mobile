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

  // Convert "none of them" -> "None Of Them", "chest" -> "Chest", etc.
  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
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
      backgroundColor: AppColor.backgroundgrey,
      appBar: AppbarSection(context),
      body: Column(
        children: [
          TextSection(),
          // Use Expanded + SingleChildScrollView to avoid overflow
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                color: AppColor.primary, // Primary color background
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
                  child: InjuryAreaSection(),
                ),
              ),
            ),
          ),
          // "Next" button at the bottom
          SizedBox(height: 20),
          NextButton(),
          SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget InjuryAreaSection() {
    // All-lowercase strings to store in Firestore
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
        return Column(
          children: [
            InjuryOption(
              // Display in Title Case, store in lowercase
              displayTitle: toTitleCase(injury),
              injuryValue: injury,
              isSelected: selectedInjuries.contains(injury),
              onTap: () => toggleSelection(injury),
            ),
            SizedBox(height: 15),
          ],
        );
      }).toList(),
    );
  }

  Widget InjuryOption({
    required String displayTitle,
    required String injuryValue,
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
                    displayTitle,
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

  GestureDetector NextButton() {
    return GestureDetector(
      onTap: () {
        _saveSelectedInjuries(); // Save selections before navigation
        saveInjuryAreaToFirebase();
        navigateWithSlideTransition(context, WorkoutLevel(), slideRight: true);
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
}

// Text Section at the top
Container TextSection() {
  return Container(
    height: 115,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Any Injured Areas\nNeeding Attention?",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 10),
            Expanded(
              child: Text(
                "We will filter and reduce improper exercises for you.",
                style: TextStyle(
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
        navigateWithSlideTransition(context, Nutriactivitylevel(), slideRight: false);
      }, icon: Icon(Icons.arrow_back,color: Colors.yellow,))
  );
}
