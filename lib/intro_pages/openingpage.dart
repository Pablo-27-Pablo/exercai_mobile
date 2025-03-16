import 'package:flutter/material.dart';
import 'intro2.dart';
import 'intro3.dart';
import 'intro1.dart';
import 'package:exercai_mobile/main.dart';
import 'dart:ui';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';
import 'package:google_fonts/google_fonts.dart'; // Add dependency in your pubspec.yaml
import 'package:exercai_mobile/main.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Vibrant gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Colors.deepPurple.shade800,
                  Colors.deepPurple.shade400,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          // Gym image overlay with darkening effect for text readability
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/gym10.jpg'),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(Colors.black54, BlendMode.darken),
                ),
              ),
            ),
          ),
          // Decorative shape in the top-left corner
          Positioned(
            top: -40,
            left: -40,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.lightPrimary.withOpacity(0.3),
              ),
            ),
          ),
          // Decorative shape in the bottom-right corner
          Positioned(
            bottom: -50,
            right: -50,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColor.solidPrimary.withOpacity(0.3),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Main Logo or Illustration
                        Image.asset(
                          'assets/exercai-front.png',
                          height: 400,
                          width: 400,
                        ),
                        // Fitness-Themed Tagline
                        Text(
                          "Train Hard, Achieve More",
                          textAlign: TextAlign.center,
                          style: GoogleFonts.lato(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Call-to-Action Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
                  child: ElevatedButton.icon(
                    onPressed: () {
                      navigateWithSlideTransition(context, OnboardingScreen(), slideRight: true);
                    },
                    icon: const Icon(Icons.arrow_forward, color: Colors.white),
                    label: Text(
                      "Start Exercising",
                      style: GoogleFonts.lato(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.solidPrimary,
                      minimumSize: const Size(double.infinity, 60),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 8,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
