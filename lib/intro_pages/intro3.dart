import 'package:exercai_mobile/auth/login_or_register.dart';
import 'package:exercai_mobile/login_register_pages/createaccount.dart';
import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/auth/login_or_register.dart';


class ThirdOnboarding extends StatefulWidget {
  const ThirdOnboarding({super.key});

  @override
  State<ThirdOnboarding> createState() => _ThirdOnboardingState();
}

class _ThirdOnboardingState extends State<ThirdOnboarding> {
  bool showLoginPage = true;

  //toggle between login and register page


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/gym8.jpg'), // Replace with your image
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
                        'Enjoy Exercising While Using\nExercAI',
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
                    _buildIndicator(isActive: false),
                    const SizedBox(width: 8),
                    _buildIndicator(isActive: false),
                    const SizedBox(width: 8),
                    _buildIndicator(isActive: true),
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
                // Add Next functionality
                _showWarningDialog(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'Get Started',
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
void _showWarningDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.yellow.withOpacity(0.6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: Colors.yellow, width: 2),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.info,
              size: 100,
              color: AppColor.yellowtext,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.4),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    "This app is not intended for individuals with medical conditions or physical limitations related to exercise. Please consult a healthcare professional before starting any exercise routine.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
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
                          builder: (context) => LoginOrRegister(initialShowLoginPage: false), // Navigate here
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Proceed',
                      style: TextStyle(
                        color: AppColor.textwhite,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}
