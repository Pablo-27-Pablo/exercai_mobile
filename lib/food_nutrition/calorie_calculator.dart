import 'package:flutter/material.dart';

class CalorieCalculatorPage extends StatefulWidget {
  const CalorieCalculatorPage({Key? key}) : super(key: key);

  @override
  State<CalorieCalculatorPage> createState() => _CalorieCalculatorPageState();
}

class _CalorieCalculatorPageState extends State<CalorieCalculatorPage> {
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();

  String _selectedGender = 'Male';
  String _selectedActivity = 'Inactive';

  // Variables to store results
  double? _maintenanceCalories;
  double? _mildLossCalories;
  double? _lossCalories;
  double? _extremeLossCalories;
  double? _mildGainCalories;
  double? _fastGainCalories;

  // Common activity factors (adjust as needed)
  // You can rename them to match your design, e.g. "Sedentary", "Lightly Active", etc.
  final Map<String, double> _activityFactor = {
    'Inactive': 1.2,
    'Low Active': 1.375,
    'Active': 1.55,
    'Very Active': 1.725,
  };

  void _calculateCalories() {
    // Parse input
    final int age = int.tryParse(_ageController.text) ?? 0;
    final double height = double.tryParse(_heightController.text) ?? 0;
    final double weight = double.tryParse(_weightController.text) ?? 0;

    if (age <= 0 || height <= 0 || weight <= 0) {
      // Show error or return
      setState(() {
        _maintenanceCalories = null;
        _mildLossCalories = null;
        _lossCalories = null;
        _extremeLossCalories = null;
        _mildGainCalories = null;
        _fastGainCalories = null;
      });
      return;
    }

    // Calculate BMR using Mifflin-St Jeor Equation
    double bmr;
    if (_selectedGender == 'Male') {
      // For men: BMR = 10W + 6.25H - 5A + 5
      bmr = 10 * weight + 6.25 * height - 5 * age + 5;
    } else {
      // For women: BMR = 10W + 6.25H - 5A - 161
      bmr = 10 * weight + 6.25 * height - 5 * age - 161;
    }

    // Multiply by activity factor
    double tdee = bmr * (_activityFactor[_selectedActivity] ?? 1.2);

    // Round to make it more user-friendly
    tdee = tdee.roundToDouble();

    // Define deficits/surpluses
    // Adjust these numbers as you prefer for mild, moderate, etc.
    double mildLoss = tdee - 250;
    double loss = tdee - 500;
    double extremeLoss = tdee - 1000;
    double mildGain = tdee + 250;
    double fastGain = tdee + 500;

    // Optional: If you want to ensure values don't go below recommended thresholds, you can clamp them:
    // For demonstration, let's keep them as is but you could do something like:
    // mildLoss = mildLoss < 1200 ? 1200 : mildLoss; // for women
    // etc.

    setState(() {
      _maintenanceCalories = tdee;
      _mildLossCalories = mildLoss;
      _lossCalories = loss;
      _extremeLossCalories = extremeLoss;
      _mildGainCalories = mildGain;
      _fastGainCalories = fastGain;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calorie Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Age
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Age (years)',
              ),
            ),
            // Height
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Height (cm)',
              ),
            ),
            // Weight
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Weight (kg)',
              ),
            ),
            // Gender
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Gender:'),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedGender,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedGender = newValue ?? 'Male';
                    });
                  },
                  items: <String>['Male', 'Female']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            // Activity
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Activity Level:'),
                const SizedBox(width: 16),
                DropdownButton<String>(
                  value: _selectedActivity,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedActivity = newValue ?? 'Inactive';
                    });
                  },
                  items: _activityFactor.keys
                      .map<DropdownMenuItem<String>>((String key) {
                    return DropdownMenuItem<String>(
                      value: key,
                      child: Text(key),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Calculate button
            ElevatedButton(
              onPressed: _calculateCalories,
              child: const Text('Calculate'),
            ),
            const SizedBox(height: 16),
            // Results
            if (_maintenanceCalories != null) ...[
              ResultRow(
                label: 'Maintain weight',
                calories: _maintenanceCalories!,
                percentage: 100,
              ),
              const SizedBox(height: 8),
              ResultRow(
                label: 'Mild weight loss',
                calories: _mildLossCalories!,
                // example percentage: mildLoss / maintain * 100
                percentage: (_mildLossCalories! / _maintenanceCalories! * 100)
                    .round(),
              ),
              const SizedBox(height: 8),
              ResultRow(
                label: 'Weight loss',
                calories: _lossCalories!,
                percentage: (_lossCalories! / _maintenanceCalories! * 100)
                    .round(),
              ),
              const SizedBox(height: 8),
              ResultRow(
                label: 'Extreme weight loss',
                calories: _extremeLossCalories!,
                percentage:
                (_extremeLossCalories! / _maintenanceCalories! * 100)
                    .round(),
              ),
              const Divider(height: 32),
              ResultRow(
                label: 'Mild weight gain',
                calories: _mildGainCalories!,
                percentage: (_mildGainCalories! / _maintenanceCalories! * 100)
                    .round(),
              ),
              const SizedBox(height: 8),
              ResultRow(
                label: 'Fast weight gain',
                calories: _fastGainCalories!,
                percentage: (_fastGainCalories! / _maintenanceCalories! * 100)
                    .round(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// A small widget to display the result row
class ResultRow extends StatelessWidget {
  final String label;
  final double calories;
  final int percentage;

  const ResultRow({
    Key? key,
    required this.label,
    required this.calories,
    required this.percentage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label),
        ),
        Expanded(
          flex: 2,
          child: Text(
            '${calories.toStringAsFixed(0)} Calories/day',
            textAlign: TextAlign.center,
          ),
        ),
        Expanded(
          flex: 1,
          child: Text(
            '$percentage%',
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}
