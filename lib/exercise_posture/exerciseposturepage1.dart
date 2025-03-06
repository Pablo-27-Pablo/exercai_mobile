import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';

class ExePosturePage1 extends StatefulWidget {
  const ExePosturePage1({super.key});

  @override
  State<ExePosturePage1> createState() => _ExePosturePage1State();
}

class _ExePosturePage1State extends State<ExePosturePage1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundgrey,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundgrey,
        elevation: 0,
        title: const Text(
          'Exercise Posture Correction',
          style: TextStyle(color: AppColor.purpletext, fontSize: 20,fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_left_outlined, color: Colors.yellow,size: 40,),
          onPressed: () {
            // Handle back button functionality
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text(
              'Features',
              style: TextStyle(
                color: AppColor.yellowtext,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            _buildLevelButton(
              'Beginner Level',
              AppColor.purpletext,
              AppColor.yellowtext,
            ),
            const SizedBox(height: 40),
            _buildLevelButton(
              'Intermediate Level',
              Colors.black,
              AppColor.yellowtext,
            ),
            const SizedBox(height: 50),
            _buildLevelButton(
              'Advance Level',
              AppColor.purpletext,
              AppColor.yellowtext,
            ),
          ],
        ),
      ),

    );
  }

  Widget _buildLevelButton(String text, Color bgColor, Color textColor) {
    return Container(
      height: 130,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              text,
              style: TextStyle(
                color: textColor,
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Row(
              children: [
                Text(
                  'Go',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 30,
                  color: textColor,
                ),
              ],
            ),
          ),


        ],
      ),
    );
  }
}

