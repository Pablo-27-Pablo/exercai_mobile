import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class NutritionScreen extends StatefulWidget {
  @override
  _NutritionScreenState createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  String selectedSex = 'Male';
  String selectedActivity = 'Active';
  Map<String, dynamic>? nutritionData;
  String errorMessage = '';

  Future<void> fetchNutritionData() async {
    final age = ageController.text;
    final height = heightController.text;
    final weight = weightController.text;

    if (age.isEmpty || height.isEmpty || weight.isEmpty) {
      setState(() {
        errorMessage = 'Please enter all fields';
      });
      return;
    }

    final url = Uri.parse(
      'https://nutrition-calculator.p.rapidapi.com/api/nutrition-info'
          '?measurement_units=met'
          '&sex=${selectedSex.toLowerCase()}'
          '&age_value=$age'
          '&age_type=yrs'
          '&cm=$height'
          '&kilos=$weight'
          '&activity_level=$selectedActivity'
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
      appBar: AppBar(title: Text('Nutrition Calculator')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildInputFields(),
            SizedBox(height: 20),
            if (errorMessage.isNotEmpty) Text(errorMessage, style: TextStyle(color: Colors.red)),
            if (nutritionData != null) ...[
              _buildEnteredValues(),
              _buildResultsTable(),
              _buildMacronutrientsTable(),
              _buildVitaminsTable(),
              _buildMineralsTable(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInputFields() {
    return Column(
      children: [
        DropdownButton<String>(
          value: selectedSex,
          items: ['Male', 'Female'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) => setState(() => selectedSex = newValue!),
        ),
        TextField(controller: ageController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Age (years)')),
        TextField(controller: heightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Height (cm)')),
        TextField(controller: weightController, keyboardType: TextInputType.number, decoration: InputDecoration(labelText: 'Weight (kg)')),
        DropdownButton<String>(
          value: selectedActivity,
          items: ['Inactive', 'Low Active', 'Active', 'Very Active'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) => setState(() => selectedActivity = newValue!),
        ),
        ElevatedButton(onPressed: fetchNutritionData, child: Text('Calculate')),
      ],
    );
  }

  Widget _buildEnteredValues() {
    return _buildTable("Your Entered Values", [
      ["Sex", selectedSex],
      ["Age", "${ageController.text} years"],
      ["Height", "${heightController.text} cm"],
      ["Weight", "${weightController.text} kg"],
      ["Activity level", selectedActivity],
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
