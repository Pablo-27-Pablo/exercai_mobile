import 'package:exercai_mobile/login_register_pages/Whatisyour_Goal_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercai_mobile/main.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'createaccount.dart';

class WelcomeUser extends StatefulWidget {
  const WelcomeUser({super.key});

  @override
  State<WelcomeUser> createState() => _WelcomeUserState();
}

class _WelcomeUserState extends State<WelcomeUser> {
  String? dropdowngender; // Default gender is null with hint text
  TextEditingController dobController = TextEditingController();
  TextEditingController weightController = TextEditingController();
  TextEditingController heightController = TextEditingController();

  // Function to show date picker
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        dobController.text = DateFormat('MM-dd-yyyy').format(picked); // Format: MM-dd-yyyy
      });
    }
  }

  // Compute BMI using standard formula: weight (kg) / [height (m)]^2
  double computeBMI(double weightKg, double heightCm) {
    double heightM = heightCm / 100.0; // convert cm to meters
    if (heightM <= 0) return 0;        // avoid division by zero
    return weightKg / (heightM * heightM);
  }

  // Determine BMI category
  String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'underweight';
    } else if (bmi < 25) {
      return 'normal';
    } else if (bmi < 30) {
      return 'overweight';
    } else if (bmi < 35) {
      return 'obese';
    } else {
      return 'extreme_obese';
    }
  }

  // (Optional) Compute user age from DOB
  int computeAge(DateTime dob) {
    final now = DateTime.now();
    int age = now.year - dob.year;
    // If the user hasn't had their birthday yet this year, subtract 1
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
        backgroundColor: AppColor.backgroundgrey,
        body: ListView(
          children: [
            upperTextSection(),
            TextFieldSection(),
            const SizedBox(height: 70),
            primarybutton(),
          ],
        ),
      ),
    );
  }

  Container TextFieldSection() {
    return Container(
      decoration: BoxDecoration(color: AppColor.primary),
      child: Column(
        children: [
          // Intro
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Text(
                  "Let's complete your profile",
                  style: TextStyle(
                    color: AppColor.yellowtext,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  "It will help us to know more about you!",
                  style: TextStyle(
                    color: AppColor.textwhite,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          // Fields
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: Column(
              children: [
                // Date of Birth Field with Date Picker
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: AppColor.shadow.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 0.0,
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: dobController,
                    readOnly: true,
                    onTap: () => _selectDate(context),
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.calendar_month_outlined),
                      hintText: 'Date of Birth',
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 25),

                // Gender Dropdown
                DropdownButtonFormField<String>(
                  value: dropdowngender,
                  decoration: InputDecoration(
                    prefixIcon: Icon(Icons.female_outlined),
                    hintText: 'Click to enter Gender',
                    filled: true,
                    fillColor: Colors.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: <String>['Male', 'Female'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdowngender = newValue;
                    });
                  },
                ),
                const SizedBox(height: 25),

                // Weight Field (Numbers Only)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(boxShadow: [
                          BoxShadow(
                            color: AppColor.shadow.withOpacity(0.5),
                            blurRadius: 40,
                            spreadRadius: 0.0,
                          ),
                        ]),
                        child: TextField(
                          controller: weightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.monitor_weight_outlined),
                            hintText: 'Weight (kg)',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 32, 32, 32),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "kg",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColor.yellowtext,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 30),

                // Height Field (Numbers Only)
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          boxShadow: [
                            BoxShadow(
                              color: AppColor.shadow.withOpacity(0.5),
                              blurRadius: 40,
                              spreadRadius: 0.0,
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: heightController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.height_outlined),
                            hintText: 'Height (cm)',
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.transparent),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      height: 50,
                      width: 50,
                      decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 32, 32, 32),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          "cm",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: AppColor.yellowtext,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 60),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // "Next" button to save data in Firestore
  GestureDetector primarybutton() {
    return GestureDetector(
      onTap: () async {
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

          // Parse weight & height
          final double weight = double.tryParse(weightController.text) ?? 0;
          final double height = double.tryParse(heightController.text) ?? 0;

          // Compute BMI
          final double heightM = height / 100.0;
          double bmi = 0;
          if (heightM > 0) {
            bmi = weight / (heightM * heightM);
          }

          // Determine BMI category
          String bmiCategory;
          if (bmi < 18.5) {
            bmiCategory = 'underweight';
          } else if (bmi < 25) {
            bmiCategory = 'normal';
          } else if (bmi < 30) {
            bmiCategory = 'overweight';
          } else if (bmi < 35) {
            bmiCategory = 'obese';
          } else {
            bmiCategory = 'extreme_obese';
          }

          // (Optional) Compute Age
          int age = 0;
          if (dob != null) {
            final now = DateTime.now();
            age = now.year - dob.year;
            if (now.month < dob.month ||
                (now.month == dob.month && now.day < dob.day)) {
              age--;
            }
          }

          // Save data to Firestore
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(user.email)
              .update({
            'dateOfBirth': dob,
            'gender': dropdowngender,
            'weight': weight.toString(),
            'height': height.toString(),
            'bmi': bmi.toStringAsFixed(2),        // numeric BMI
            'bmiCategory': bmiCategory,          // e.g. "normal", "overweight"
            'age': age,                          // optional
          });

          print("User profile data saved with BMI: $bmi, category: $bmiCategory.");
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => WhatGoalPage()),
          );
        } catch (e) {
          print("Error saving data: $e");
        }
      },
      child: Container(
        child: Column(
          children: [
            Container(
              height: 55,
              width: 150,
              decoration: BoxDecoration(
                color: AppColor.buttonPrimary.withOpacity(0.7),
                borderRadius: BorderRadius.circular(50),
                border: Border.all(width: 2, color: AppColor.buttonSecondary),
                boxShadow: [
                  BoxShadow(
                    color: AppColor.buttonSecondary.withOpacity(0.7),
                    blurRadius: 90,
                    spreadRadius: 0.1,
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  "Next",
                  style: TextStyle(
                    color: AppColor.textwhite,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container upperTextSection() {
    return Container(
      height: 130,
      color: Colors.black,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.only(left: 20),
            child: Text(
              "Welcome",
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 43,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
