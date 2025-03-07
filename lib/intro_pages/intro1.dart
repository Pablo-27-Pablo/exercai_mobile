
import 'package:exercai_mobile/intro_pages/intro2.dart';
import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';


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
                image: AssetImage('assets/gym5.jpg'), // Replace with your image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Top Skip Button
          /*Positioned(
            top: 40,
            right: 20,
            child: TextButton(
              onPressed: () {
                // Add Skip functionality
              },
              child: Row(
                children: const [
                  Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColor.yellowtext,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Icon(
                    Icons.play_arrow_rounded,
                    color: AppColor.yellowtext,
                    size: 16,
                  ),
                ],
              ),
            ),
          ),*/
          // Middle Content
          Align(
            alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: double.infinity, // Makes it expand across the screen
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                  margin: const EdgeInsets.symmetric(horizontal: 0), // Remove margin to fully expand
                  decoration: BoxDecoration(
                    color: AppColor.primary.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(0), // Keeps rounded corners
                  ),
                  child: Column(
                    children: const [
                      Icon(
                        Icons.directions_run,
                        size: 40,
                        color: Colors.yellow,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Start Real-Time Exercise Journey Towards\nA More Active Lifestyle',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildIndicator(isActive: true),
                    const SizedBox(width: 8),
                    _buildIndicator(isActive: false),
                    const SizedBox(width: 8),
                    _buildIndicator(isActive: false),
                  ],
                ),
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
                backgroundColor: Colors.grey.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Next',
                style: TextStyle(
                  fontSize: 16,
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
  return Container(
    width: isActive ? 12 : 8,
    height: 8,
    decoration: BoxDecoration(
      color: isActive ? AppColor.yellowtext : Colors.grey,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}
