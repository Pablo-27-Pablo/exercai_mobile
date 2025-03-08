import 'package:exercai_mobile/auth/login_or_register.dart';
import 'package:exercai_mobile/login_register_pages/login.dart';
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




class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {

  //current login user
  final User? currentUser = FirebaseAuth.instance.currentUser;

  //future to fetch users details
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails()async{
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
      MaterialPageRoute(builder: (context) => LoginPage(onTap: () => login(context))),
          (route) => false, // Removes all previous routes
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                logout(context); // Call the logout function
              },
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }



  String computeAge(Timestamp? dob) {
    if (dob == null) return "N/A"; // Handle missing DOB

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
      appBar: AppBar(

        title: Text('My Profile',
            style: TextStyle(
                color: AppColor.textwhite, fontWeight: FontWeight.bold)),
        backgroundColor: AppColor.primary,
        elevation: 0,
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // Error
          else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          // Data received
          else if (snapshot.hasData) {
            // Extract user data
            Map<String, dynamic>? user = snapshot.data!.data();

            return Column(
              children: [
                // Profile header section
                Container(
                  color: AppColor.primary,
                  padding: EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      /*CircleAvatar(
                        radius: 50,
                        backgroundImage: AssetImage(
                            'assets/MikoProfile.jpg'), // Use a default image or user's image if available
                      ),*/
                      SizedBox(height: 10),

                      // Display User's Name from Firebase
                      Text(
                        "${_capitalize(user?['firstname'] ?? 'Unknown')} ${_capitalize(user?['lastname'] ?? 'User')}",
                        style: TextStyle(
                          fontSize: 40,
                          color: AppColor.textwhite,
                          fontWeight: FontWeight.bold,
                        ),
                      ),


                      SizedBox(height: 5),

                      // Display User's Email from Firebase
                      Text(
                        user?['email'] ?? 'No Email Provided',
                        style: TextStyle(
                          fontSize: 17,
                          color: AppColor.textwhite.withOpacity(0.7),
                        ),
                      ),
                      SizedBox(height: 15),

                      Container(
                        margin: EdgeInsets.only(left: 60, right: 60),
                        padding: EdgeInsets.only(top: 15, bottom: 15),
                        decoration: BoxDecoration(
                            color: AppColor.shadow.withOpacity(0.5),
                            borderRadius: BorderRadius.circular(14)),
                        child: Row(
                          children: [
                            Expanded(child: _infoCard(user?['weight'] ?? 'No Weight Provided', 'Weight (kg)')),
                            Column(
                              children: [
                                Text("|", style: TextStyle(color: AppColor.textwhite.withOpacity(0.5))),
                                Text("|", style: TextStyle(color: AppColor.textwhite.withOpacity(0.5))),
                                Text("|", style: TextStyle(color: AppColor.textwhite.withOpacity(0.5))),
                              ],
                            ),
                            Expanded(child: _infoCard(computeAge(user?['dateOfBirth']), 'Years Old')),
                            Column(
                              children: [
                                Text("|", style: TextStyle(color: AppColor.textwhite.withOpacity(0.5))),
                                Text("|", style: TextStyle(color: AppColor.textwhite.withOpacity(0.5))),
                                Text("|", style: TextStyle(color: AppColor.textwhite.withOpacity(0.5))),
                              ],
                            ),
                            Expanded(child: _infoCard(user?['height'] ?? 'No Height Provided', 'Height (cm)')),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Options section
                Expanded(
                  child: Container(
                    color: AppColor.backgroundgrey,
                    child: ListView(
                      children: [
                        _optionTile(Icons.person, 'Profile', () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePageProfile()));
                        }),
                        _optionTile(Icons.track_changes_outlined, 'Progress Tracking', () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProgressTrackingScreen()));
                        }),

                        _optionTile(Icons.settings_accessibility, 'BMI and Other Settings', () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => BMIEditProfilePage()));
                        }),
                        /*_optionTile(Icons.settings, 'Settings', () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => ProfilePageSetting()));
                        }),*/
                        /*_optionTile(Icons.logout, 'Logout', () {
                          logout(context);
                        }),*/

                        _optionTile(Icons.logout, 'Logout', () {
                          _showLogoutConfirmationDialog(context);
                        }),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          else {
            return Center(child: Text('No Data Available'));
          }
        },
      ),


      // Bottom navigation bar
      
    );
  }

  // Helper widget for info cards
  Widget _infoCard(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 16,
              color: AppColor.textwhite,
              fontWeight: FontWeight.bold),
        ),
        Text(
          label,
          style: TextStyle(
              fontSize: 14, color: AppColor.textwhite.withOpacity(0.7)),
        ),
      ],
    );
  }

  // Helper widget for option tiles
  Widget _optionTile(IconData icon, String title, VoidCallback onTap) {
    return Container(
      margin: EdgeInsets.only(top: 10,bottom: 10),
      child: ListTile(
        leading: ClipOval(
          child: Container(
              height: 50,
              width: 50,
              color: AppColor.primary,
          
              child: Icon(icon, color: AppColor.textwhite)),
        ),
        title: Text(
          title,
          style: TextStyle(color: AppColor.textwhite, fontSize: 16),
        ),
        trailing: Icon(Icons.arrow_forward_ios,
            color: AppColor.yellowtext.withOpacity(0.7), size: 16),
        onTap: onTap,
      ),
    );
  }
}
