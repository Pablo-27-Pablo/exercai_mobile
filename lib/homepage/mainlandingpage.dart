import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/components/my_drawer.dart';
import 'package:exercai_mobile/different_exercises/all_exercises.dart';
import 'package:exercai_mobile/different_exercises/choose_bodyparts.dart';
import 'package:exercai_mobile/exercise_posture/exerciseposturepage1.dart';
import 'package:exercai_mobile/food_nutrition/nutrition_calculator_firebase.dart';
import 'package:exercai_mobile/local_notification/reminder_settings.dart';
import 'package:exercai_mobile/profile_pages/bmi_settings.dart';
import 'package:exercai_mobile/profile_pages/profile_page.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/progress_tracking/progress_tracking..dart';
import 'package:exercai_mobile/show_firestore_exercises_download/show_with_reps_kcals/filter_reps_kcal.dart';
import 'package:exercai_mobile/pages/Main_Pages/Exercises_Page.dart';
import 'package:exercai_mobile/pages/arcade_mode_page.dart';
import 'package:exercai_mobile/utils/music_background.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:google_fonts/google_fonts.dart';

class MainLandingPage extends StatefulWidget {
  const MainLandingPage({super.key});

  @override
  State<MainLandingPage> createState() => _MainLandingPageState();
}


class _MainLandingPageState extends State<MainLandingPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  get musicPlayer => MusicPlayerService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkInternetConnection();
    });
    musicPlayer.stop();
  }

  /// Check internet connection and show a warning if not connected.
  Future<void> _checkInternetConnection() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isEmpty || result[0].rawAddress.isEmpty) {
        _showNoInternetDialog();
      }
    } on SocketException catch (_) {
      _showNoInternetDialog();
    }
  }

  /// Show a dialog if no internet connection is detected.
  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // Prevent closing by tapping outside.
      builder: (BuildContext context) {
        return AlertDialog(
          // Rounded shape for a modern look
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          // White background for the main body
          backgroundColor: Colors.white,
          // We set zero padding so we can control spacing precisely in the content
          titlePadding: EdgeInsets.zero,
          contentPadding: EdgeInsets.zero,
          actionsPadding: EdgeInsets.only(bottom: 8, right: 8),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Gradient header with a "no-wifi" icon
              Container(
                height: 100,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.blue.shade400,
                      Colors.blueAccent.shade200,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                child: Center(
                  child: Icon(
                    Icons.wifi_off_rounded,
                    color: Colors.white,
                    size: 50,
                  ),
                ),
              ),

              // Title
              const SizedBox(height: 16),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "No Internet Connection",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueAccent,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Message
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text(
                  "Some features may not work properly and your progress may not be saved.\n\n"
                      "Please connect to the internet to continue.",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: Colors.black87),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),

          // Action buttons at the bottom
          actions: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey.shade500, // Retry button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text("Continue Offline",style: TextStyle(color: Colors.white),),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent, // Retry button color
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                    _checkInternetConnection(); // Retry connection. // Calls your custom retry function
                  },
                  child: const Text("Retry",style: TextStyle(color: Colors.white),),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// Future to fetch user details.
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser?.email)
        .get();
  }

  /// Capitalizes the first letter of each word.
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text
        .split(' ')
        .map(
          (word) =>
              word.isNotEmpty
                  ? word[0].toUpperCase() + word.substring(1).toLowerCase()
                  : word,
        )
        .join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White minimalist background.
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
          stream:
              FirebaseFirestore.instance
                  .collection('Users')
                  .doc(currentUser?.email)
                  .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text(
                "Error fetching name",
                style: TextStyle(color: AppColor.backgroundWhite),
              );
            } else if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Text(
                "Hi, User",
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: AppColor.backgroundWhite,
                ),
              );
            }
            Map<String, dynamic>? userData = snapshot.data!.data();
            String firstName = _capitalize(userData?['firstname'] ?? 'User');
            return Text(
              "Hi, $firstName",
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: AppColor.backgroundWhite,
              ),
            );
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.person,
              color: AppColor.backgroundWhite,
              size: 35,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
            },
          ),
        ],
      ),
      drawer: const MyDrawer(),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Text
          Container(
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            height: 50,

            child: Center(
              child: Text(
                "Push Your Limits",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColor.backgroundWhite,
                ),
              ),
            ),
          ),

          // Feature Icons Row
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                bottom: 20,
                top: 20,
              ),
              child: Column(
                children: [
                  //SizedBox(height: 15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildFeatureIcon(Icons.alarm, "Reminder", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ReminderSettings(),
                          ),
                        );
                      }),
                      _buildFeatureIcon(Icons.show_chart, "Track", () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProgressTrackingScreen(),
                          ),
                        );
                      }),
                      _buildFeatureIcon(
                        Icons.food_bank_rounded,
                        "Nutrition",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => NutritionCalculatorFirebase(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureIcon(
                        Icons.settings_accessibility,
                        "BMI",
                        () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BMIEditProfilePage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                  // Column layout for Feature Cards (stacked vertically)
                  Row(
                    
                    children: [
                      SizedBox(width: 20,),
                      Text(
                        "Features",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColor.backgroundgrey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildFeatureCard(
                    title: 'Posture Correction',
                    subtitle: 'Correct Your Posture With Targeted Exercises',
                    imagePath: 'assets/mainpage/posture.png',
                    onTap: () {
                      Mode = "postureCorrection";
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => Trypage()),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    title: 'Arcade Mode',
                    subtitle: 'Fun Challenges To Push Your Limits',
                    imagePath: 'assets/mainpage/arcade-machine.png',
                    onTap: () {
                      int last = peopleBox.get("final", defaultValue: 0);
                      if (last < 1) {
                        peopleBox.put("squat", 0);
                        peopleBox.put("legraises", 0);
                        peopleBox.put("pushup", 0);
                        peopleBox.put("situp", 0);
                        peopleBox.put("finalcoloriesburn", 0);
                        peopleBox.put("final", 5);
                      }
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArcadeModePage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    title: 'Recommended Exercise',
                    subtitle: 'Recommended Exercises For Your Needs',
                    imagePath: 'assets/mainpage/recommend.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FilterRepsKcal(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 10),
                  _buildFeatureCard(
                    title: 'Different Exercises',
                    subtitle: 'Explore A Variety Of Workouts',
                    imagePath: 'assets/mainpage/different.png',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChooseBodyparts(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureIcon(IconData icon, String title, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.primary.withOpacity(0.05),
            ),
            child: Icon(icon, color: AppColor.backgroundgrey, size: 40),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: GoogleFonts.poppins(fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // Column-style feature card: Image on top, text content below.
  // Feature card with image on the left and text on the right.
  Widget _buildFeatureCard({
    required String title,
    required String subtitle,
    required String imagePath,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 5,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        clipBehavior: Clip.antiAlias,
        color: Colors.white,
        child: Row(
          children: [
            // Image on the left.
            Padding(
              padding: const EdgeInsets.only(left: 5.0, right: 5.0),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                child: Image.asset(
                  imagePath,
                  height: 140,
                  width: 100,
                  fit: BoxFit.contain,
                ),
              ),
            ),
            // Text content on the right.
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                //color: Colors.white,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        color: Colors.black87,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      style: GoogleFonts.poppins(
                        color: Colors.black54,
                        fontSize: 14,
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
