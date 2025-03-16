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

class ChooseBodyparts extends StatefulWidget {
  const ChooseBodyparts({super.key});

  @override
  State<ChooseBodyparts> createState() => _ChooseBodypartsState();
}

class _ChooseBodypartsState extends State<ChooseBodyparts> {
  final List<BodyPartItem> _bodyParts = [
    // Replace the asset paths with your actual image assets
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
            Icons.arrow_back,
            color: AppColor.moresolidPrimary,
          ),
          onPressed: () {
            Navigator.push(context,
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
            // Use GridView.count for grid cards
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                children: _bodyParts.map((item) {
                  return GestureDetector(
                    onTap: () {
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
              // Use a default asset if null
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

