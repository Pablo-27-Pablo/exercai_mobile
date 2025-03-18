import 'package:exercai_mobile/intro_pages/intro2.dart';
import 'package:exercai_mobile/intro_pages/openingpage.dart';
import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';
import 'package:google_fonts/google_fonts.dart'; // Add this dependency in your pubspec.yaml


class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/gym5.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Dark Gradient Overlay for improved text contrast
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
          Positioned(
            top: 40,
            left: 10,
            child: TextButton(
              onPressed: () {
                navigateWithSlideTransition(context, WelcomePage(), slideRight: false);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                textStyle: GoogleFonts.lato(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              child: Row(
                children: const [
                  Icon(Icons.arrow_back_ios, size: 30),
                ],
              ),
            ),
          ),
          // Top Skip Button
          // Middle Content: Main Card with icon & message
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
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
                    )
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
                      'Embark on a Real-Time Exercise Journey Towards\nA More Active Lifestyle',
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
          // Progress Indicators
          Positioned(
            bottom: 110,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIndicator(isActive: true),
                const SizedBox(width: 8),
                _buildIndicator(isActive: false),
                const SizedBox(width: 8),
                _buildIndicator(isActive: false),
              ],
            ),
          ),
          // Bottom Button
          Positioned(
            bottom: 40,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                navigateWithSlideTransition(context, SecondOnboarding(), slideRight: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.moresolidPrimary,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 8,
              ),
              child: Text(
                'Next',
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
