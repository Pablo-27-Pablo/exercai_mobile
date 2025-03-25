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
  String? goal; // NEW: store the user’s goal from Firebase
  Map<String, dynamic>? nutritionData;
  String errorMessage = '';
  bool isLoading = false;

  // Store our calorie calculation results here
  Map<String, double>? _calorieResults;

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
            goal = userDoc["goal"]; // NEW: read the "goal" field
          });

          // Once we have the user's data, calculate our custom calorie estimates
          _calorieResults = _calculateCalories();

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

  /// Fetch nutrition data from the external API using Firebase values
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
          'X-Rapidapi-Key': '81efa21332mshc3d43597ee9e475p14e998jsn7776838f3ddd', //'dc1bad7b61msh8f8c3cb4e545871p10b76djsnedc2c2ff9c22',
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

  // Calculate calories using Mifflin-St Jeor + activity factor.
  // NEW: Also return BMR and activityFactor in the map for computation details.
  Map<String, double> _calculateCalories() {
    double parseDouble(String? val) {
      if (val == null) return 0;
      return double.tryParse(val) ?? 0;
    }

    double w = parseDouble(weight); // kg
    double h = parseDouble(height); // cm
    double a = parseDouble(age);    // years

    // Default factor if not recognized
    double factor = 1.2;
    if (activityLevel == 'Inactive') {
      factor = 1.2;
    } else if (activityLevel == 'Low Active') {
      factor = 1.375;
    } else if (activityLevel == 'Active') {
      factor = 1.55;
    } else if (activityLevel == 'Very Active') {
      factor = 1.725;
    }

    double bmr;
    if ((gender ?? '').toLowerCase() == 'male') {
      // Mifflin-St Jeor (Men)
      bmr = 10 * w + 6.25 * h - 5 * a + 5;
    } else {
      // Mifflin-St Jeor (Women)
      bmr = 10 * w + 6.25 * h - 5 * a - 161;
    }

    double tdee = bmr * factor;

    // Example deficits/surpluses
    double maintain = tdee;
    double mildLoss = tdee - 250;
    double loss = tdee - 500;
    double extremeLoss = tdee - 1000;
    double mildGain = tdee + 250;
    double moderateGain = tdee + 500; // ~0.5 kg/week
    double fastGain = tdee + 1000;

    // Compute percentages
    int tdeePct = 100; // "Maintain weight" is always 100%
    int mildLossPct = ((mildLoss / tdee) * 100).round();
    int lossPct = ((loss / tdee) * 100).round();
    int extremeLossPct = ((extremeLoss / tdee) * 100).round();
    int mildGainPct = ((mildGain / tdee) * 100).round();
    int moderateGainPct = ((moderateGain / tdee) * 100).round();
    int fastGainPct = ((fastGain / tdee) * 100).round();

    // Return all as a map including BMR and activityFactor for detailed display.
    return {
      'bmr': bmr,
      'activityFactor': factor,
      'tdee': tdee,
      'maintain': maintain,
      'mildLoss': mildLoss,
      'loss': loss,
      'extremeLoss': extremeLoss,
      'mildGain': mildGain,
      'moderateGain': moderateGain,
      'fastGain': fastGain,
      'tdeePct': tdeePct.toDouble(),
      'mildLossPct': mildLossPct.toDouble(),
      'lossPct': lossPct.toDouble(),
      'extremeLossPct': extremeLossPct.toDouble(),
      'mildGainPct': mildGainPct.toDouble(),
      'moderateGainPct': moderateGainPct.toDouble(),
      'fastGainPct': fastGainPct.toDouble(),
    };
  }


  // Build a Card to display the calorie suggestions (as before)
  Widget _buildCalorieCard(Map<String, double> cals) {
    return _buildTable(
      "Calorie Suggestions",
      [
        [
          "Maintain weight",
          "${cals['tdee']?.toStringAsFixed(0)} Calories/day",
          //Pecent tong sa ilalim alisin muna
          //"${cals['tdeePct']?.toStringAsFixed(0)}%"
        ],
        /*[
          "Mild weight loss (0.25 kg/week)",
          "${cals['mildLoss']?.toStringAsFixed(0)} Calories/day",
          "${cals['mildLossPct']?.toStringAsFixed(0)}%"
        ],*/
        [
          "Weight loss\n", //"Weight loss\n(0.5 kg/week)"
          "${cals['loss']?.toStringAsFixed(0)} Calories/day",
          //Pecent tong sa ilalim alisin muna
          //"${cals['lossPct']?.toStringAsFixed(0)}%"
        ],
        /*[
          "Extreme weight loss\n(1 kg/week)",
          "${cals['extremeLoss']?.toStringAsFixed(0)} Calories/day",
          "${cals['extremeLossPct']?.toStringAsFixed(0)}%"
        ],*/
        /*[
          "Mild weight gain (0.25 kg/week)",
          "${cals['mildGain']?.toStringAsFixed(0)} Calories/day",
          "${cals['mildGainPct']?.toStringAsFixed(0)}%"
        ],*/
        [
          "Weight gain\n", //"Weight gain\n(0.5 kg/week)"
          "${cals['moderateGain']?.toStringAsFixed(0)} Calories/day",
          //Pecent tong sa ilalim alisin muna
          //"${cals['moderateGainPct']?.toStringAsFixed(0)}%"
        ],
        /*[
          "Fast weight gain (1 kg/week)",
          "${cals['fastGain']?.toStringAsFixed(0)} Calories/day",
          "${cals['fastGainPct']?.toStringAsFixed(0)}%"
        ],*/
      ],
    );
  }

  /// NEW: Return the chosen calorie suggestion based on the user's goal
  String _getGoalBasedCalories() {
    if (_calorieResults == null) {
      // If for some reason we haven't computed or there's an error,
      // fall back to the original API data
      return _getData("BMI_EER", "Estimated Daily Caloric Needs");
    }

    // Switch on the user’s "goal"
    switch (goal?.toLowerCase()) {
      case "maintain":
        return "${_calorieResults!['tdee']?.toStringAsFixed(0) ?? 'N/A'} Calories/day";
      case "lose weight":
        return "${_calorieResults!['loss']?.toStringAsFixed(0) ?? 'N/A'} Calories/day";
      case "muscle mass gain":
        return "${_calorieResults!['moderateGain']?.toStringAsFixed(0) ?? 'N/A'} Calories/day";
      default:
      // If the goal isn't recognized, just return the original API data
        return _getData("BMI_EER", "Estimated Daily Caloric Needs");
    }
  }

  // Build a Card to display detailed calorie computation
  /*Widget _buildCalorieComputationCard(Map<String, double> cals) {
    return _buildTable(
      "Calorie Computation Details",
      [
        ["BMR", "${cals['bmr']?.toStringAsFixed(0)} Calories"],
        ["Activity Factor", "${cals['activityFactor']?.toStringAsFixed(2)}"],
        ["TDEE (BMR x Factor)", "${cals['tdee']?.toStringAsFixed(0)} Calories/day"],
        ["Mild Weight Loss (0.25 kg/week)", "${cals['mildLoss']?.toStringAsFixed(0)} Calories/day"],
        ["Weight Loss (0.5 kg/week)", "${cals['loss']?.toStringAsFixed(0)} Calories/day"],
        ["Extreme Weight Loss (1 kg/week)", "${cals['extremeLoss']?.toStringAsFixed(0)} Calories/day"],
        ["Mild Weight Gain (0.25 kg/week)", "${cals['mildGain']?.toStringAsFixed(0)} Calories/day"],
        ["Weight Gain (0.5 kg/week)", "${cals['moderateGain']?.toStringAsFixed(0)} Calories/day"],
        ["Fast Weight Gain (1 kg/week)", "${cals['fastGain']?.toStringAsFixed(0)} Calories/day"],
      ],
    );
  }*/

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
              // Use 3 columns if data has 3 entries per row
              columnWidths: {
                0: FlexColumnWidth(2),
                1: FlexColumnWidth(2),
                if (data.isNotEmpty && data[0].length == 3) 2: FlexColumnWidth(1),
              },
              children: data.asMap().entries.map((entry) {
                final row = entry.value;
                final index = entry.key;
                return TableRow(
                  decoration: BoxDecoration(
                    color: index % 2 == 0 ? Colors.grey.shade50 : Colors.white,
                  ),
                  children: row.map((cell) {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        cell,
                        style: TextStyle(fontSize: 16, color: Colors.black87),
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
      ["Goal", goal ?? "N/A"], // Show user’s goal if you like
    ]);
  }

  /// Overwrite the second row's "Estimated Daily Caloric Needs" with the user’s goal-based result
  Widget _buildResultsTable() {
    return _buildTable("Your Calculated Results", [
      ["Body Mass Index (BMI)", _getData("BMI_EER", "BMI")],
      [
        "Estimated Daily Caloric Needs",
        _getGoalBasedCalories(), // Overwrite with the chosen calorie
      ],
    ]);
  }


  /*Widget _buildMacronutrientsTable() {
    return _buildTableFromJson(
      "Daily Recommended Macronutrient Intake",
      nutritionData?['macronutrients_table']?['macronutrients-table'],
    );
  }*/

  Widget _buildMacronutrientsTable() {
    // 1. Get the JSON data for macronutrients table.
    final data = nutritionData?['macronutrients_table']?['macronutrients-table'];
    if (data == null || data is! List) return SizedBox();

    // 2. Convert the JSON list into a List<List<String>>.
    List<List<String>> tableData = data.map<List<String>>((row) {
      return row.map<String>((cell) => cell.toString()).toList();
    }).toList();

    // 3. If the user's goal is one of the ones we handle, overwrite the "Protein" row.
    String userGoal = (goal ?? '').toLowerCase();
    if (userGoal == 'muscle mass gain' || userGoal == 'lose weight' || userGoal == 'maintain') {
      double weightKg = double.tryParse(weight ?? '0') ?? 0;
      for (var row in tableData) {
        if (row.isNotEmpty && row[0].toLowerCase().contains('protein')) {
          if (userGoal == 'muscle mass gain') {
            double lowerProtein = weightKg * 1.6;
            double upperProtein = weightKg * 2.2;
            row[1] = '${lowerProtein.toStringAsFixed(0)}–${upperProtein.toStringAsFixed(0)} g/day (muscle gain)';
          } else if (userGoal == 'lose weight') {
            double lowerProtein = weightKg * 2.0;
            double upperProtein = weightKg * 2.5;
            row[1] = '${lowerProtein.toStringAsFixed(0)}–${upperProtein.toStringAsFixed(0)} g/day (weight loss)';
          } else if (userGoal == 'maintain') {
            double lowerProtein = weightKg * 1.2;
            double upperProtein = weightKg * 1.6;
            row[1] = '${lowerProtein.toStringAsFixed(0)}–${upperProtein.toStringAsFixed(0)} g/day (maintain)';
          }
        }
      }
    }

    // 4. Build the table using your existing _buildTable() function.
    return _buildTable("Daily Recommended Macronutrient Intake", tableData);
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

  /// Definitions Section
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

  /// A Card that shows "How It Works" explanation
  Widget _buildHowItWorksCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: EdgeInsets.symmetric(vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Gradient header for "How It Works"
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
              "How It Works",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          // Explanation content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. User Inputs
                Text(
                  "1. User Inputs:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text("• Age (years)\n• Height (cm)\n• Weight (kg)\n• Gender (Male/Female)\n• Activity Level (Inactive, Low Active, Active, Very Active)"),
                SizedBox(height: 12),

                // 2. BMR Calculation
                Text(
                  "2. BMR Calculation:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text("Using the Mifflin-St Jeor Equation:\n"),
                Text("Men:   BMR = 10 × W + 6.25 × H − 5 × A + 5\nWomen: BMR = 10 × W + 6.25 × H − 5 × A − 161",
                    style: TextStyle(fontStyle: FontStyle.italic)),
                SizedBox(height: 12),

                // 3. Activity Factor
                Text(
                  "3. Activity Factor:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text("• Inactive: 1.2\n• Low Active: 1.375\n• Active: 1.55\n• Very Active: 1.725"),
                SizedBox(height: 4),
                Text("We multiply BMR by the chosen factor to get TDEE (Total Daily Energy Expenditure)."),
                SizedBox(height: 12),

                // 4. Calorie Targets
                Text(
                  "4. Calorie Targets:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text("• Maintenance ≈ TDEE\n• Mild weight loss ≈ TDEE − 250\n• Weight loss ≈ TDEE − 500\n• Extreme weight loss ≈ TDEE − 1000\n• Mild weight gain ≈ TDEE + 250\n• Weight gain ≈ TDEE + 500\n• Fast weight gain ≈ TDEE + 1000"),
                SizedBox(height: 4),
                Text("(1 kg/week loss or gain is not recommended without medical supervision.)",
                    style: TextStyle(fontStyle: FontStyle.italic)),
                SizedBox(height: 12),

                // 5. Protein Intake Recommendations
                Text(
                  "5. Protein Intake Recommendations:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                SizedBox(height: 4),
                Text(
                  "For muscle mass gain, it's recommended to consume approximately 1.6–2.2 g of protein per kg of body weight per day.\n"
                      "For example, if you weigh 70 kg:\n"
                      "• Lower end: 70 × 1.6 = 112 g/day\n"
                      "• Upper end: 70 × 2.2 = 154 g/day",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 12),
                Text(
                  "For weight loss, a higher protein intake helps preserve lean muscle mass, so it's recommended to consume around 2.0–2.5 g per kg of body weight per day.\n"
                      "For example, if you weigh 70 kg:\n"
                      "• Lower end: 70 × 2.0 = 140 g/day\n"
                      "• Upper end: 70 × 2.5 = 175 g/day",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 12),
                Text(
                  "For maintenance, a typical recommendation is about 1.2–1.6 g per kg of body weight per day.\n"
                      "For example, if you weigh 70 kg:\n"
                      "• Lower end: 70 × 1.2 = 84 g/day\n"
                      "• Upper end: 70 × 1.6 = 112 g/day",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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



                      // Show our custom calorie suggestions card
                      if (_calorieResults != null)
                        _buildCalorieCard(_calorieResults!),


                      // NEW: Show detailed computation of the calorie suggestion
                      /*if (_calorieResults != null)
                        _buildCalorieComputationCard(_calorieResults!),*/

                      if (nutritionData != null) ...[
                        _buildResultsTable(),
                        _buildMacronutrientsTable(),
                        _buildVitaminsTable(),
                        _buildMineralsTable(),
                        _buildDefinitionsSection(),
                      ],
                      // Show our custom "How It Works" card
                      _buildHowItWorksCard(),
                      SizedBox(height: 20),
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
