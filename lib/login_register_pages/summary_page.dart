import 'package:exercai_mobile/homepage/starter_page.dart';
import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:ui';

class SummaryBodyMetricsPage extends StatefulWidget {
  const SummaryBodyMetricsPage({Key? key}) : super(key: key);

  @override
  State<SummaryBodyMetricsPage> createState() => _SummaryBodyMetricsPageState();
}

class _SummaryBodyMetricsPageState extends State<SummaryBodyMetricsPage> {
  bool isLoading = true;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Fetch user data from Firestore
  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => isLoading = false);
      return;
    }

    final doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .get();

    if (!doc.exists) {
      setState(() => isLoading = false);
      return;
    }

    setState(() {
      userData = doc.data();
      isLoading = false;
    });
  }

  // Convert each word's first letter to uppercase
  String toTitleCase(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1);
    }).join(' ');
  }

  // Clamps BMI to [15..40] range and returns a 0..1 fraction
  double _bmiToSliderValue(double bmi) {
    const double minBmi = 15.0; // Left boundary
    const double maxBmi = 40.0; // Right boundary
    if (bmi <= minBmi) return 0.0;
    if (bmi >= maxBmi) return 1.0;
    return (bmi - minBmi) / (maxBmi - minBmi);
  }

  // Decide which image to show based on gender
  String _getGenderAsset(String gender) {
    return gender.toLowerCase() == 'female'
        ? 'assets/female.jpg'
        : 'assets/male.jpg';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      // Simple AppBar
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: BackButton(color: Colors.black87),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(),
    );
  }

  Widget _buildBody() {
    if (userData == null) {
      return const Center(child: Text("No user data found."));
    }

    // Extract fields from userData
    final age = userData?['age']?.toString() ?? '-';
    final double userBmi = double.tryParse('${userData?['bmi']}') ?? 0.0;
    final bmiCategory = userData?['bmiCategory']?.toString() ?? '-';
    final bodyShape = toTitleCase(userData?['bodyShape']?.toString() ?? '-');
    final gender = userData?['gender']?.toString() ?? 'male';
    final double userHeight = double.tryParse('${userData?['height']}') ?? 0.0;
    final double userWeight = double.tryParse('${userData?['weight']}') ?? 0.0;
    final double userTarget =
        double.tryParse('${userData?['targetWeight']}') ?? 0.0;
    final nutriActivitylevel =
        userData?['nutriActivitylevel']?.toString() ?? '-';
    final injuryArea = toTitleCase(userData?['injuryArea']?.toString() ?? '-');
    final goal = toTitleCase(userData?['goal']?.toString() ?? '-');
    final workoutLevel = toTitleCase(userData?['workoutLevel']?.toString() ?? '-');

    // Weight goal difference
    double weightGoalDiff = userTarget - userWeight;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            // Page Title
            Text(
              "Summary of User Input",
              style: GoogleFonts.poppins(
                color: Colors.black87,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            // BMI card at the top
            _buildBMICard(userBmi, bmiCategory),
            const SizedBox(height: 16),
            // Main content with two columns
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left column with stats
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      _buildStatCard("Age", age),
                      const SizedBox(height: 8),
                      _buildStatCard("Current Weight", "${userWeight.toStringAsFixed(1)} kg"),
                      const SizedBox(height: 8),
                      _buildStatCard(
                        "Weight Goal",
                        "${weightGoalDiff >= 0 ? "+" : ""}${weightGoalDiff.toStringAsFixed(1)} kg",
                        highlightColor: weightGoalDiff < 0 ? Colors.red : Colors.green,
                      ),
                      const SizedBox(height: 8),
                      _buildStatCard("Body Shape", bodyShape),
                      const SizedBox(height: 8),
                      _buildStatCard("Height", "${userHeight.toStringAsFixed(1)} cm"),
                      const SizedBox(height: 8),
                      _buildStatCard("Activity", nutriActivitylevel),
                      const SizedBox(height: 8),
                      _buildStatCard("Goal", goal),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right column: image at top, then Injuries and Workout Level
                Expanded(
                  flex: 1,
                  child: Column(
                    children: [
                      Center(
                        child: Image.asset(
                          _getGenderAsset(gender),
                          height: 260,
                          fit: BoxFit.contain,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildStatCard("Injuries", injuryArea),
                      const SizedBox(height: 8),
                      _buildStatCard("Workout Level", workoutLevel),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // Continue button
            SizedBox(
              width: double.infinity,
              height: 60,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.moresolidPrimary,
                  foregroundColor: AppColor.backgroundWhite,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  textStyle: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onPressed: () {
                  _showWarningDialog(context);
                },
                child: const Text("Get Started"),
              ),
            ),
            const SizedBox(height: 15,)
          ],
        ),
      ),
    );
  }
// Example function showing a redesigned warning dialog
  void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.5), // Darken background slightly
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // The frosted background
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.3), // Semi-transparent white
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.white.withOpacity(0.2), width: 1),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Minimalist icon
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.info_outline_rounded,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Warning text
                        Text(
                          "This app is not intended for individuals with medical conditions or physical limitations related to exercise. Please consult a healthcare professional before starting any exercise routine.",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.poppins(
                            fontWeight: FontWeight.w500,
                            fontSize: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Proceed button
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => WelcomeScreen(), // Navigate to create account page
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.supersolidPrimary,
                            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 5,
                          ),
                          child: Text(
                            'Proceed',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }


  // BMI card with color scale
  Widget _buildBMICard(double bmiValue, String bmiCategory) {
    final double sliderValue = _bmiToSliderValue(bmiValue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row: "Current BMI" and category label
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Current BMI",
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Row(
                children: [
                  Text(
                    bmiCategory.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(width: 6),
                  const Icon(Icons.info_outline, size: 18, color: Colors.grey),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // BMI value
          Text(
            "${bmiValue.toStringAsFixed(1)} BMI",
            style: GoogleFonts.poppins(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // The color scale with 5 stops: Underweight, Normal, Overweight, Obese, Extremely Obese
          _buildColorScale(sliderValue),
          const SizedBox(height: 12),
          // Show 5 labels for each category
          _buildBmiLabelsRow(),
        ],
      ),
    );
  }

  // A color scale with five stops, clamped at either end
  Widget _buildColorScale(double sliderValue) {
    final double totalWidth = MediaQuery.of(context).size.width - 32;
    final double indicatorLeft = (totalWidth * sliderValue) - 6;

    return Stack(
      children: [
        Container(
          height: 10,
          decoration: BoxDecoration(
            // 5 color stops: teal->green->orange->red->dark red
            gradient: const LinearGradient(
              colors: [
                Color(0xFF00B4D8), // Underweight
                Color(0xFF48BB78), // Normal
                Color(0xFFFFBB00), // Overweight
                Color(0xFFFF6633), // Obese
                Color(0xFFFA5252), // Extremely Obese
              ],
              stops: [0.0, 0.25, 0.50, 0.75, 1.0],
            ),
            borderRadius: BorderRadius.circular(5),
          ),
        ),
        // The indicator dot
        Positioned(
          left: indicatorLeft.clamp(0, totalWidth - 12),
          child: Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  // Five labels for the BMI categories
  Widget _buildBmiLabelsRow() {
    // We space them out evenly in a row.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _bmiLabel("Underweight\n<18.5"),
        _bmiLabel("Normal\n18.5-24.9"),
        _bmiLabel("Overweight\n25-29.9"),
        _bmiLabel("Obese\n30-34.9"),
        _bmiLabel("Extremely Obese\n≥35"),
      ],
    );
  }

  Widget _bmiLabel(String text) {
    return Expanded(
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 10,
          color: Colors.grey[700],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // A stat card that allows wrapping if needed.
  Widget _buildStatCard(String label, String value, {Color? highlightColor}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Text(
            label,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 4),
          // Value with wrapping enabled
          Text(
            value,
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: highlightColor ?? Colors.black87,
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
