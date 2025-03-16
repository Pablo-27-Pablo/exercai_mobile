import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:exercai_mobile/main.dart';
import '../login_register_pages/login.dart';
import '../login_register_pages/createaccount.dart';

// A helper to convert each word's first letter to uppercase.
String toTitleCase(String text) {
  if (text.isEmpty) return text;
  return text
      .split(' ')
      .map((word) => word.isNotEmpty
      ? word[0].toUpperCase() + word.substring(1).toLowerCase()
      : word)
      .join(' ');
}

class WelcomeScreen extends StatelessWidget {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser?.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Minimalist white background
      body: SafeArea(
        child: Stack(
          children: [
            // Subtle circular accent in the background (top-right)
            Positioned(
              top: -50,
              right: -50,
              child: Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: AppColor.superlightPrimary.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Subtle circular accent in the background (bottom-left)
            Positioned(
              bottom: -70,
              left: -70,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  color: AppColor.lightPrimary.withOpacity(0.6),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Main content
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Fetch and display user's first name in Title Case
                    FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: getUserDetails(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text(
                            "Error Fetching Name",
                            style: GoogleFonts.poppins(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          );
                        } else if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Text(
                            "Welcome, User",
                            style: GoogleFonts.poppins(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          );
                        }

                        Map<String, dynamic>? userData = snapshot.data!.data();
                        String firstName = userData?['firstname'] ?? 'User';
                        // Convert to Title Case
                        firstName = toTitleCase(firstName);

                        return Text(
                          "Welcome, $firstName",
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    // Motivational Quote
                    Text(
                      "Consistency Is The Key To Progress.\nDon't Give Up!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Sub-Message
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "You are all set now. Let's reach your goals together!",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Go To Home Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MainLandingPage()),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColor.moresolidPrimary,
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        elevation: 5,
                      ),
                      child: Text(
                        "Go To Home",
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
