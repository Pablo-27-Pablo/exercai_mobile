import 'package:exercai_mobile/login_register_pages/Whatisyour_Goal_page.dart';
import 'package:exercai_mobile/login_register_pages/Whatisyour_target_weight.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercai_mobile/main.dart';
import 'package:intl/intl.dart';
import 'package:hive/hive.dart';
import 'createaccount.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';

class WeightChoose extends StatefulWidget {
  const WeightChoose({super.key});

  @override
  State<WeightChoose> createState() => _WeightChooseState();
}

class _WeightChooseState extends State<WeightChoose> {
  // Weight range in kilograms
  final double _minWeight = 20.0;
  final double _maxWeight = 300.0;
  final double _step = 0.1; // increments of 0.1 kg

  // Current weight in kg
  double _currentWeight = 70.0; // default

  // Fetched user height from Firestore (in cm)
  double _firebaseHeight = 0.0;

  // Real-time BMI and category
  double _computedBMI = 0.0;
  String _bmiCategory = "";

  // For calculating the number of wheel items
  late int _itemCount;

  @override
  void initState() {
    super.initState();
    _itemCount = ((_maxWeight - _minWeight) / _step).round() + 1;
    _checkForNewUser();       // Ensure data resets for new users
    _getHeightFromFirebase(); // Retrieve the stored height from Firestore
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
    final savedWeightStr = prefs.getString('weight') ?? "";
    if (savedWeightStr.isNotEmpty) {
      double savedWeight = double.tryParse(savedWeightStr) ?? 70.0;
      // Constrain to [minWeight, maxWeight]
      savedWeight = savedWeight.clamp(_minWeight, _maxWeight);
      setState(() {
        _currentWeight = savedWeight;
      });
    }
    _updateBMI(); // Recompute BMI if possible
  }

  // Save user input when clicking "Next"
  Future<void> _saveUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('weight', _currentWeight.toString());
  }

  // Fetch the height from Firestore
  Future<void> _getHeightFromFirebase() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final docSnapshot = await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.email)
          .get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        setState(() {
          _firebaseHeight =
              double.tryParse(docSnapshot.data()!['height'].toString()) ?? 0.0;
        });
        // Recompute BMI with newly fetched height
        _updateBMI();
      }
    } catch (e) {
      print("Error fetching height: $e");
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

  // Helper function to return color based on BMI category
  Color getBMIColor(String bmiCategory) {
    switch (bmiCategory) {
      case 'underweight':
        return Colors.red;
      case 'normal':
        return Colors.green;
      case 'overweight':
        return Colors.orange;
      case 'obese':
        return Colors.red;
      case 'extreme_obese':
        return Colors.red[900] ?? Colors.red;
      default:
        return Colors.orangeAccent;
    }
  }

  // Recompute BMI based on current weight & height
  void _updateBMI() {
    if (_currentWeight > 0 && _firebaseHeight > 0) {
      double bmi = computeBMI(_currentWeight, _firebaseHeight);
      setState(() {
        _computedBMI = bmi;
        _bmiCategory = getBMICategory(bmi);
      });
    } else {
      setState(() {
        _computedBMI = 0.0;
        _bmiCategory = "";
      });
    }
  }

  // Convert index -> weight
  double _indexToWeight(int index) {
    return _minWeight + index * _step;
  }

  // Convert weight -> index
  int _weightToIndex(double weight) {
    return ((weight - _minWeight) / _step).round();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // Header
              // Center content
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Big weight display
                    _buildWeightDisplay(),
                    SizedBox(height: 24),
                    // Horizontal weight wheel
                    _buildWeightSelector(),
                    SizedBox(height: 24),
                    // BMI card
                    _buildBMIDisplay(),
                  ],
                ),
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


  // Large number in the center showing the selected weight in kg
  Widget _buildWeightDisplay() {
    String textVal = "${_currentWeight.toStringAsFixed(1)} kg";
    return Column(
      children: [
        Text(
          "What's your current weight?",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 25,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 6),
        Text(
          "It's only used to help us adjust the workouts to best suit your physique",
          style: TextStyle(fontSize: 14, color: Colors.black54),textAlign: TextAlign.center,
        ),
        SizedBox(height: 15),
        Text(
          textVal,
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        // Green line under the main weight number
        Container(
          height: 2,
          width: 100,
          color: AppColor.supersolidPrimary,
          margin: EdgeInsets.only(top: 4),
        ),
      ],
    );
  }

  // Horizontal ListWheelScrollView with vertical tick lines
  Widget _buildWeightSelector() {
    // Convert current weight to index
    int currentIndex = _weightToIndex(_currentWeight);
    currentIndex = currentIndex.clamp(0, _itemCount - 1);

    return Container(
      height: 80,
      child: RotatedBox(
        quarterTurns: -1, // rotate to make it horizontal
        child: ListWheelScrollView.useDelegate(
          controller: FixedExtentScrollController(initialItem: currentIndex),
          itemExtent: 25,
          perspective: 0.002,
          physics: FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            double newWeight = _indexToWeight(index);
            setState(() {
              _currentWeight = newWeight.clamp(_minWeight, _maxWeight);
            });
            _updateBMI();
          },
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (index < 0 || index >= _itemCount) return null;
              double val = _indexToWeight(index);

              // Check if it's a whole number
              bool isWholeNumber = ((val * 10) % 10) == 0;

              // Is this item the selected item?
              bool isSelected = index == currentIndex;
              return RotatedBox(
                quarterTurns: 1, // rotate upright
                child: _buildVerticalTickLine(val, isWholeNumber, isSelected),
              );
            },
            childCount: _itemCount,
          ),
        ),
      ),
    );
  }

  // Build a vertical "tick" line
  // - If it's a whole number, show a taller line and the numeric label
  // - If it's a decimal, show a shorter line, no label
  Widget _buildVerticalTickLine(double value, bool isWholeNumber, bool isSelected) {
    // For a whole number, e.g. 21.0, show a longer line and label
    double lineHeight = isWholeNumber ? 30 : 15;
    bool showLabel = isWholeNumber;

    return Container(
      width: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Vertical line
          Container(
            width: 2,
            height: lineHeight,
            color: isSelected ? AppColor.supersolidPrimary : Colors.black54,
          ),
          // If whole number, show label below the line
          if (showLabel) ...[
            SizedBox(height: 6),
            Text(
              value.toStringAsFixed(0), // integer display
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

  // BMI card display
  // BMI card display
  Widget _buildBMIDisplay() {
    if (_computedBMI <= 0) {
      return SizedBox.shrink(); // no valid BMI yet
    }
    String message = _getBMICategoryMessage(_bmiCategory);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Text(
            "Your BMI: ${_computedBMI.toStringAsFixed(1)}",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: getBMIColor(_bmiCategory),
            ),
          ),
          SizedBox(height: 8),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.black87,fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // Short motivational message based on BMI category
  String _getBMICategoryMessage(String category) {
    switch (category) {
      case 'underweight':
        return "Your BMI is a bit low. With the right workouts and nutrition, you'll reach a healthy range!";
      case 'normal':
        return "You're in a healthy range. Keep it up!";
      case 'overweight':
        return "You're just a few sweat workouts away from a fitter you!";
      case 'obese':
      case 'extreme_obese':
        return "Consistency is key. Let's work together to get you in a healthier range!";
      default:
        return "Keep going! A healthier you is within reach.";
    }
  }

  // "Next" button
  Widget _buildNextButton() {
    return GestureDetector(
      onTap: () async {
        await _saveUserData(); // Save input data locally
        try {
          final user = FirebaseAuth.instance.currentUser;
          if (user == null) return;

          // Recompute BMI with final values
          final double bmi = computeBMI(_currentWeight, _firebaseHeight);
          final String bmiCategory = getBMICategory(bmi);

          // Save weight, height, BMI, and BMI category to Firestore
          await FirebaseFirestore.instance.collection("Users").doc(user.email).update({
            'weight': _currentWeight.toStringAsFixed(1),
            'height': _firebaseHeight.toStringAsFixed(1),
            'bmi': bmi.toStringAsFixed(1),
            'bmiCategory': bmiCategory,
          });

          print("User profile data saved with BMI: $bmi, category: $bmiCategory.");
          navigateWithSlideTransition(context, WhatisyourTargetWeight(), slideRight: true);
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
