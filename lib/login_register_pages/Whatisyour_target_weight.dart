import 'package:exercai_mobile/homepage/starter_page.dart';
import 'package:exercai_mobile/login_register_pages/bodyshape.dart';
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

final TextEditingController targetWeight = TextEditingController();

class _WhatisyourTargetWeightState extends State<WhatisyourTargetWeight> {
  double? currentWeight;
  String displayedMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchCurrentWeight();
    _loadTargetWeight(); // Load stored target weight
    targetWeight.addListener(_calculatePercentage);
  }

  // 🔹 Load saved target weight from SharedPreferences
  Future<void> _loadTargetWeight() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      targetWeight.text = prefs.getString('targetWeight') ?? '';
    });
  }

  // 🔹 Save target weight to SharedPreferences
  Future<void> _saveTargetWeight() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('targetWeight', targetWeight.text.trim());
  }

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

  //ibalik yung message na Current Weight Not Available pag nag error
  void _calculatePercentage() {
    if (currentWeight == null || currentWeight == 0) {
      setState(() {
        displayedMessage = '';
      });
      return;
    }

    String newMessage = '';

    if (targetWeight.text.isEmpty) {
      newMessage = ''; // Clear message when empty
    } else {
      double? target = double.tryParse(targetWeight.text);
      if (target == null) {
        newMessage = 'Invalid weight value';
      } else {
        double difference = target - currentWeight!;
        double percent = (difference.abs() / currentWeight!) * 100;
        String gainOrLose = difference > 0 ? 'gain' : 'lose';

        if (percent <= 10) {
          newMessage = '👌A piece of cake:\nYou will $gainOrLose ${percent.toStringAsFixed(1)}% of your weight';
        } else if (percent <= 20) {
          newMessage = '💦Achievable Goal\nYou will $gainOrLose ${percent.toStringAsFixed(1)}% of your weight';
        } else if (percent == 0) {
          newMessage = '😃Keep Going\nMaintain your current weight';
        } else {
          newMessage = '💪🏻 Challenging Goal\nYou will $gainOrLose ${percent.toStringAsFixed(1)}% of your weight';
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
        return Colors.green;
      case '😃Keep going:':
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
    if (user != null && targetWeight.text.isNotEmpty) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(user.email)
          .set({
        'targetWeight': targetWeight.text.trim(),
      }, SetOptions(merge: true));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a target weight before proceeding.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundgrey,
      appBar: AppbarSection(context),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            TextSection(),
            _buildTextFieldSection(),
            const SizedBox(height: 70),
            buttonNext(context)
          ],
        ),
      ),
    );
  }

  Widget _buildTextFieldSection() {
    return Container(
      height: 270,
      decoration: BoxDecoration(
        color: AppColor.primary,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              child: const Column(
                children: [
                  SizedBox(height: 10),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 25, left: 25),
            child: Container(
              child: Column(
                children: [
                  const SizedBox(height: 25),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(boxShadow: [
                            BoxShadow(
                                color: AppColor.shadow.withOpacity(0.5),
                                blurRadius: 40,
                                spreadRadius: 0.0)
                          ]),
                          child: TextField(
                            controller: targetWeight,
                            keyboardType: TextInputType.number,
                            onChanged: (value) => _saveTargetWeight(), // Save when typing
                            decoration: InputDecoration(
                              prefixIcon: const Icon(Icons.monitor_weight_outlined),
                              hintText: 'Weight (kg)',
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: const BorderSide(color: Colors.transparent),
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
                            borderRadius: BorderRadius.circular(12)),
                        child: Center(
                            child: Text(
                              "kg",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                  color: AppColor.yellowtext),
                            )),
                      )
                    ],
                  ),
                  if (displayedMessage.isNotEmpty)
                    Column(
                      children: [
                        const SizedBox(height: 30),
                        Text(
                          displayedMessage.split('\n')[0], // First line (goal category)
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                            color: _getMessageColor(displayedMessage.split('\n')[0]),
                          ),
                        ),
                        if (displayedMessage.contains('\n'))
                          Text(
                            displayedMessage.split('\n')[1], // Second line (gain/lose %)
                            style: const TextStyle(
                              fontSize: 17,
                              color: Colors.black,
                            ),
                          ),
                      ],
                    ),

                  const SizedBox(height: 60),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  GestureDetector buttonNext(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        saveTargetWeightToFirebase();
        _saveTargetWeight(); // Save selection before navigation
        navigateWithSlideTransition(context, Bodyshape(), slideRight: true);
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
                  border: Border.all(
                      width: 2, color: AppColor.buttonSecondary),
                  boxShadow: [
                    BoxShadow(
                        color: AppColor.buttonSecondary.withOpacity(0.7),
                        blurRadius: 90,
                        spreadRadius: 0.1)
                  ]),
              child: Center(
                  child: Text(
                    "Next",
                    style: TextStyle(
                        color: AppColor.textwhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}

Container TextSection() {
  return Container(
    height: 130,
    child: Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, top: 25),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("What is your Target weight?",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 30)),
            const SizedBox(height: 10),
            const Expanded(
              child: Text(
                "",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 15),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

AppBar AppbarSection(BuildContext context) {
  return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        onPressed: () {
          navigateWithSlideTransition(context, WorkoutLevel(), slideRight: false);
        },
        icon: Icon(Icons.arrow_back, color: AppColor.yellowtext),
      )
  );
}