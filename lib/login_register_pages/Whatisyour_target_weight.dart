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
  // Controller for target weight text display
  late TextEditingController _targetWeightController;

  // Scroll controller for the ListWheelScrollView
  late FixedExtentScrollController _scrollController;

  // Track whether user data has loaded.
  bool _isDataLoaded = false;

  // Fetched user data from Firestore (stored as strings)
  double? currentWeight;
  double? userHeight; // in centimeters
  String? userGoal;   // e.g. "lose_weight" or "muscle_gain"

  // Allowed target weight range
  double? targetMin;
  double? targetMax;

  // Allowed indices (in the full wheel range)
  int? allowedMinIndex;
  int? allowedMaxIndex;

  // Real-time motivational message
  String displayedMessage = '';

  // Full visible range slider parameters
  final double _defaultMinWeight = 20.0;
  final double _defaultMaxWeight = 300.0;
  final double _step = 0.1;
  late int _itemCount;

  // This flag ensures we only jump to the wheel’s initial position once
  bool _hasSetInitialPosition = false;

  @override
  void initState() {
    super.initState();
    _targetWeightController = TextEditingController();
    _itemCount = (((_defaultMaxWeight - _defaultMinWeight) / _step).round() + 1);

    // Initialize the wheel controller once
    //_scrollController = FixedExtentScrollController(initialItem: 0);

    _loadTargetWeight();
    _fetchUserData();
    _targetWeightController.addListener(_calculatePercentage);
  }

  @override
  void dispose() {
    _targetWeightController.removeListener(_calculatePercentage);
    _targetWeightController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _initializeScrollController() {
    double fallbackWeight = currentWeight ?? 70.0;
    if (_targetWeightController.text.isEmpty) {
      _targetWeightController.text = fallbackWeight.toStringAsFixed(1);
    }
    double? targetVal = double.tryParse(_targetWeightController.text) ?? fallbackWeight;
    if (targetVal < _defaultMinWeight) targetVal = _defaultMinWeight;
    if (targetVal > _defaultMaxWeight) targetVal = _defaultMaxWeight;
    int targetIndex = ((targetVal - _defaultMinWeight) / _step).round().clamp(0, _itemCount - 1);
    _currentSelectedIndex = targetIndex;
    _scrollController = FixedExtentScrollController(initialItem: targetIndex);
  }


  // Load saved target weight from SharedPreferences
  Future<void> _loadTargetWeight() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('targetWeight') ?? '';
    setState(() {
      _targetWeightController.text = saved;
    });
  }

  // Save target weight to SharedPreferences
  Future<void> _saveTargetWeight() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('targetWeight', _targetWeightController.text.trim());
  }

  // ---------------------------------------------------------------------------
  //  1) BMI Category Helpers
  // ---------------------------------------------------------------------------
  // Get BMI Category from a numeric BMI
  String _getBmiCategory(double bmi) {
    if (bmi < 18.5) {
      return "Underweight";
    } else if (bmi < 25) {
      return "Normal";
    } else if (bmi < 30) {
      return "Overweight";
    } else if (bmi < 35) {
      return "Obese";
    } else {
      return "Extremely Obese";
    }
  }

  // ---------------------------------------------------------------------------
  //  2) Fetch user data, set allowed target range
  // ---------------------------------------------------------------------------
  void _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .get();

    if (!doc.exists) return;

    var data = doc.data() as Map<String, dynamic>?;
    if (data == null) return;

    // 2.1) Retrieve user's current weight, height, and goal
    if (data.containsKey('weight')) {
      currentWeight = double.parse(data['weight'].toString());
    }
    if (data.containsKey('height')) {
      userHeight = double.parse(data['height'].toString());
    }
    if (data.containsKey('goal')) {
      userGoal = data['goal'].toString(); // e.g. "lose_weight" or "muscle_gain"
    }

    // 2.2) If userHeight and currentWeight exist, compute allowed range
    if (userHeight != null && currentWeight != null) {
      double heightInM = userHeight! / 100.0;
      double userBmi = currentWeight! / (heightInM * heightInM);
      String userBmiCategory = _getBmiCategory(userBmi);

      if (userGoal == "lose weight") {
        // If height and current weight are available, compute targetMin using BMI 18.5.
        if (userHeight != null && currentWeight != null) {
          targetMin = 18.5 * heightInM * heightInM;
          targetMax = currentWeight;
        } else {
          // Fallback to default minimum if data is not available.
          targetMin = _defaultMinWeight;
          targetMax = currentWeight;
        }
      }
      else if (userGoal == "muscle mass gain") {
        double lowerBound = currentWeight!;
        double upperBound = lowerBound; // Start by assuming no increase
        // Overweight: up to BMI 29.9
        if (userBmiCategory.toLowerCase() == "overweight") {
          double candidate = 29.9 * heightInM * heightInM;
          if (candidate > currentWeight!) {
            upperBound = candidate;
          }
        }
        else if (userBmiCategory.toLowerCase() == "obese") {
          double candidate = 34.9 * heightInM * heightInM;
          if (candidate > currentWeight!) {
            upperBound = candidate;
          }
        }
        else if (userBmiCategory.toLowerCase() == "normal") {
          double candidate = 24.9 * heightInM * heightInM;
          if (candidate > currentWeight!) {
            upperBound = candidate;
          }
        }
        // Fallback
        else {
          double candidate = 24.9 * heightInM * heightInM;
          if (candidate > currentWeight!) {
            upperBound = candidate;
          }
        }

        targetMin = lowerBound;
        targetMax = upperBound;
      }

      else {
        // Fallback to lose_weight logic
        targetMin = 18.5 * heightInM * heightInM;
        targetMax = currentWeight;
      }

      // 2.3) Compute allowed indices for the wheel selector
      allowedMinIndex = (((targetMin!) - _defaultMinWeight) / _step).round();
      allowedMaxIndex = (((targetMax!) - _defaultMinWeight) / _step).round();
    }

    // Always set the wheel to the correct position after we have user data

    //_setWheelToCorrectPosition();
    _initializeScrollController();

    setState(() {
      _isDataLoaded = true;
    });


    setState(() {}); // Refresh UI
  }

  /// Sets the wheel to the correct position based on:
  /// 1) The saved target weight (if any), else
  /// 2) The user’s current weight
  void _setWheelToCorrectPosition() {
    // If we've already jumped once, don't do it again
    if (_hasSetInitialPosition) return;

    double fallbackWeight = (currentWeight ?? 70.0);

    // If the text controller is empty, use current weight as fallback
    if (_targetWeightController.text.isEmpty) {
      _targetWeightController.text = fallbackWeight.toStringAsFixed(1);
    }

    // Parse whatever is in the text controller
    double? targetVal = double.tryParse(_targetWeightController.text);
    if (targetVal == null) {
      targetVal = fallbackWeight;
      _targetWeightController.text = targetVal.toStringAsFixed(1);
    }

    // Clamp to [defaultMinWeight, defaultMaxWeight]
    if (targetVal < _defaultMinWeight) targetVal = _defaultMinWeight;
    if (targetVal > _defaultMaxWeight) targetVal = _defaultMaxWeight;
    int targetIndex = ((targetVal - _defaultMinWeight) / _step).round();
    targetIndex = targetIndex.clamp(0, _itemCount - 1);

    // Jump after the first frame is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.jumpToItem(targetIndex);
    });

    _hasSetInitialPosition = true;
  }

  // ---------------------------------------------------------------------------
  //  3) The rest of your existing code remains mostly unchanged
  // ---------------------------------------------------------------------------

  // Calculate the difference between currentWeight and targetWeight
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildHeader(context),
      body:!_isDataLoaded
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          const SizedBox(height: 24),
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
                        color: Colors.black87),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColor.supersolidPrimary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Text(
                    "kg",
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _buildWeightDisplay(),
          _buildWheelSelector(),
          _buildMotivationalCard(),
          const Spacer(),
          _buildNextButton(context),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildHeader(BuildContext context) {
    return AppBar(
      backgroundColor: AppColor.backgroundWhite,
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        onPressed: () async {
          // Delete the "targetWeight" from SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.remove("targetWeight");

          // Delete the "targetWeight" field from Firebase for the current user
          final user = FirebaseAuth.instance.currentUser;
          if (user != null) {
            await FirebaseFirestore.instance
                .collection("Users")
                .doc(user.email)
                .update({"targetWeight": FieldValue.delete()});
          }

          // Navigate back to the previous page (e.g. WhatGoalPage)
          navigateWithSlideTransition(context, WhatGoalPage(), slideRight: false);
        },
        icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
      ),
    );

  }


  Widget _buildWeightDisplay() {
    // If text is empty or invalid, default to 70
    double weightVal = double.tryParse(_targetWeightController.text) ?? 70.0;

    String bmiString = "";
    String bmiCategory = "";
    if (userHeight != null && userHeight! > 0) {
      double heightInM = userHeight! / 100.0;
      double bmi = weightVal / (heightInM * heightInM);
      bmiString = bmi.toStringAsFixed(1);
      bmiCategory = _getBmiCategory(bmi);
    }

    return Column(
      children: [
        Text(
          weightVal.toStringAsFixed(1),
          style: const TextStyle(
              fontSize: 48, fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        if (bmiString.isNotEmpty)
          Text(
            "Target BMI: $bmiString",
            style: const TextStyle(fontSize: 16, color: Colors.black54),
          ),
        if (bmiCategory.isNotEmpty)
          Text(
            "TARGET BMI LEVEL: $bmiCategory",
            style: const TextStyle(
                fontSize: 16, color: Colors.black54, fontWeight: FontWeight.w600),
          ),
        const SizedBox(height: 4),
        Container(height: 2, width: 100, color: AppColor.supersolidPrimary),
        const SizedBox(height: 8),
      ],
    );
  }

  // 1) Add a field to track the currently selected index
  int _currentSelectedIndex = 0;


  Widget _buildWheelSelector() {
    return SizedBox(
      height: 100,
      child: RotatedBox(
        quarterTurns: -1,
        child: ListWheelScrollView.useDelegate(
          controller: _scrollController,
          itemExtent: 25,
          perspective: 0.002,
          physics: const FixedExtentScrollPhysics(),
          // 2) Update _currentSelectedIndex in onSelectedItemChanged
          onSelectedItemChanged: (index) {
            setState(() {
              _currentSelectedIndex = index;
            });

            double newWeight = _defaultMinWeight + index * _step;

            // Restrict selection to the allowed range
            if (targetMin != null && targetMax != null) {
              if (newWeight < targetMin!) {
                _scrollController.animateToItem(
                  allowedMinIndex!,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                return;
              }
              if (newWeight > targetMax!) {
                _scrollController.animateToItem(
                  allowedMaxIndex!,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
                return;
              }
            }

            _targetWeightController.text = newWeight.toStringAsFixed(1);
            _calculatePercentage();
            _saveTargetWeight();
          },
          childDelegate: ListWheelChildBuilderDelegate(
            builder: (context, index) {
              if (index < 0 || index >= _itemCount) return null;

              double val = _defaultMinWeight + index * _step;
              bool isWholeNumber = ((val * 10) % 10) == 0;

              // Mark values outside the allowed range as disabled
              bool isSelectable = true;
              if (targetMin != null && targetMax != null) {
                if (val < targetMin! || val > targetMax!) {
                  isSelectable = false;
                }
              }

              // 3) Check if this line is currently selected
              bool isSelected = (index == _currentSelectedIndex);

              return RotatedBox(
                quarterTurns: 1,
                child: _buildVerticalTick(
                  val,
                  isWholeNumber,
                  isSelectable,
                  isSelected, // Pass this flag
                ),
              );
            },
            childCount: _itemCount,
          ),
        ),
      ),
    );
  }

  // Modify the signature to accept isSelected
  Widget _buildVerticalTick(double value, bool isWholeNumber, bool isSelectable, bool isSelected) {
    double lineHeight = isWholeNumber ? 30 : 15;

    // Decide the color based on selectable + selected
    Color tickColor;
    if (!isSelectable) {
      tickColor = Colors.red; // outside allowed range
    } else if (isSelected) {
      tickColor = Colors.lightGreenAccent; // highlight the selected line in green
    } else {
      tickColor = Colors.black; // normal line
    }

    return SizedBox(
      width: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: 2, height: lineHeight, color: tickColor),
          if (isWholeNumber) ...[
            const SizedBox(height: 6),
            Text(
              value.toStringAsFixed(0),
              style: TextStyle(
                fontSize: 12,
                color: tickColor,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMotivationalCard() {
    if (displayedMessage.isEmpty) return const SizedBox.shrink();
    final lines = displayedMessage.split('\n');
    final firstLine = lines[0];
    final secondLine = (lines.length > 1) ? lines[1] : "";

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      padding: const EdgeInsets.all(16),
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
            const SizedBox(height: 4),
            Text(
              secondLine,
              style: const TextStyle(
                  fontSize: 16, color: Colors.black87, fontWeight: FontWeight.bold),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNextButton(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        saveTargetWeightToFirebase();
        _saveTargetWeight();
        navigateWithSlideTransition(context, Nutriactivitylevel(), slideRight: true);
      },
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.symmetric(horizontal: 24),
        height: 50,
        decoration: BoxDecoration(
          color: AppColor.moresolidPrimary,
          borderRadius: BorderRadius.circular(25),
        ),
        child: const Center(
          child: Text(
            "Next",
            style: TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
