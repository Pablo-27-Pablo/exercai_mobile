import 'package:exercai_mobile/auth/login_or_register.dart';
import 'package:exercai_mobile/login_register_pages/createaccount.dart';
import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/auth/login_or_register.dart';
import 'package:google_fonts/google_fonts.dart'; // Ensure this dependency is added in pubspec.yaml
import 'dart:ui';

class ThirdOnboarding extends StatefulWidget {
  const ThirdOnboarding({super.key});

  @override
  State<ThirdOnboarding> createState() => _ThirdOnboardingState();
}

class _ThirdOnboardingState extends State<ThirdOnboarding> {
  bool showLoginPage = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/gym8.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark Gradient Overlay for improved readability
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.black.withOpacity(0.6),
                    Colors.black.withOpacity(0.3),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          // Middle Content: Card-style container with icon and message
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.directions_run,
                      size: 50,
                      color: AppColor.yellowtext,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Enjoy Exercising While Using\nExercAI',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // Animated Progress Indicators
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIndicator(isActive: false),
                const SizedBox(width: 8),
                _buildIndicator(isActive: false),
                const SizedBox(width: 8),
                _buildIndicator(isActive: true),
              ],
            ),
          ),
          // Bottom Button: Triggers the warning dialog
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                _showWarningDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.solidPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
              child: Text(
                'Get Started',
                style: GoogleFonts.lato(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Widget _buildIndicator({required bool isActive}) {
  return AnimatedContainer(
    duration: const Duration(milliseconds: 300),
    width: isActive ? 16 : 8,
    height: 8,
    decoration: BoxDecoration(
      color: isActive ? AppColor.yellowtext : Colors.grey,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

void _showWarningDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierColor: Colors.black.withOpacity(0.6), // Dim background
    builder: (BuildContext context) {
      return Dialog(
        backgroundColor: Colors.transparent, // Makes the dialog background transparent
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10), // Frosted glass effect
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.yellow.withOpacity(0.8),
                    Colors.orange.withOpacity(0.8)
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
                          builder: (context) => Createaccount(), // Navigate to create account page
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
}

