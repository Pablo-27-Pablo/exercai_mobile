import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NutritionCalculatorFirebase extends StatefulWidget {
  @override
  _NutritionCalculatorFirebaseState createState() =>
      _NutritionCalculatorFirebaseState();
}

class _NutritionCalculatorFirebaseState
    extends State<NutritionCalculatorFirebase> {
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
    if (age == null ||
        height == null ||
        weight == null ||
        gender == null ||
        activityLevel == null) {
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
          'X-Rapidapi-Key':
          //'81efa21332mshc3d43597ee9e475p14e998jsn7776838f3ddd', //Api key for animeneko email
          'dc1bad7b61msh8f8c3cb4e545871p10b76djsnedc2c2ff9c22',// Replace with your key: api key for main email
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
          errorMessage =
          'Error: ${response.statusCode} - ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = 'Network error: $e';
      });
    }
  }

  /// Build a table wrapped in a card with a gradient header.
  Widget _buildTable(String title, List<List<String>> data) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header section with a gradient background
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.supersolidPrimary,
                  AppColor.superlightPrimary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              title,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Table(
              defaultVerticalAlignment: TableCellVerticalAlignment.middle,
              columnWidths: {0: FlexColumnWidth(2), 1: FlexColumnWidth(3)},
              children: data.asMap().entries.map((entry) {
                final row = entry.value;
                final index = entry.key;
                return TableRow(
                  decoration: BoxDecoration(
                    color: index % 2 == 0
                        ? Colors.grey.shade50
                        : Colors.white,
                  ),
                  children: row.map((cell) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        cell,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Dynamically convert JSON list into a table.
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
      [
        "Estimated Daily Caloric Needs",
        _getData("BMI_EER", "Estimated Daily Caloric Needs"),
      ],
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

  /// NEW: Definitions Section
  /// A visually appealing card with a gradient header and expansion tiles for each definition.
  Widget _buildDefinitionsSection() {
    final List<Map<String, String>> definitions = [
      {
        "title": "Acceptable Macronutrient Distribution Ranges (AMDRs)",
        "description":
        "Ranges of macronutrient intakes that are associated with reduced risk of chronic disease, while providing recommended intakes of other essential nutrients."
      },
      {
        "title": "Adequate Intake (AI)",
        "description":
        "The recommended average daily intake level based on observed or experimentally determined approximations or estimates of nutrient intake by a group of apparently healthy people that are assumed to be adequate—used when an RDA cannot be determined."
      },
      {
        "title": "Dietary Reference Intakes (DRI)",
        "description":
        "Set of four reference values: Estimated Average Requirements (EAR), Recommended Dietary Allowances (RDA), Adequate Intakes (AI) and Tolerable Upper Intake Levels (UL)."
      },
      {
        "title": "Electrolytes",
        "description":
        "Includes sodium, chloride, potassium, and inorganic sulfate."
      },
      {
        "title": "Estimated Average Requirement (EAR)",
        "description":
        "The average daily nutrient intake level estimated to meet the requirement of half the healthy individuals in a particular life stage and gender group."
      },
      {
        "title": "Estimated Energy Requirement (EER)",
        "description":
        "The average dietary energy intake that is predicted to maintain energy balance in a healthy adult of a defined age, gender, weight, height, and level of physical activity consistent with good health."
      },
      {
        "title": "Macronutrients",
        "description":
        "Includes carbohydrate, fiber, fat, fatty acids, cholesterol, protein, and amino acids."
      },
      {
        "title": "mcg",
        "description": "Micrograms"
      },
      {
        "title": "mg",
        "description": "Milligrams"
      },
      {
        "title": "Micronutrients",
        "description":
        "Includes both Vitamins and Elements (Minerals)."
      },
      {
        "title": "Minerals (Elements)",
        "description":
        "Includes arsenic, boron, calcium, chromium, copper, fluoride, iodine, iron, magnesium, manganese, molybdenum, nickel, phosphorus, selenium, silicon, vanadium and zinc."
      },
      {
        "title": "NA",
        "description": "No information available."
      },
      {
        "title": "ND",
        "description":
        "Not determinable due to lack of data of adverse effects in this age group and concern with regard to lack of ability to handle excess amounts. Source of intake should be from food only to prevent high levels of intake."
      },
      {
        "title": "Recommended Daily Allowance (RDA)",
        "description":
        "The average daily dietary nutrient intake level sufficient to meet the nutrient requirement of nearly all healthy individuals in a particular life stage and gender group."
      },
      {
        "title": "Tolerable Upper Level Intake (UL)",
        "description":
        "The highest average daily nutrient intake level that is likely to pose no risk of adverse health effects to almost all individuals in the general population. As intake increases above the UL, the potential risk of adverse effects may increase."
      },
      {
        "title": "Vitamins",
        "description":
        "Includes biotin, choline, folate, niacin, pantothenic acid, riboflavin, thiamin, vitamin A, vitamin B6, vitamin B12, vitamin C, vitamin D, vitamin E and vitamin K."
      },
    ];

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient header for the Definitions section
          Container(
            padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColor.supersolidPrimary,
                  AppColor.superlightPrimary,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Text(
              "Important Nutrient Definitions",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Expansion tiles for each definition
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Column(
              children: definitions.map((def) {
                return Card(
                  color: Colors.grey.shade50,
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 6),
                  child: ExpansionTile(
                    tilePadding: EdgeInsets.symmetric(horizontal: 16),
                    title: Text(
                      def["title"]!,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.vertical(
                            bottom: Radius.circular(8),
                          ),
                        ),
                        child: Text(
                          def["description"]!,
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  /// Safely retrieve a value from the nutrition JSON.
  String _getData(String category, String key) {
    return nutritionData?[category]?[key]?.toString() ?? "N/A";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: AppColor.primary,
        elevation: 2,
      ),
      backgroundColor: Colors.white,
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          // Top header area with a big curved bottom border
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColor.primary,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(40),
                bottomRight: Radius.circular(40),
              ),
            ),
            child: Column(
              children: [
                SizedBox(height: 20),
                Text(
                  "Nutrition and Calories \nSuggestion For You",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColor.backgroundWhite,
                  ),
                  textAlign: TextAlign.center,
                ),
                largeGap,
              ],
            ),
          ),

          // Main scrollable content
          Expanded(
            child: SingleChildScrollView(
              child: Container(
                padding: EdgeInsets.only(left: 20, right: 20, bottom: 20),
                child: Column(
                  children: [
                    SizedBox(height: 20),
                    if (errorMessage.isNotEmpty)
                      Card(
                        color: Colors.red.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            errorMessage,
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
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
                        // Insert the new definitions section here
                        _buildDefinitionsSection(),
                      ],
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: ClipRRect(
        borderRadius: BorderRadius.circular(30), // Custom radius
        child: FloatingActionButton(
          onPressed: fetchUserData,
          backgroundColor: AppColor.moresolidPrimary,
          child: isLoading
              ? CircularProgressIndicator(color: AppColor.backgroundWhite)
              : Icon(Icons.refresh, color: AppColor.backgroundWhite),
          tooltip: "Reload Data",
        ),
      ),
    );
  }
}
