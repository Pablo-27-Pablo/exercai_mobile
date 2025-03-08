import 'package:flutter/material.dart';
import 'intro2.dart';
import 'intro3.dart';
import 'intro1.dart';
import 'package:exercai_mobile/main.dart';
import 'dart:ui';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';



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
          // Background Image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/gym10.jpg'), // Replace with your image path
                fit: BoxFit.cover,
              ),
            ),

          ),
          // Blur Effect
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 1, sigmaY: 1), // Adjust blur intensity
              child: Container(
                color: Colors.black.withOpacity(0.8), // Optional dark overlay
              ),
            ),
          ),

          // Dark Overlay
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 2),
                Image.asset('assets/exercai-front.png',height: 400,width: 400,),
                const SizedBox(height: 8),
              ],
            ),
          ),
          Positioned(
            bottom: 60,
            left: 20,
            right: 20,
            child: ElevatedButton(
              onPressed: () {
                navigateWithSlideTransition(context, OnboardingScreen(), slideRight: true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.withOpacity(0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text(
                'START',
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
