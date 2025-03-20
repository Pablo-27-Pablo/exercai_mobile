import 'package:exercai_mobile/login_register_pages/Whatisyour_Goal_page.dart';
import 'package:exercai_mobile/login_register_pages/date_of_birth.dart';
import 'package:exercai_mobile/login_register_pages/height_choose.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercai_mobile/main.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'createaccount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';

class GenderChoose extends StatefulWidget {
  const GenderChoose({super.key});

  @override
  State<GenderChoose> createState() => _GenderChooseState();
}

class _GenderChooseState extends State<GenderChoose> {
  String? dropdowngender; // Will store "Male" or "Female" or remain null

  @override
  void initState() {
    super.initState();
    _checkForNewUser(); // Ensure data resets for new users
  }

  // 🔹 Check if user has changed and reset data if needed
  Future<void> _checkForNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser == null) return;

    String? lastSavedUser = prefs.getString('lastSavedUser');

    if (lastSavedUser != currentUser.email) {
      // 🔥 Clear previous user data
      await prefs.clear();
      await prefs.setString('lastSavedUser', currentUser.email!);
      print("Cleared previous user data. Storing data for new user: ${currentUser.email}");
    }

    _loadUserData(); // Load the correct user's data
  }

  // 🔹 Load saved user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final savedGender = prefs.getString('gender');
    setState(() {
      dropdowngender = (savedGender != null && savedGender.isNotEmpty) ? savedGender : null;
    });
  }


  // 🔹 Save user input when clicking "Next"
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gender', dropdowngender ?? '');
  }

  // Build method with modern UI layout
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: AppColor.backgroundWhite,
          title: Image.asset('assets/exercai-front.png', height: 60,width: 100,),
          leading: IconButton(onPressed: (){
            navigateWithSlideTransition(context, DateOfBirth(), slideRight: false);
          }, icon: Icon(Icons.arrow_back_ios,color: Colors.black87,)),
        ),
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Center( // Centers content horizontally
            child: SingleChildScrollView( // Ensures content stays scrollable if the screen is small
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center, // Centers content vertically
                crossAxisAlignment: CrossAxisAlignment.center, // Centers content horizontally
                children: [
                  _buildHeaderText(),
                  SizedBox(height: 24),
                  _buildGenderOptionsRow(),
                  SizedBox(height: 60),
                  _buildNextButton(),
                  SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }



  // Title: "Tell us your gender" + subtext with lightbulb icon
  Widget _buildHeaderText() {
    return Column(
      children: [
        Text(
          "Tell us your gender",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 12),
      ],
    );
  }

  // Row with Male and Female images
  Widget _buildGenderOptionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildGenderOption("Male", "assets/male.jpg"),
        _buildGenderOption("Female", "assets/female.jpg"),
      ],
    );
  }

  // Single gender option card
  Widget _buildGenderOption(String label, String assetPath) {
    final bool isSelected = dropdowngender == label;
    return GestureDetector(
      onTap: () {
        setState(() {
          dropdowngender = label;
        });
      },
      child: Container(
        width: 150,
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(
            color: isSelected ? AppColor.supersolidPrimary : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Gender image
            Image.asset(
              assetPath,
              height: 220,
              fit: BoxFit.cover,
            ),
            SizedBox(height: 8),
            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColor.supersolidPrimary : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // "Next" button (preserves original functionality)
  Widget _buildNextButton() {
    return Center(
      child: SizedBox(
        width: 170,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: (dropdowngender != null && dropdowngender!.isNotEmpty)
                ? AppColor.moresolidPrimary
                : Colors.grey,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 4,
          ),
          onPressed: (dropdowngender != null && dropdowngender!.isNotEmpty)
              ? () async {
            await _saveUserData();
            try {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;
              await FirebaseFirestore.instance
                  .collection("Users")
                  .doc(user.email)
                  .update({'gender': dropdowngender});
              navigateWithSlideTransition(context, HeightChoose(), slideRight: true);
            } catch (e) {
              print("Error saving data: $e");
            }
          }
              : null,
          child: Text(
            "Next",
            style: TextStyle(
              color: AppColor.backgroundWhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
