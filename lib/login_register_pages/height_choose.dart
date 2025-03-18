import 'package:exercai_mobile/login_register_pages/Whatisyour_Goal_page.dart';
import 'package:exercai_mobile/login_register_pages/gender_choose.dart';
import 'package:exercai_mobile/login_register_pages/weight_choose.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercai_mobile/main.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'createaccount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';

class HeightChoose extends StatefulWidget {
  const HeightChoose({super.key});

  @override
  State<HeightChoose> createState() => _HeightChooseState();
}

class _HeightChooseState extends State<HeightChoose> {
  // Updated range of selectable heights
  final int minHeight = 80;
  final int maxHeight = 280;

  // Currently selected height in cm
  int _currentHeight = 170; // Default selection

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
      // Clear previous user data
      await prefs.clear();
      await prefs.setString('lastSavedUser', currentUser.email!);
      print("Cleared previous user data. Storing data for new user: ${currentUser.email}");
    }
    _loadUserData();
  }

  // Load saved user data from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    String savedHeightStr = prefs.getString('height') ?? '';
    if (savedHeightStr.isNotEmpty) {
      int savedHeight = int.tryParse(savedHeightStr) ?? 170;
      // Constrain loaded height to [minHeight, maxHeight]
      savedHeight = savedHeight.clamp(minHeight, maxHeight);
      setState(() {
        _currentHeight = savedHeight;
      });
    }
  }

  // Save user input when clicking "Next"
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('height', _currentHeight.toString());
  }

  // Compute BMI using standard formula: weight (kg) / [height (m)]^2
  double computeBMI(double weightKg, double heightCm) {
    double heightM = heightCm / 100.0;
    if (heightM <= 0) return 0;
    return weightKg / (heightM * heightM);
  }


  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          leading: IconButton(onPressed: (){
            navigateWithSlideTransition(context, GenderChoose(), slideRight: false);
          }, icon: Icon(Icons.arrow_back_ios,color: Colors.black87,)),
        ),
        backgroundColor: AppColor.backgroundWhite,
        body: SafeArea(
          child: Column(
            children: [
              // Step indicator and question
              _buildHeaderSection(),
              // Main content with the big numeric display and scale
              Expanded(
                child: _buildHeightSelector(),
              ),
              // Next button
              _buildNextButton(),
              SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  // Header: Step text, progress bar, question, subtext
  Widget _buildHeaderSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 40,),
          Text(
            "What's your height?",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          // Subtext
          Text(
            "It's only used to help us adjust the workouts to best suit your physique",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }

  // Main content: Big number in the center, scale on the right
  Widget _buildHeightSelector() {
    // The total number of height values
    final itemCount = (maxHeight - minHeight) + 1;

    // We'll invert the scroll so that physically scrolling up -> bigger height
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Big number in the middle
        Expanded(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                // Current height
                Text(
                  _currentHeight.toString(),
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                // Horizontal line
                Container(
                  width: 120,
                  height: 2,
                  color: AppColor.supersolidPrimary,
                  margin: EdgeInsets.symmetric(vertical: 4),
                ),
                // Unit
                Text(
                  "cm",
                  style: TextStyle(
                    fontSize: 20,
                    color: AppColor.supersolidPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 55,),
              ],
            ),
          ),
        ),
        // Vertical scale on the right
        Container(
          width: 80,
          // RotatedBox to invert the direction so that scrolling up => index increases
          child: RotatedBox(
            quarterTurns: 2, // Flip upside down
            child: ListWheelScrollView.useDelegate(
              physics: FixedExtentScrollPhysics(),
              itemExtent: 15,
              perspective: 0.003,
              // Our itemCount is the total range of values
              childDelegate: ListWheelChildBuilderDelegate(
                builder: (context, index) {
                  if (index < 0 || index >= itemCount) {
                    return null;
                  }
                  // This value is in ascending order, but because we've rotated the list,
                  // physically scrolling up moves to higher indexes -> higher height.
                  final value = minHeight + index;
                  return RotatedBox(
                    quarterTurns: 2, // Rotate each child back upright
                    child: _buildScaleLine(value),
                  );
                },
                childCount: itemCount,
              ),
              // We want the initialItem so that the user sees the correct height on load
              controller: FixedExtentScrollController(
                initialItem: _currentHeight - minHeight,
              ),
              onSelectedItemChanged: (index) {
                setState(() {
                  _currentHeight = minHeight + index;
                });
              },
            ),
          ),
        ),
        SizedBox(width: 16),
      ],
    );
  }

  // Draw a horizontal "tick" line.
  // Long line + label if ends with 0, medium line if ends with 5, short line otherwise.
  Widget _buildScaleLine(int value) {
    // Determine line width and whether to show a label
    double lineWidth;
    bool showLabel = false;

    if (value % 10 == 0) {
      lineWidth = 40; // long line
      showLabel = true;
    } else if (value % 5 == 0) {
      lineWidth = 25; // medium line
    } else {
      lineWidth = 15; // short line
    }

    bool isSelected = (value == _currentHeight);

    return Container(
      height: 40,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Tick line
          Container(
            height: 2,
            width: lineWidth,
            color: isSelected ? AppColor.supersolidPrimary : Colors.black54,
          ),
          // Optional label if multiple of 10
          if (showLabel) ...[
            SizedBox(width: 6),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 12,
                color: isSelected ? AppColor.supersolidPrimary : Colors.black54,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // "Next" button
  Widget _buildNextButton() {
    return GestureDetector(
      onTap: () async {
        await _saveUserData(); // Save input data before navigating
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) return;

          // Save data to Firestore
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(user.email)
              .update({
            'height': _currentHeight.toString(),
          });

          navigateWithSlideTransition(context, WeightChoose(), slideRight: true);
        } catch (e) {
          print("Error saving data: $e");
        }
      },
      child: Container(
        height: 50,
        margin: EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          color: AppColor.moresolidPrimary,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Center(
          child: Text(
            "Next",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
