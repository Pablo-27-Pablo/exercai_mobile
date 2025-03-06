import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:flutter/material.dart';
import '../login_register_pages/login.dart';
import '../login_register_pages/createaccount.dart';
import 'package:exercai_mobile/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WelcomeScreen extends StatelessWidget {
  // Current logged-in user
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Future to fetch user details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser?.email)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Fullscreen Background Image
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/welcomescreen.jpg'), // Replace with your image
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Overlay with gradient effect
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.backgroundgrey.withOpacity(1),
                  AppColor.backgroundgrey.withOpacity(0.7),
                  Colors.transparent,
                ],
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
              ),
            ),
          ),
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Fetch and display user's first name
                    FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                      future: getUserDetails(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (snapshot.hasError) {
                          return Text("Error fetching name", style: TextStyle(color: Colors.white));
                        } else if (!snapshot.hasData || !snapshot.data!.exists) {
                          return Text("Welcome, User",
                              style: TextStyle(fontSize: 39, fontWeight: FontWeight.bold, color: Colors.white));
                        }

                        // Extract user's first name
                        Map<String, dynamic>? userData = snapshot.data!.data();
                        String firstName = userData?['firstname'] ?? 'User';

                        return Text(
                          "Welcome, $firstName",
                          style: TextStyle(fontSize: 39, fontWeight: FontWeight.bold, color: Colors.white),
                        );
                      },
                    ),

                    SizedBox(height: 16),
                    // Motivational Message
                    Text(
                      "Consistency Is The Key To Progress.\nDon't Give Up!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFFFEB3B), // Bright yellow text
                      ),
                    ),
                    SizedBox(height: 16),
                    // Subtitle or Description
                    Container(
                      height: 70,
                      color: AppColor.primary,
                      child: Center(
                        child: Text(
                          "You are all set now, let's reach your goals\ntogether with us.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 32),
                    // "Go To Home" Button
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => MainLandingPage()));
                      },
                      style: ElevatedButton.styleFrom(
                        side: BorderSide(color: AppColor.textwhite),
                        padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(50),
                        ),
                        backgroundColor: AppColor.buttonPrimary,
                      ),
                      child: Text(
                        "Go To Home",
                        style: TextStyle(fontSize: 18, color: AppColor.textwhite),
                      ),
                    ),
                    SizedBox(height: 32),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
