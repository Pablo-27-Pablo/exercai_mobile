import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NutritionCalculatorFirebase extends StatefulWidget {
  @override
  _NutritionCalculatorFirebaseState createState() => _NutritionCalculatorFirebaseState();
}

class _NutritionCalculatorFirebaseState extends State<NutritionCalculatorFirebase> {
  String? age;
  String? height;
  String? weight;
  String? gender;
  String? activityLevel;
  Map<String, dynamic>? nutritionData;
  String errorMessage = '';
  bool isLoading = false; // <-- Added loading state

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  /// Fetch user data from Firebase Firestore
  Future<void> fetchUserData() async {
    setState(() {
      isLoading = true; // Show loading indicator
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection("Users").doc(user.email).get();

        if (userDoc.exists) {
          setState(() {
            age = userDoc["age"].toString();
            height = userDoc["height"].toString();
            weight = userDoc["weight"].toString();
            gender = userDoc["gender"];
            activityLevel = userDoc["nutriActivitylevel"];
          });

          await fetchNutritionData();
        }
      } catch (e) {
        setState(() {
          errorMessage = 'Error fetching user data: $e';
        });
      }
    }

    setState(() {
      isLoading = false; // Hide loading indicator
    });
  }

  /// Fetch nutrition data from API using Firebase values
  Future<void> fetchNutritionData() async {
    if (age == null || height == null || weight == null || gender == null || activityLevel == null) {
      setState(() {
        errorMessage = 'User data is incomplete in Firebase';
      });
      return;
    }

    final url = Uri.parse(
      'https://nutrition-calculator.p.rapidapi.com/api/nutrition-info'
          '?measurement_units=met'
          '&sex=${gender!.toLowerCase()}'
          '&age_value=$age'
          '&age_type=yrs'
          '&cm=$height'
          '&kilos=$weight'
          '&activity_level=$activityLevel'
          '&pregnancy_lactating=none',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'X-Rapidapi-Key': '81efa21332mshc3d43597ee9e475p14e998jsn7776838f3ddd', // Replace with your key
          'X-Rapidapi-Host': 'nutrition-calculator.p.rapidapi.com',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          nutritionData = data;
          errorMessage = '';
        });
      } else {
        setState(() {
          errorMessage = 'Error: ${response.statusCode} - ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nutrients Suggestion'),backgroundColor: AppColor.primary,),
      body: Container(
        color: AppColor.primary,
        child: isLoading
            ? Center(child: CircularProgressIndicator()) // Show loading spinner
            : SingleChildScrollView(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text("Nutrition Suggestion For You",style: TextStyle(fontSize: 25,fontWeight: FontWeight.bold,color: Colors.white),),
              if (errorMessage.isNotEmpty) Text(errorMessage, style: TextStyle(color: Colors.red)),
              if (age != null && height != null && weight != null && gender != null && activityLevel != null) ...[
                _buildEnteredValues(),
                if (nutritionData != null) ...[
                  _buildResultsTable(),
                  _buildMacronutrientsTable(),
                  _buildVitaminsTable(),
                  _buildMineralsTable(),
                ],
              ],
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: fetchUserData,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Adjust the radius as needed
        ),
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white) // Show loading spinner inside button
            : Icon(Icons.refresh),
        tooltip: "Reload Data",
      ),
    );
  }

  Widget _buildEnteredValues() {
    //User's Information ay dating Your entered values:
    return _buildTable("User's Information", [
      ["Sex", gender ?? "N/A"],
      ["Age", "$age years"],
      ["Height", "$height cm"],
      ["Weight", "$weight kg"],
      ["Activity level", activityLevel ?? "N/A"],
    ]);
  }

  Widget _buildResultsTable() {
    return _buildTable("Your Calculated Results", [
      ["Body Mass Index (BMI)", _getData("BMI_EER", "BMI")],
      ["Estimated Daily Caloric Needs", _getData("BMI_EER", "Estimated Daily Caloric Needs")],
    ]);
  }

  Widget _buildMacronutrientsTable() {
    return _buildTableFromJson(
      "Daily Recommended Macronutrient Intake",
      nutritionData?['macronutrients_table']?['macronutrients-table'],
    );
  }

  Widget _buildVitaminsTable() {
    return _buildTableFromJson(
      "Daily Recommended Vitamin Intake",
      nutritionData?['vitamins_table']?['vitamins-table'],
    );
  }

  Widget _buildMineralsTable() {
    return _buildTableFromJson(
      "Daily Recommended Mineral Intake",
      nutritionData?['minerals_table']?['essential-minerals-table'],
    );
  }

  /// Helper function to retrieve values safely from JSON
  String _getData(String category, String key) {
    return nutritionData?[category]?[key]?.toString() ?? "N/A";
  }

  /// Helper function to build tables dynamically
  Widget _buildTable(String title, List<List<String>> data) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 10),
        Table(
          border: TableBorder.all(color: Colors.black),
          columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
          children: data.map((row) {
            return TableRow(
              children: row.map((cell) {
                return Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(cell, style: TextStyle(fontSize: 14)),
                );
              }).toList(),
              decoration: BoxDecoration(color: data.indexOf(row) % 2 == 0 ? Colors.grey[200] : Colors.white),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Helper function to dynamically convert JSON list into a table format
  Widget _buildTableFromJson(String title, dynamic jsonData) {
    if (jsonData == null || jsonData is! List) return Container();

    List<List<String>> tableData = jsonData.map<List<String>>((row) {
      return row.map<String>((cell) => cell.toString()).toList();
    }).toList();

    return _buildTable(title, tableData);
  }
}
