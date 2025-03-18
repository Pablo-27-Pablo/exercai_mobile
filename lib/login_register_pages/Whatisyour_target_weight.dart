import 'package:exercai_mobile/homepage/starter_page.dart';
import 'package:exercai_mobile/login_register_pages/Whatisyour_Goal_page.dart';
import 'package:exercai_mobile/login_register_pages/bodyshape.dart';
import 'package:exercai_mobile/login_register_pages/nutriActivitylevel.dart';
import 'package:exercai_mobile/login_register_pages/weight_choose.dart';
import 'package:exercai_mobile/login_register_pages/workout_level.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WhatisyourTargetWeight extends StatefulWidget {
  const WhatisyourTargetWeight({super.key});

  @override
  State<WhatisyourTargetWeight> createState() => _WhatisyourTargetWeightState();
}

class _WhatisyourTargetWeightState extends State<WhatisyourTargetWeight> {
  // Local controller for target weight
  late TextEditingController _targetWeightController;

  // Fetched from Firestore
  double? currentWeight;

  // Real-time motivational message
  String displayedMessage = '';

  // Range for target weight in kg
  final double _minWeight = 20.0;
  final double _maxWeight = 300.0;
  final double _step = 0.1;
  late int _itemCount;

  @override
  void initState() {
    super.initState();
    _targetWeightController = TextEditingController();

    // Number of possible values
    _itemCount = ((_maxWeight - _minWeight) / _step).round() + 1;

    _fetchCurrentWeight();
    _loadTargetWeight();
    _targetWeightController.addListener(_calculatePercentage);
  }

  @override
  void dispose() {
    _targetWeightController.removeListener(_calculatePercentage);
    _targetWeightController.dispose();
    super.dispose();
  }

  // Load saved target weight from SharedPreferences
  Future<void> _loadTargetWeight() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _targetWeightController.text = prefs.getString('targetWeight') ?? '';
    });
  }

  // Save target weight to SharedPreferences
  Future<void> _saveTargetWeight() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('targetWeight', _targetWeightController.text.trim());
  }

  // Fetch the user’s current weight from Firestore
  void _fetchCurrentWeight() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .get();

    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('weight')) {
        setState(() {
          currentWeight = double.parse(data['weight'].toString());
        });
      }
    }
  }

  // Calculate the percentage difference between currentWeight and targetWeight
  void _calculatePercentage() {
    if (currentWeight == null || currentWeight == 0) {
      setState(() {
        displayedMessage = '';
      });
      return;
    }

    String newMessage = '';
    if (_targetWeightController.text.isEmpty) {
      newMessage = '';
    } else {
      double? target = double.tryParse(_targetWeightController.text);
      if (target == null) {
        newMessage = 'Invalid weight value';
      } else {
        double difference = target - currentWeight!;
        double percent = (difference.abs() / currentWeight!) * 100;
        String gainOrLose = difference > 0 ? 'gain' : 'lose';

        if (percent == 0) {
          newMessage = '😃Keep Going\nMaintain your current weight';
        } else if (percent <= 10) {
          newMessage =
          '👌A piece of cake:\nYou will $gainOrLose ${percent.toStringAsFixed(1)}% of your weight';
        } else if (percent <= 20) {
          newMessage =
          '💦Achievable Goal\nYou will $gainOrLose ${percent.toStringAsFixed(1)}% of your weight';
        } else {
          newMessage =
          '💪🏻 Challenging Goal\nYou will $gainOrLose ${percent.toStringAsFixed(1)}% of your weight';
        }
      }
    }

    if (newMessage != displayedMessage) {
      setState(() {
        displayedMessage = newMessage;
      });
    }
  }

  // Return the appropriate color for the first line of the displayed message
  Color _getMessageColor(String messagePart) {
    switch (messagePart) {
      case '👌A piece of cake:':
      case '😃Keep Going':
        return Colors.green;
      case '💦Achievable Goal':
        return Colors.orange;
      case '💪🏻 Challenging Goal':
        return Colors.red;
      default:
        return Colors.black;
    }
  }

  // Save target weight to Firestore
  void saveTargetWeightToFirebase() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && _targetWeightController.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.email)
          .set({
        'targetWeight': _targetWeightController.text.trim(),
      }, SetOptions(merge: true));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Please select a target weight before proceeding.")),
      );
    }
  }

  // Build method
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // White background to match the screenshot
      backgroundColor: Colors.white,
      appBar: _buildHeader(context),
      body: Column(
        children: [
          // Large spacing at the top for the question
          SizedBox(height: 24),

          // Title: "What's your target weight?" in bold black
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "What's your target weight?",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                // The green pill that says "kg" (no lbs)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColor.supersolidPrimary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    "kg",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Some spacing
          SizedBox(height: 16),

          // The big number in the center
          _buildWeightDisplay(),

          // The horizontal scale
          _buildWheelSelector(),

          // The motivational message
          _buildMotivationalCard(),

          Spacer(),

          // Next button at the bottom
          _buildNextButton(context),
          SizedBox(height: 16),
        ],
      ),
    );
  }

  // Custom AppBar with a back arrow
  PreferredSizeWidget _buildHeader(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.backgroundWhite,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        onPressed: () {
          navigateWithSlideTransition(context, WeightChoose(), slideRight: false);
        },
        icon: Icon(Icons.arrow_back_ios, color: Colors.black),
      ),
    );
  }

  // The large numeric display in the center
  Widget _buildWeightDisplay() {
    double weightVal = double.tryParse(_targetWeightController.text) ?? 70.0;
    return Column(
      children: [
        Text(
          weightVal.toStringAsFixed(1),
          style: TextStyle(
            fontSize: 48,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 4),
        // Thin green line under the big number
        Container(
          height: 2,
          width: 100,
          color: AppColor.supersolidPrimary,
        ),
        SizedBox(height: 8),
      ],
    );
  }

  // The horizontal wheel for selecting target weight (20–300 kg in 0.1 increments)
  Widget _buildWheelSelector() {
    // Convert current target weight from text controller
    double currentTarget = double.tryParse(_targetWeightController.text) ?? 70.0;
    if (currentTarget < _minWeight || currentTarget > _maxWeight) {
      currentTarget = 70.0;
    }

    int currentIndex = ((currentTarget - _minWeight) / _step).round();
    currentIndex = currentIndex.clamp(0, _itemCount - 1);

    // Keep the text controller in sync
    _targetWeightController.text = currentTarget.toStringAsFixed(1);

    return Container(
      height: 100,
      child: RotatedBox(
        quarterTurns: -1, // rotate to make it horizontal
        child: ListWheelScrollView.useDelegate(
          controller: FixedExtentScrollController(initialItem: currentIndex),
          itemExtent: 25,
          perspective: 0.002,
          physics: FixedExtentScrollPhysics(),
          onSelectedItemChanged: (index) {
            double newWeight = _minWeight + index * _step;
            setState(() {
              _targetWeightController.text = newWeight.toStringAsFixed(1);
            });
            _calculatePercentage();
            _saveTargetWeight();
          },
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (index < 0 || index >= _itemCount) return null;
              double val = _minWeight + index * _step;
              bool isWholeNumber = ((val * 10) % 10) == 0;
              bool isSelected = index == currentIndex;

              return RotatedBox(
                quarterTurns: 1, // rotate upright
                child: _buildVerticalTick(val, isWholeNumber, isSelected),
              );
            },
            childCount: _itemCount,
          ),
        ),
      ),
    );
  }

  // Build a vertical tick line:
  // - Longer line + label for whole number
  // - Shorter line for decimals
  Widget _buildVerticalTick(double value, bool isWholeNumber, bool isSelected) {
    double lineHeight = isWholeNumber ? 30 : 15;
    bool showLabel = isWholeNumber;

    return Container(
      width: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // The vertical line
          Container(
            width: 2,
            height: lineHeight,
            color: isSelected ? AppColor.supersolidPrimary : Colors.black54,
          ),
          if (showLabel) ...[
            SizedBox(height: 6),
            Text(
              value.toStringAsFixed(0),
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

  // Container for the motivational message
  Widget _buildMotivationalCard() {
    if (displayedMessage.isEmpty) {
      return SizedBox.shrink();
    }

    // The message has two lines separated by \n
    final lines = displayedMessage.split('\n');
    final firstLine = lines[0];
    final secondLine = lines.length > 1 ? lines[1] : "";

    return Container(
      width: double.infinity,
      margin: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            firstLine,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: _getMessageColor(firstLine),
            ),
          ),
          if (secondLine.isNotEmpty) ...[
            SizedBox(height: 4),
            Text(
              secondLine,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black87,
                fontWeight: FontWeight.bold
              ),
            ),
          ],
        ],
      ),
    );
  }

  // "Next" button (black background, white text)
  Widget _buildNextButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        saveTargetWeightToFirebase();
        _saveTargetWeight();
        navigateWithSlideTransition(context, WhatGoalPage(), slideRight: true);
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(horizontal: 24),
        height: 50,
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
