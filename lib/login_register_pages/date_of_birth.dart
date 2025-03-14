import 'package:exercai_mobile/login_register_pages/Whatisyour_Goal_page.dart';
import 'package:exercai_mobile/login_register_pages/gender_choose.dart';
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

class DateOfBirth extends StatefulWidget {
  const DateOfBirth({super.key});

  @override
  State<DateOfBirth> createState() => _DateOfBirthState();
}

class _DateOfBirthState extends State<DateOfBirth> {
  TextEditingController dobController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _checkForNewUser(); // Ensure data resets for new users
  }

  // Check if user has changed and reset data if needed
  Future<void> _checkForNewUser() async {
    final prefs = await SharedPreferences.getInstance();
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;
    String? lastSavedUser = prefs.getString('lastSavedUser');
    if (lastSavedUser != currentUser.email) {
      await prefs.clear();
      await prefs.setString('lastSavedUser', currentUser.email!);
      print("Cleared previous user data. Storing data for new user: ${currentUser.email}");
    }
    _loadUserData(); // Load the correct user's data
  }

  // Load saved user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      dobController.text = prefs.getString('dob') ?? '';
    });
  }

  // Save user input when clicking "Next"
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('dob', dobController.text);
  }

  // Redesigned date picker: Uses a sliding CupertinoDatePicker in a modal bottom sheet.
  Future<void> _selectDate(BuildContext context) async {
    DateTime initialDate = DateTime.now();
    if (dobController.text.isNotEmpty) {
      try {
        initialDate = DateFormat('MM-dd-yyyy').parse(dobController.text);
      } catch (e) {
        // Fallback to today if parsing fails.
      }
    }
    DateTime selectedDate = initialDate;
    await showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          height: 300,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              // Header with title and Done button.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Select Date of Birth",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      setState(() {
                        dobController.text = DateFormat('MM-dd-yyyy').format(selectedDate);
                      });
                      Navigator.pop(context);
                    },
                    child: Text(
                      "Done",
                      style: TextStyle(
                        color: AppColor.moresolidPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ],
              ),
              Divider(color: Colors.grey[300], height: 1),
              // The CupertinoDatePicker provides a smooth sliding interface.
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  initialDateTime: initialDate,
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime.now(),
                  onDateTimeChanged: (DateTime newDate) {
                    selectedDate = newDate;
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // (Optional) Compute user age from DOB
  int computeAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
      age--;
    }
    return age;
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white, // Overall white background
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Center vertically
            crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
            mainAxisSize: MainAxisSize.min, // Avoid stretching full height
            children: [
              _buildHeaderSection(),
              _buildDateFieldSection(),
              SizedBox(height: 40),
              _buildNextButton(),
            ],
          ),
        ),
      ),
    );

  }

  // Modern, clean header section.
  Widget _buildHeaderSection() {
    return Column(
      children: [
        SizedBox(height: 12),
          Image.asset('assets/balloon.png',width: 200,)
      ],
    );
  }

  // Redesigned Date of Birth field with card-like style.
  Widget _buildDateFieldSection() {
    return Column(
      children: [
        Text(
          "Choose your date of birth.",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 75, // Increased height for better spacing
            child: Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              child: InkWell( // <-- Added InkWell to make it clickable
                onTap: () => _selectDate(context), // Trigger the date picker
                borderRadius: BorderRadius.circular(30), // Ensure click effect follows rounded corners
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    children: [
                      SizedBox(width: 16), // Left padding for alignment
                      Icon(Icons.calendar_month_rounded, color: AppColor.supersolidPrimary,size: 35,),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          dobController.text.isEmpty ? "Date of Birth" : dobController.text,
                          style: TextStyle(
                            color: dobController.text.isEmpty ? Colors.grey : Colors.black87,
                            fontSize: 20,
                          ),
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: AppColor.supersolidPrimary),
                      SizedBox(width: 16), // Right padding for alignment
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Redesigned "Next" button using modern Material styling.
  Widget _buildNextButton() {
    return Center(
      child: SizedBox(
        width: 170,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColor.moresolidPrimary,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            elevation: 4,
          ),
          onPressed: () async {
            await _saveUserData(); // Save input data before navigating
            try {
              final user = FirebaseAuth.instance.currentUser;
              if (user == null) return;

              // Parse DOB
              DateTime? dob;
              try {
                dob = DateFormat('MM-dd-yyyy').parse(dobController.text);
              } catch (e) {
                print("Invalid date format: $e");
                return;
              }

              // Compute Age
              int age = 0;
              if (dob != null) {
                final now = DateTime.now();
                age = now.year - dob.year;
                if (now.month < dob.month || (now.month == dob.month && now.day < dob.day)) {
                  age--;
                }
              }

              // Save data to Firestore
              await FirebaseFirestore.instance.collection("Users").doc(user.email).update({
                'dateOfBirth': dob,
                'age': age,
              });
              navigateWithSlideTransition(context, GenderChoose(), slideRight: true);
            } catch (e) {
              print("Error saving data: $e");
            }
          },
          child: Text(
            "Next",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
