import 'package:flutter/material.dart';
import 'intro2.dart';
import 'intro3.dart';
import 'intro1.dart';
import 'package:exercai_mobile/main.dart';
import 'dart:ui';



class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
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
                  color: Colors.black.withOpacity(0.5), // Optional dark overlay
                ),
              ),
            ),

            // Dark Overlay
            // Content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Welcome to',
                    style: TextStyle(
                      color: AppColor.yellowtext,
                      fontSize: 40,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'E',
                              style: TextStyle(
                                color: AppColor.purpletext,
                                fontSize: 140,
                                fontStyle: FontStyle.italic, // Italicized
                                fontWeight: FontWeight.normal, // Not bold
                              ),
                            ),
                            TextSpan(
                              text: 'AI',
                              style: TextStyle(
                                color: AppColor.purpletext,
                                fontSize: 140 ,
                                fontStyle: FontStyle.italic, // Italicized
                                fontWeight: FontWeight.bold, // Bold
                              ),
                            ),
                          ],
                        ),
                      ),
        
                      const SizedBox(width: 1),
                      const Icon(
                        Icons.local_fire_department,
                        color: AppColor.yellowtext,
                        size: 140,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'EXERC',
                          style: TextStyle(
                            color: AppColor.yellowtext,
                            fontSize: 50,
                            fontWeight: FontWeight.normal, // Not bold
                            fontStyle: FontStyle.italic, // Italicized
                          ),
                        ),
                        TextSpan(
                          text: 'AI',
                          style: TextStyle(
                            color: AppColor.yellowtext,
                            fontSize: 50,
                            fontWeight: FontWeight.bold, // Bold
                            fontStyle: FontStyle.italic, // Italicized
                          ),
                        ),
                      ],
                    ),
                  ),
        
        
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
