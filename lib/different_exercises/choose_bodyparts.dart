import 'package:exercai_mobile/different_exercises/bodypart_exercises/back_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/cardio_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/chest_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/lower_arms_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/lower_legs_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/neck_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/shoulders_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/upper_arms_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/upper_legs_allExercises.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/waist_allExercises.dart';
import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:exercai_mobile/main.dart';

import 'package:flutter/material.dart';

class ChooseBodyparts extends StatefulWidget {
  const ChooseBodyparts({super.key});

  @override
  State<ChooseBodyparts> createState() => _ChooseBodypartsState();
}

class _ChooseBodypartsState extends State<ChooseBodyparts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundgrey,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundgrey,
        elevation: 0,
        title: const Text(
          'Different Body Parts',
          style: TextStyle(color: AppColor.purpletext, fontSize: 20,fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.yellow,),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context)=>MainLandingPage()));
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Exercises',
                style: TextStyle(
                  color: AppColor.yellowtext,
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              GestureDetector(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>NeckAllexercises())),
                child: _buildLevelButton(
                  'Neck',
                  AppColor.purpletext,
                  AppColor.yellowtext,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>ChestAllexercises())),
                child: _buildLevelButton(
                  'Chest',
                  AppColor.purpletext,
                  AppColor.yellowtext,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>WaistAllexercises())),
                child: _buildLevelButton(
                  'Waist',
                  AppColor.purpletext,
                  AppColor.yellowtext,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>BackAllexercises())),
                child: _buildLevelButton(
                  'Back',
                  AppColor.purpletext,
                  AppColor.yellowtext,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>ShouldersAllexercises())),
                child: _buildLevelButton(
                  'Shoulders',
                  AppColor.purpletext,
                  AppColor.yellowtext,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>UpperArmsAllexercises())),
                child: _buildLevelButton(
                  'Upper Arms',
                  AppColor.purpletext,
                  AppColor.yellowtext,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>LowerArmsAllexercises())),
                child: _buildLevelButton(
                  'Lower Arms',
                  AppColor.purpletext,
                  AppColor.yellowtext,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>UpperLegsAllexercises())),
                child: _buildLevelButton(
                  'Upper Legs',
                  AppColor.purpletext,
                  AppColor.yellowtext,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>LowerLegsAllexercises())),
                child: _buildLevelButton(
                  'Lower Legs',
                  AppColor.purpletext,
                  AppColor.yellowtext,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: ()=> Navigator.push(context, MaterialPageRoute(builder: (context)=>CardioAllexercises())),
                child: _buildLevelButton(
                  'Cardio',
                  AppColor.purpletext,
                  AppColor.yellowtext,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLevelButton(String text, Color bgColor, Color textColor) {
    return Container(
      height: 80,
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

