import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/homepage/starter_page.dart';
import 'package:exercai_mobile/login_register_pages/Whatisyour_target_weight.dart';
import 'package:exercai_mobile/login_register_pages/summary_page.dart';
import 'package:exercai_mobile/login_register_pages/workout_level.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';
import 'package:exercai_mobile/profile_pages/profile_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Bodyshape extends StatefulWidget {
  const Bodyshape({super.key});

  @override
  State<Bodyshape> createState() => _BodyshapeState();
}

class _BodyshapeState extends State<Bodyshape> {
  String? selectedShape;
  String? gender; // Fetched gender from Firestore

  @override
  void initState() {
    super.initState();
    _fetchGender();
  }

  /// Fetch the current user's gender from Firestore.
  Future<void> _fetchGender() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection("Users").doc(user.email).get();
      setState(() {
        gender = doc.get("gender")?.toString().toLowerCase() ?? "male"; // default to male if missing
      });
    } else {
      setState(() {
        gender = "male";
      });
    }
  }

  void selectBodyShape(String shape) {
    setState(() {
      selectedShape = shape;
    });
  }

  Future<void> saveBodyShapeToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && selectedShape != null) {
      await FirebaseFirestore.instance.collection("Users").doc(user.email).set(
        {
          'bodyShape': selectedShape,
        },
        SetOptions(merge: true),
      );
      print("Body Shape saved to Firebase: $selectedShape");
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a body shape before proceeding.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // While waiting for gender to be fetched, show a loading indicator.
    if (gender == null) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator()),
      );
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(context),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "What's Your Current\nBody Shape?",
                textAlign: TextAlign.center,
                style: GoogleFonts.roboto(
                  color: Colors.black87,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                'Slim',
                'You are at a normal level!\nTry our tailored plan to get fitter and healthier!',
                selectedShape,
                "slim",
                imagePath: gender == "male"
                    ? "assets/Slim.png"
                    : "assets/slim_female.jpg",
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                'Average',
                'You may have a slower metabolism\nand face potential health risks.',
                selectedShape,
                "average",
                imagePath: gender == "male"
                    ? "assets/average.jpg"
                    : "assets/average_female.jpg",
              ),
              const SizedBox(height: 20),
              _buildFeatureCard(
                'Heavy',
                'High risk for obesity-related diseases!\nWe can help you turn it around.',
                selectedShape,
                "heavy",
                imagePath: gender == "male"
                    ? "assets/heavy.jpg"
                    : "assets/heavy_female.jpg",
              ),
              const SizedBox(height: 20),
              Center(child: _buildNextButton()),
            ],
          ),
        ),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () {
          navigateWithSlideTransition(context, WhatisyourTargetWeight(), slideRight: false);
        },
        icon: const Icon(Icons.arrow_back, color: AppColor.moresolidPrimary),
      ),
    );
  }

  Widget _buildFeatureCard(String title, String subtitle, String? currentSelection, String shape,
      {required String imagePath}) {
    // Define a color scheme based on shape.
    Color accentColor;
    if (shape == 'slim') {
      accentColor = Colors.green;
    } else if (shape == 'average') {
      accentColor = Colors.orange;
    } else if (shape == 'heavy') {
      accentColor = Colors.red;
    } else {
      accentColor = Colors.black;
    }

    bool isSelected = currentSelection == shape;
    return GestureDetector(
      onTap: () => selectBodyShape(shape),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        height: 140,
        decoration: BoxDecoration(
          color: isSelected ? accentColor.withOpacity(0.2) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isSelected ? accentColor : Colors.grey.shade300, width: 2),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: accentColor.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              )
          ],
        ),
        child: Row(
          children: [
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.roboto(
                        color: accentColor,
                        fontSize: 23,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: GoogleFonts.roboto(
                        color: Colors.black87,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(20)),
                child: Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  height: 140,
                  width: double.infinity,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey,
                      child: const Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.white,
                          size: 40,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: () {
          saveBodyShapeToFirebase();
          navigateWithSlideTransition(context, SummaryBodyMetricsPage(), slideRight: true);
      },
      child: Container(
        height: 55,
        width: 180,
        decoration: BoxDecoration(
          color: AppColor.moresolidPrimary,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: AppColor.primary.withOpacity(0.4),
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

  /*void _showWarningDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.6),
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.yellow.withOpacity(0.8),
                      Colors.orange.withOpacity(0.8),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.yellow, width: 2),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.info,
                      size: 100,
                      color: AppColor.yellowtext,
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "This app is not intended for individuals with medical conditions or physical limitations related to exercise. Please consult a healthcare professional before starting any exercise routine.",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: AppColor.textwhite,
                      ),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => WelcomeScreen(), // Navigate to the next page
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.solidPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Proceed',
                        style: GoogleFonts.lato(
                          color: AppColor.textwhite,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }*/
}

