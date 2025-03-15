import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/login_register_pages/Whatisyour_target_weight.dart';
import 'package:exercai_mobile/login_register_pages/bodyshape.dart';
import 'package:exercai_mobile/login_register_pages/injury_selection.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercai_mobile/main.dart';
import 'package:hive/hive.dart';
import 'createaccount.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';

class WorkoutLevel extends StatefulWidget {
  const WorkoutLevel({super.key});

  @override
  State<WorkoutLevel> createState() => _WorkoutLevelState();
}

class _WorkoutLevelState extends State<WorkoutLevel> {
  // Map slider positions to workout level values.
  final Map<int, String> workoutLevels = {
    0: "beginner",
    1: "intermediate",
    2: "advanced",
  };

  // Default slider index.
  int sliderIndex = 0;
  String? selectedArea;

  @override
  void initState() {
    super.initState();
    _loadSelectedWorkoutLevel();
  }

  // 🔹 Load saved workout level from SharedPreferences
  Future<void> _loadSelectedWorkoutLevel() async {
    final prefs = await SharedPreferences.getInstance();
    String? savedValue = prefs.getString('selectedWorkoutLevel');
    setState(() {
      if (savedValue != null) {
        sliderIndex = workoutLevels.entries.firstWhere(
              (entry) => entry.value == savedValue,
          orElse: () => const MapEntry(0, "beginner"),
        ).key;
        selectedArea = savedValue;
      } else {
        sliderIndex = 0;
        selectedArea = workoutLevels[0];
      }
    });
  }

  // 🔹 Save selected workout level to SharedPreferences
  Future<void> _saveSelectedWorkoutLevel(String workoutLevel) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('selectedWorkoutLevel', workoutLevel);
  }

  void saveWorkoutLevelToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && selectedArea != null) {
      await FirebaseFirestore.instance.collection("Users").doc(user.email).set({
        'workoutLevel': selectedArea,
      }, SetOptions(merge: true));
      print("Workout Level saved to Firebase: $selectedArea");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a workout level before proceeding.")),
      );
    }
  }

  // Returns the corresponding color for the current slider index.
  Color get currentLevelColor {
    switch (sliderIndex) {
      case 0:
        return Colors.orange;
      case 1:
        return const Color(0xFFFF4500); // Orange Red
      case 2:
        return Colors.red;
      default:
        return Colors.blueAccent;
    }
  }

  // Returns a gradient for the Next button based on the current level color.
  LinearGradient get nextButtonGradient {
    return LinearGradient(
      colors: [
        currentLevelColor.withOpacity(0.8),
        currentLevelColor.withOpacity(0.6),
      ],
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for a clean look
      appBar: _buildAppBar(context),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
          child: Column(
            children: [
              _buildHeaderText(),
              const SizedBox(height: 20),
              _buildFireIcon(),
              const SizedBox(height: 40),
              _buildSliderFill(),
              const SizedBox(height: 15),
              _buildSliderLabels(),
              const Spacer(),
              _buildNextButton(context),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, // AppBar on white background
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        onPressed: () {
          navigateWithSlideTransition(context, InjurySelection(), slideRight: false);
        },
        icon: const Icon(Icons.arrow_back, color: Colors.black87),
      ),
      title: Text(
        'Workout Level',
        style: GoogleFonts.roboto(
          color: Colors.black87,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildHeaderText() {
    return Column(
      children: [
        Text(
          "What is your Preferred Workout Level?",
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontSize: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Choose how intense and frequent your workouts are",
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.w500,
            color: Colors.grey,
            fontSize: 15,
          ),
        ),
      ],
    );
  }

  // Animated fire icon that switches based on selected workout level.
  Widget _buildFireIcon() {
    String asset;
    switch (sliderIndex) {
      case 0:
        asset = "assets/beginner_fire.gif";
        break;
      case 1:
        asset = "assets/intermediate_fire.gif";
        break;
      case 2:
        asset = "assets/advanced_fire.gif";
        break;
      default:
        asset = "assets/beginner_fire.gif";
    }

    return Center(
      child: Image.asset(
        asset,
        height: 100,
        width: 100,
        fit: BoxFit.contain,
      ),
    );
  }


  // Slider with fill effect using a dynamic color based on selection.
  Widget _buildSliderFill() {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: currentLevelColor,
        inactiveTrackColor: Colors.grey.shade300,
        trackHeight: 8.0,
        thumbColor: currentLevelColor,
        overlayColor: currentLevelColor.withAlpha(32),
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 28.0),
        tickMarkShape: const RoundSliderTickMarkShape(),
        activeTickMarkColor: currentLevelColor,
        inactiveTickMarkColor: Colors.grey,
      ),
      child: Slider(
        value: sliderIndex.toDouble(),
        min: 0,
        max: 2,
        divisions: 2,
        label: workoutLevels[sliderIndex]!.toUpperCase(),
        onChanged: (double value) {
          setState(() {
            sliderIndex = value.round();
            selectedArea = workoutLevels[sliderIndex];
            _saveSelectedWorkoutLevel(selectedArea!);
          });
        },
      ),
    );
  }

  // Labels for each stop on the slider, colored accordingly.
  Widget _buildSliderLabels() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: workoutLevels.entries.map((entry) {
        Color labelColor;
        switch (entry.key) {
          case 0:
            labelColor = Colors.orange;
            break;
          case 1:
            labelColor = const Color(0xFFFF4500);
            break;
          case 2:
            labelColor = Colors.red;
            break;
          default:
            labelColor = Colors.grey;
        }
        return Text(
          entry.value.toUpperCase(),
          style: GoogleFonts.roboto(
            fontWeight: FontWeight.bold,
            color: sliderIndex == entry.key ? labelColor : Colors.grey[400],
          ),
        );
      }).toList(),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (selectedArea != null) {
          saveWorkoutLevelToFirebase();
          _saveSelectedWorkoutLevel(selectedArea!);
          navigateWithSlideTransition(context, Bodyshape(), slideRight: true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Please select a workout level before proceeding.")),
          );
        }
      },
      child: Container(
        height: 55,
        width: 180,
        decoration: BoxDecoration(
          color: AppColor.moresolidPrimary,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColor.backgroundWhite.withOpacity(0.4),
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
