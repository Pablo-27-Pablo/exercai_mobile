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
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  /// Fetch user data from Firebase Firestore
  Future<void> fetchUserData() async {
    setState(() {
      isLoading = true;
    });

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection("Users")
            .doc(user.email)
            .get();

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
      isLoading = false;
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

  // Helper method to build a beautifully styled table with cards.
  Widget _buildTable(String title, List<List<String>> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: EdgeInsets.symmetric(vertical: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87)),
            SizedBox(height: 12),
            Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(3),
              },
              children: data.map((row) {
                int index = data.indexOf(row);
                return TableRow(
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.grey[200] : Colors.white,
                  ),
                  children: row.map((cell) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        cell,
                        style: TextStyle(fontSize: 14, color: Colors.black87),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // Helper function to dynamically convert JSON list into a table format.
  Widget _buildTableFromJson(String title, dynamic jsonData) {
    if (jsonData == null || jsonData is! List) return SizedBox();
    List<List<String>> tableData = jsonData.map<List<String>>((row) {
      return row.map<String>((cell) => cell.toString()).toList();
    }).toList();
    return _buildTable(title, tableData);
  }

  Widget _buildEnteredValues() {
    return _buildTable("User's Information", [
      ["Sex", gender ?? "N/A"],
      ["Age", "$age years"],
      ["Height", "$height cm"],
      ["Weight", "$weight kg"],
      ["Activity Level", activityLevel ?? "N/A"],
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
        "Daily Recommended Macronutrient Intake", nutritionData?['macronutrients_table']?['macronutrients-table']);
  }

  Widget _buildVitaminsTable() {
    return _buildTableFromJson(
        "Daily Recommended Vitamin Intake", nutritionData?['vitamins_table']?['vitamins-table']);
  }

  Widget _buildMineralsTable() {
    return _buildTableFromJson(
        "Daily Recommended Mineral Intake", nutritionData?['minerals_table']?['essential-minerals-table']);
  }

  /// Helper function to retrieve values safely from JSON.
  String _getData(String category, String key) {
    return nutritionData?[category]?[key]?.toString() ?? "N/A";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nutrition Calculator'),
        centerTitle: true,
        backgroundColor: AppColor.primary,
      ),
      // Use a gradient background to enhance the visual appeal.
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.primary, AppColor.backgroundgrey],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SizedBox(height: 20),
              Text(
                "Nutrition and Calories Suggestion\nFor You",
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 20),
              if (errorMessage.isNotEmpty)
                Card(
                  color: Colors.red[100],
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(errorMessage,
                        style: TextStyle(color: Colors.red, fontSize: 16)),
                  ),
                ),
              if (age != null &&
                  height != null &&
                  weight != null &&
                  gender != null &&
                  activityLevel != null) ...[
                _buildEnteredValues(),
                SizedBox(height: 20),
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
          borderRadius: BorderRadius.circular(30),
        ),
        child: isLoading
            ? CircularProgressIndicator(color: Colors.white)
            : Icon(Icons.refresh),
        tooltip: "Reload Data",
      ),
    );
  }
}
