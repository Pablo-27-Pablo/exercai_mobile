import 'package:exercai_mobile/auth/login_or_register.dart';
import 'package:exercai_mobile/food_nutrition/nutrients_show_screen.dart';
import 'package:exercai_mobile/food_nutrition/nutrition_calculator_firebase.dart';
import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:exercai_mobile/local_notification/reminder_settings.dart';
import 'package:exercai_mobile/login_register_pages/login.dart';
import 'package:exercai_mobile/month_log_exercise/month_note_exercise.dart';
import 'package:exercai_mobile/predictive_graph/predictive_graph_analysis.dart';
import 'package:exercai_mobile/profile_pages/bmi_settings.dart';
import 'package:exercai_mobile/profile_pages/profile_page_proffile.dart';
import 'package:exercai_mobile/profile_pages/profile_page_setting.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';
import '../login_register_pages/login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exercai_mobile/progress_tracking/progress_tracking..dart';
import 'package:google_fonts/google_fonts.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // Current logged in user
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Future to fetch user's details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  Future<void> logout(BuildContext context) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_token'); // Clear session

    FirebaseAuth.instance.signOut();

    // Prevent going back to the previous page
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
      (route) => false,
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Confirm Logout",
            style: GoogleFonts.poppins(
              color: Colors.black87,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "Are you sure you want to log out?",
            style: GoogleFonts.poppins(color: Colors.black54),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text(
                "Cancel",
                style: GoogleFonts.poppins(color: Colors.blue),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                logout(context);
              },
              child: Text(
                "Logout",
                style: GoogleFonts.poppins(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  String computeAge(Timestamp? dob) {
    if (dob == null) return "N/A";
    DateTime birthDate = dob.toDate();
    DateTime today = DateTime.now();

    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age.toString();
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Crisp white background
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'My Profiles',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainLandingPage()),
            );
          },
          icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
        ),
        elevation: 0,
        backgroundColor: AppColor.primary,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColor.superlightPrimary, AppColor.primary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          // Loading state
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          // Error state
          else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          // Data received
          else if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();

            return SingleChildScrollView(
              child: Column(
                children: [
                  // Header with gradient and inline avatar/details
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColor.superlightPrimary, AppColor.primary],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        bottom: 30,
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 40,
                              backgroundColor: Colors.white,
                              child: Text(
                                // User's initials
                                "${_capitalize(user?['firstname']?[0] ?? 'U')}${_capitalize(user?['lastname']?[0] ?? 'U')}",
                                style: TextStyle(
                                  fontSize: 30,

                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SizedBox(width: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "${_capitalize(user?['firstname'] ?? 'Unknown')} ${_capitalize(user?['lastname'] ?? 'User')}",
                                  style: TextStyle(
                                    fontSize: 22,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 6),
                                Text(
                                  user?['email'] ?? 'No Email Provided',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.white70,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Metrics section with a soft elevated card
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Card(
                      color: AppColor.backgroundWhite,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 3,
                      shadowColor: AppColor.backgroundgrey,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 15,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _infoMetric(
                              user?['weight'].toString() ?? 'N/A',
                              'Weight (kg)',
                            ),
                            _infoMetric(
                              computeAge(user?['dateOfBirth']),
                              'Age',
                            ),
                            _infoMetric(
                              user?['height'].toString() ?? 'N/A',
                              'Height (cm)',
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Options section with custom interactive tiles
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Column(
                      children: [
                        _customOptionTile(Icons.person, 'Profile', () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ProfilePageProfile(),
                            ),
                          );
                        }),
                        _customOptionTile(
                          Icons.show_chart,
                          'Progress Tracking',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProgressTrackingScreen(),
                              ),
                            );
                          },
                        ),
                        _customOptionTile(
                          Icons.settings_accessibility,
                          'BMI and Other Settings',
                          () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => BMIEditProfilePage(),
                              ),
                            );
                          },
                        ),
                        _customOptionTile(
                          Icons.food_bank_outlined,
                          'Nutrition and Calories',
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => NutritionCalculatorFirebase(),
                              ),
                            );
                          },
                        ),
                        _customOptionTile(
                          Icons.alarm,
                          'Set Reminders',
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ReminderSettings(),
                              ),
                            );
                          },
                        ),
                        _customOptionTile(
                          Icons.monitor_weight_outlined,
                          'Weight Analysis',
                              () {
                                // Get the current user's email from FirebaseAuth.
                                final userEmail = FirebaseAuth.instance.currentUser?.email;
                                if (userEmail != null) {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PredictiveAnalysisPage(userEmail: userEmail),
                                    ),
                                  );
                                } else {
                                  // Handle the case where the email is null.
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text("No user email available.")),
                                  );
                                }
                          },
                        ),
                        _customOptionTile(
                          Icons.calendar_month_outlined,
                          'Log Exercise Date',
                              () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MonthExercisePage(),
                              ),
                            );
                          },
                        ),
                        _customOptionTile(Icons.logout, 'Logout', () {
                          _showLogoutConfirmationDialog(context);
                        }),
                      ],
                    ),
                  ),
                  SizedBox(height: 30),
                ],
              ),
            );
          } else {
            return Center(child: Text('No Data Available'));
          }
        },
      ),
    );
  }

  // Helper widget for metric display
  Widget _infoMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            color: AppColor.backgroundgrey,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
      ],
    );
  }

  // Helper widget for custom option tiles
  Widget _customOptionTile(IconData icon, String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      splashColor: AppColor.superlightPrimary.withOpacity(0.2),
      child: Container(
        margin: EdgeInsets.only(bottom: 15),
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
          border: Border.all(color: Colors.grey.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColor.superlightPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: AppColor.backgroundgrey),
            ),
            SizedBox(width: 20),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: AppColor.backgroundgrey.withOpacity(0.6),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
