import 'package:exercai_mobile/different_exercises/bodypart_exercises/back_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/cardio_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/chest_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/lower_arms_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/lower_legs_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/neck_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/shoulders_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/upper_arms_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/upper_legs_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/waist_allExercises.dart';
import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChooseBodyparts extends StatefulWidget {
  const ChooseBodyparts({super.key});

  @override
  State<ChooseBodyparts> createState() => _ChooseBodypartsState();
}

class _ChooseBodypartsState extends State<ChooseBodyparts> {
  // Initially an empty list; will be filled from Firestore
  List<String> _userInjuries = [];
  final List<BodyPartItem> _bodyParts = [
    BodyPartItem(title: "Neck", screen: NeckAllexercises(), assetPath: "assets/neck.png"),
    BodyPartItem(title: "Chest", screen: ChestAllexercises(), assetPath: "assets/chest.png"),
    BodyPartItem(title: "Waist", screen: WaistAllexercises(), assetPath: "assets/waist.png"),
    BodyPartItem(title: "Back", screen: BackAllexercises(), assetPath: "assets/back.png"),
    BodyPartItem(title: "Shoulders", screen: ShouldersAllexercises(), assetPath: "assets/shoulder.png"),
    BodyPartItem(title: "Upper Arms", screen: UpperArmsAllexercises(), assetPath: "assets/upper_arm.png"),
    BodyPartItem(title: "Lower Arms", screen: LowerArmsAllexercises(), assetPath: "assets/lower_arm.png"),
    BodyPartItem(title: "Upper Legs", screen: UpperLegsAllexercises(), assetPath: "assets/upper_leg.png"),
    BodyPartItem(title: "Lower Legs", screen: LowerLegsAllexercises(), assetPath: "assets/lower_leg.png"),
    BodyPartItem(title: "Cardio", screen: CardioAllexercises(), assetPath: "assets/cardio.png"),
  ];

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  /// Fetches the user's injury areas from Firestore and sets the _userInjuries list.
  Future<void> fetchUserData() async {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(currentUser.email)
          .get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        String injuryArea = userData['injuryArea'] ?? '';
        // Split the comma-separated string and remove any empty values
        List<String> injuries = injuryArea.split(', ').where((s) => s.isNotEmpty).toList();
        // Clear list if "none of them" is selected
        if (injuries.contains('none of them')) {
          injuries.clear();
        }
        setState(() {
          _userInjuries = injuries.map((injury) => injury.toLowerCase()).toList();
        });
      }
    } catch (e) {
      print("Error fetching user injury data: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for a fresh look
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Different Body Parts',
          style: TextStyle(
              color: AppColor.supersolidPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            color: AppColor.moresolidPrimary,
          ),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MainLandingPage()));
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            const Text(
              'Exercises',
              style: TextStyle(
                color: AppColor.backgroundgrey,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Grid of body part cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: _bodyParts.map((item) {
                  return GestureDetector(
                    onTap: () async {
                      // Convert the tapped body part to lowercase for comparison
                      String tappedBodyPart = item.title.toLowerCase();
                      if (_userInjuries.contains(tappedBodyPart)) {
                        bool? proceedInjury = await showDialog<bool>(
                          context: context,
                          builder: (context) => Dialog(
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20)),
                            elevation: 10,
                            backgroundColor: Colors.white,
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.85,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Header with Icon and Title
                                  Row(
                                    children: [
                                      const Icon(Icons.warning, color: Colors.red, size: 30),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "Injury Warning",
                                          style: TextStyle(
                                            fontSize: 22,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.red[700],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  // Content message
                                  Text(
                                    "You have an injury in your $tappedBodyPart. Exercising this area might aggravate your injury.\nDo you want to proceed?",
                                    style: const TextStyle(
                                        fontSize: 18, color: Colors.black87),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 30),
                                  // Action Buttons
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    children: [
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.grey[300],
                                          foregroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(false),
                                        child: Text("Cancel", style: TextStyle(fontSize: 16)),
                                      ),
                                      const SizedBox(width: 10),
                                      ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.red,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        onPressed: () =>
                                            Navigator.of(context).pop(true),
                                        child: Text("Proceed", style: TextStyle(fontSize: 16)),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ) ?? false;
                        if (!proceedInjury) return;
                      }
                      // Navigate to the selected body part screen if no injury or user proceeds
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => item.screen));
                    },
                    child: _buildGridCard(item.title, item.assetPath),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGridCard(String text, String? asset) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: [AppColor.superlightPrimary, AppColor.primary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.4),
              offset: const Offset(0, 4),
              blurRadius: 6,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              // Default asset if null
              Image.asset(
                asset ?? "assets/images/default.png",
                width: 40,
                height: 40,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Helper model for body part items.
class BodyPartItem {
  final String title;
  final Widget screen;
  final String? assetPath;
  BodyPartItem({required this.title, required this.screen, this.assetPath});
}
