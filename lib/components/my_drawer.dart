import 'package:exercai_mobile/components/my_drawer.dart';
import 'package:exercai_mobile/login_register_pages/login.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/month_log_exercise/month_note_exercise.dart';
import 'package:exercai_mobile/predictive_graph/predictive_graph_analysis.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout(BuildContext context) async {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(
            "Confirm Logout",
            style: GoogleFonts.poppins(color: Colors.black87, fontWeight: FontWeight.bold),
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
                style: GoogleFonts.poppins(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  // A helper function to capitalize the first letter of each word.
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Colors.white, // White background for a minimalist look.
      child: Column(
        children: [
          // Drawer Header with user info.
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.white,
            ),
            child: Row(
              children: [
                // Display a circular avatar placeholder.
/*                CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.grey.shade300,
                  child: const Icon(Icons.person, color: Colors.white, size: 30),
                ),*/
                const SizedBox(width: 16),
                // Fetch and show user first name.
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: FirebaseFirestore.instance
                      .collection("Users")
                      .doc(FirebaseAuth.instance.currentUser?.email)
                      .get(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return Text("User",
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87));
                    } else if (!snapshot.hasData || !snapshot.data!.exists) {
                      return Text("User",
                          style: GoogleFonts.poppins(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87));
                    }

                    Map<String, dynamic>? userData = snapshot.data!.data();
                    String firstName = _capitalize(userData?['firstname'] ?? 'User');
                    String lastName = _capitalize(userData?['lastname'] ?? '');

                    // Combine First Name and Last Name
                    String fullName = '$firstName $lastName'.trim();

                    return Text(
                      fullName,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    );
                  },
                )
              ],
            ),
          ),

          // Drawer ListTiles – wrapped in an Expanded ListView.
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerTile(
                  icon: Icons.home,
                  title: "Home",
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.person,
                  title: "Profile",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/profile_page');
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.show_chart,
                  title: "Progress Tracking",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/progress_tracking');
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.settings_accessibility,
                  title: "BMI Settings",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/bmi_settings');
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.food_bank,
                  title: "Nutrition And Calories",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/nutrition');
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.alarm,
                  title: "Set Reminders",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/reminder');
                  },
                ),
                _buildDrawerTile(
                  icon: Icons.monitor_weight_outlined,
                  title: "Weight Analysis",
                  onTap: () {
                    Navigator.pop(context);
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
                _buildDrawerTile(
                  icon: Icons.calendar_month_outlined,
                  title: "Log Exercise Date",
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(context, MaterialPageRoute(builder: (context)=>MonthExercisePage()));
                  },
                ),
              ],
            ),
          ),
          // Logout Tile at the bottom.
          Padding(
            padding: const EdgeInsets.only(left: 25, bottom: 25),
            child: _buildDrawerTile(
              icon: Icons.logout,
              title: "Logout",
              onTap: () {
                _showLogoutConfirmationDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  // Drawer tile builder.
  Widget _buildDrawerTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.grey.shade200,
        ),
        padding: const EdgeInsets.all(8),
        child: Icon(
          icon,
          color: AppColor.moresolidPrimary,
          size: 20,
        ),
      ),
      title: Text(
        title,
        style: GoogleFonts.poppins(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
