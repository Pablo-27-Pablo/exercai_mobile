import 'dart:math' as math;
import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fl_chart/fl_chart.dart';

// A helper function to safely convert a value to double.
double parseToDouble(dynamic value) {
  if (value is String) {
    return double.tryParse(value) ?? 0;
  } else if (value is num) {
    return value.toDouble();
  } else {
    return 0;
  }
}

// A simple model class for user data
class UserData {
  final int age;
  final String gender;
  final String goal;   // e.g. "lose weight", "muscle mass gain", "maintain"
  final double height; // assumed to be in cm
  final String nutriActivityLevel; // "Inactive", "Low Active", "Active", "Very Active"
  final double targetWeight;
  final double weight;
  final String workoutLevel; // "beginner", "intermediate", "advanced"

  UserData({
    required this.age,
    required this.gender,
    required this.goal,
    required this.height,
    required this.nutriActivityLevel,
    required this.targetWeight,
    required this.weight,
    required this.workoutLevel,
  });

  // Helper factory for reading from Firestore
  factory UserData.fromMap(Map<String, dynamic> data) {
    return UserData(
      age: data['age'] ?? 0,
      gender: data['gender'] ?? '',
      goal: data['goal'] ?? '',
      height: parseToDouble(data['height'] ?? 0),
      nutriActivityLevel: data['nutriActivitylevel'] ?? '',
      targetWeight: parseToDouble(data['targetWeight'] ?? 0),
      weight: parseToDouble(data['weight'] ?? 0),
      workoutLevel: data['workoutLevel'] ?? '',
    );
  }
}

// A simple model for the predicted result
class Prediction {
  final DateTime goalDate;
  final double weeksToGoal;

  Prediction({required this.goalDate, required this.weeksToGoal});
}

// A data class for plotting points
class WeightProgress {
  final DateTime date;
  final double weight;
  WeightProgress({required this.date, required this.weight});
}

class PredictiveAnalysisPage extends StatelessWidget {
  final String userEmail; // The Firestore document ID or userId
  const PredictiveAnalysisPage({Key? key, required this.userEmail})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use a white background or any light color from your theme.
    return Scaffold(
      backgroundColor: AppColor.backgroundWhite,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundWhite,
        elevation: 1,
        centerTitle: true,
        title: const Text(
          'Weight Analysis',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(userEmail)
            .snapshots(),
        builder: (context, snapshot) {
          // 1) Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2) Error
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // 3) No data
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('No user data found.'));
          }

          // 4) Parse user data
          final data = snapshot.data!.data() as Map<String, dynamic>;
          final userData = UserData.fromMap(data);

          // 5) Compute prediction
          final prediction = computePrediction(userData);

          // 6) Generate chart data
          final chartData = generateChartData(
            currentWeight: userData.weight,
            targetWeight: userData.targetWeight,
            weeksToGoal: prediction.weeksToGoal,
          );

          if (chartData.isEmpty) {
            return const Center(child: Text('No chart data.'));
          }

          // Convert DateTime-based data to fl_chart’s spots
          final firstDate = chartData.first.date;
          final lastDate = chartData.last.date;
          final totalDays = math.max(1, lastDate.difference(firstDate).inDays);

          final spots = chartData.map((wp) {
            final x = wp.date.difference(firstDate).inDays.toDouble();
            return FlSpot(x, wp.weight);
          }).toList();

          // Calculate min/max for nicer chart scale
          final allWeights = chartData.map((e) => e.weight).toList();
          final minY = allWeights.reduce(math.min);
          final maxY = allWeights.reduce(math.max);

          // We'll highlight the final point (goal point)
          final lastX = spots.last.x;

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Prediction message with a soft gradient background
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            AppColor.superlightPrimary,
                            AppColor.backgroundWhite
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Based on your goal and body data, we predict you’ll reach '
                                '${userData.targetWeight.toStringAsFixed(1)} kg by\n'
                                '${_formatDate(prediction.goalDate)}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 12),
                          // Display current weight and target weight
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Column(
                                children: [
                                  const Text(
                                    'Current Weight',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    '${userData.weight.toStringAsFixed(1)} kg',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  const Text(
                                    'Target Weight',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black54,
                                    ),
                                  ),
                                  Text(
                                    '${userData.targetWeight.toStringAsFixed(1)} kg',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Chart wrapped in a modern card design
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 4,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: SizedBox(
                          height: 300,
                          child: LineChart(
                            LineChartData(
                              minX: 0,
                              maxX: totalDays.toDouble(),
                              minY: minY * 0.95,
                              maxY: maxY * 1.05,
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Colors.grey.shade300,
                                  strokeWidth: 1,
                                ),
                              ),
                              borderData: FlBorderData(show: false),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 40,
                                    getTitlesWidget: (value, meta) => Text(
                                      value.toStringAsFixed(2),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black54,
                                      ),
                                    ),
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    interval: (totalDays / 3)
                                        .floorToDouble()
                                        .clamp(1, 9999),
                                    getTitlesWidget: (value, meta) {
                                      final date = firstDate.add(
                                        Duration(days: value.toInt()),
                                      );
                                      return Text(
                                        '${date.month}/${date.day}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                rightTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                                topTitles: AxisTitles(
                                  sideTitles: SideTitles(showTitles: false),
                                ),
                              ),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: spots,
                                  isCurved: true,
                                  gradient: const LinearGradient(
                                    colors: [
                                      Colors.orange,
                                      Colors.green,
                                    ],
                                  ),
                                  barWidth: 4,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter:
                                        (spot, percent, barData, index) {
                                      // Show dot only at the start and end
                                      if (index == 0 ||
                                          index == spots.length - 1) {
                                        return FlDotCirclePainter(
                                          radius: 5,
                                          color: Colors.red,
                                          strokeWidth: 2,
                                          strokeColor: Colors.white,
                                        );
                                      }
                                      return FlDotCirclePainter(radius: 0);
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.green.withOpacity(0.3),
                                        Colors.green.withOpacity(0.0),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                              // Add a dashed vertical line at the final spot
                              extraLinesData: ExtraLinesData(
                                verticalLines: [
                                  VerticalLine(
                                    x: lastX,
                                    color: Colors.green,
                                    strokeWidth: 1,
                                    dashArray: [5, 5],
                                    label: VerticalLineLabel(
                                      show: true,
                                      labelResolver: (line) =>
                                          _formatDate(prediction.goalDate),
                                      style: const TextStyle(
                                        color: Colors.green,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              // Disable direct line touches for a cleaner design
                              lineTouchData: LineTouchData(enabled: false),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 5),

                  // Bubble label for final weight
                  Align(
                    alignment: Alignment.centerRight,
                    child: Container(
                      margin: const EdgeInsets.only(right: 36, top: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.greenAccent.shade400, Colors.green],
                        ),
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.4),
                            offset: const Offset(0, 2),
                            blurRadius: 6,
                          )
                        ],
                      ),
                      child: Text(
                        '${userData.targetWeight.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // "Great start!" card with a subtle icon
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            offset: const Offset(0, 4),
                            blurRadius: 8,
                          )
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: Colors.green,
                            size: 32,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              "Everything is on track! We'll provide an updated date after you log your current weight.",
                              textAlign: TextAlign.left,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // --------------- NEW: FORMULA CARD ---------------
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blue.shade50],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: Offset(0, 4),
                      )
                    ],
                  ),
                  child: Card(
                    elevation: 0,
                    color: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    margin: EdgeInsets.zero,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header Title
                          Text(
                            "Weight Analysis Formulas",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple.shade700,
                            ),
                          ),
                          const SizedBox(height: 16),
                          // BMR Segment
                          _buildSegment(
                            icon: Icons.fitness_center,
                            title: "Basal Metabolic Rate (BMR)",
                            subtitle:
                            "Mifflin–St. Jeor Equation\n\nFor males:\nBMR = (10 × weight in kg) + (6.25 × height in cm) − (5 × age in years) + 5\n\nFor females:\nBMR = (10 × weight in kg) + (6.25 × height in cm) − (5 × age in years) − 161",
                            backgroundColor: Colors.deepPurple.shade100,
                            iconColor: Colors.deepPurple,
                          ),
                          const SizedBox(height: 12),
                          // TDEE Segment
                          _buildSegment(
                            icon: Icons.local_fire_department,
                            title: "Total Daily Energy Expenditure (TDEE)",
                            subtitle: "TDEE = BMR × Activity Factor × Workout Factor",
                            backgroundColor: Colors.green.shade100,
                            iconColor: Colors.green,
                          ),
                          const SizedBox(height: 12),
                          // Activity Factor Segment
                          _buildSegment(
                            icon: Icons.directions_run,
                            title: "Activity Factor",
                            subtitle:
                            "Based on nutriActivityLevel:\n• Very Active: 1.725\n• Active: 1.55\n• Low Active: 1.375\n• Inactive: 1.2",
                            backgroundColor: Colors.blue.shade100,
                            iconColor: Colors.blue,
                          ),
                          const SizedBox(height: 12),
                          // Workout Factor Segment
                          _buildSegment(
                            icon: Icons.sports_gymnastics,
                            title: "Workout Factor",
                            subtitle:
                            "Based on workoutLevel:\n• Advanced: 1.2\n• Intermediate: 1.1\n• Beginner (or default): 1.0",
                            backgroundColor: Colors.orange.shade100,
                            iconColor: Colors.orange,
                          ),
                          const SizedBox(height: 12),
                          // Daily Calorie Offset & Weight Change Segment
                          _buildSegment(
                            icon: Icons.calculate,
                            title: "Daily Calorie Offset & Weight Change",
                            subtitle:
                            "Goals:\n• Lose weight: –500 kcal/day\n• Muscle mass gain: +300 kcal/day\n• Maintain: 0 kcal/day\n\nDaily Weight Change (kg) = dailyCalorieOffset / 7700",
                            backgroundColor: Colors.red.shade100,
                            iconColor: Colors.red,
                          ),
                          const SizedBox(height: 12),
                          // Time to Reach Target Weight & Goal Date Segment
                          _buildSegment(
                            icon: Icons.calendar_today,
                            title: "Time to Reach Target Weight & Goal Date",
                            subtitle:
                            "Total Weight Change (kg) = targetWeight − currentWeight\nTotal Days = |Total Weight Change / Daily Weight Change|\nWeeks to Goal = Total Days / 7\nGoal Date = Current Date + Total Days",
                            backgroundColor: Colors.purple.shade100,
                            iconColor: Colors.purple,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  /// ---------------------------------------------
  /// UPDATED PREDICTION LOGIC USING Mifflin–St. Jeor
  /// ---------------------------------------------
  Prediction computePrediction(UserData userData) {
    // 1) Calculate TDEE (Total Daily Energy Expenditure)
    final tdee = _calculateTDEE(userData);

    // 2) Decide on daily calorie deficit or surplus based on goal
    double dailyCalorieOffset = 0.0;
    switch (userData.goal.toLowerCase()) {
      case 'lose weight':
        dailyCalorieOffset = -500;
        break;
      case 'muscle mass gain':
        dailyCalorieOffset = 300;
        break;
      case 'maintain':
      default:
        dailyCalorieOffset = 0.0;
        break;
    }

    // 3) Convert daily calorie offset to daily weight change (in kg)
    //    1 kg of fat mass ~ 7700 kcal
    final dailyWeightChangeKg = dailyCalorieOffset / 7700.0;

    // If dailyWeightChangeKg is 0 (maintain), or if TDEE is 0 for some reason:
    if (dailyWeightChangeKg == 0) {
      return Prediction(goalDate: DateTime.now(), weeksToGoal: 0);
    }

    // 4) Calculate how many total kg we need to lose/gain
    final totalKgToChange = userData.targetWeight - userData.weight;

    // 5) Compute total days (absolute value in case of sign mismatch)
    final totalDays = (totalKgToChange / dailyWeightChangeKg).abs();

    // 6) Project the date
    final goalDate = DateTime.now().add(Duration(days: totalDays.round()));
    final weeksToGoal = totalDays / 7.0;

    return Prediction(goalDate: goalDate, weeksToGoal: weeksToGoal);
  }

  /// Calculate TDEE using the Mifflin–St. Jeor formula.
  /// height is assumed to be in cm, weight in kg, age in years.
  double _calculateTDEE(UserData user) {
    // 1) Compute BMR
    double bmr;
    if (user.gender.toLowerCase() == 'male') {
      bmr = (10 * user.weight) + (6.25 * user.height) - (5 * user.age) + 5;
    } else {
      // female
      bmr = (10 * user.weight) + (6.25 * user.height) - (5 * user.age) - 161;
    }

    // 2) Activity factor based on nutriActivityLevel
    double activityFactor;
    switch (user.nutriActivityLevel) {
      case 'Very Active':
        activityFactor = 1.725;
        break;
      case 'Active':
        activityFactor = 1.55;
        break;
      case 'Low Active':
        activityFactor = 1.375;
        break;
      case 'Inactive':
        activityFactor = 1.2;
        break;
      default:
        activityFactor = 1.2; // fallback
        break;
    }

    // 3) Additional workout factor based on workoutLevel
    double workoutFactor;
    switch (user.workoutLevel.toLowerCase()) {
      case 'advanced':
        workoutFactor = 1.2;
        break;
      case 'intermediate':
        workoutFactor = 1.1;
        break;
      default:
      // 'beginner' or unknown
        workoutFactor = 1.0;
        break;
    }

    // 4) TDEE
    return bmr * activityFactor * workoutFactor;
  }

  /// Generate daily points from now until goal date
  List<WeightProgress> generateChartData({
    required double currentWeight,
    required double targetWeight,
    required double weeksToGoal,
  }) {
    final now = DateTime.now();
    final totalDays = (weeksToGoal * 7).round();

    if (totalDays <= 0) {
      // No progress data or immediate result
      return [WeightProgress(date: now, weight: currentWeight)];
    }

    final List<WeightProgress> data = [];
    for (int i = 0; i <= totalDays; i++) {
      final date = now.add(Duration(days: i));
      final fraction = i / totalDays;
      // Linear interpolation from currentWeight to targetWeight
      final weight = currentWeight + (targetWeight - currentWeight) * fraction;
      data.add(WeightProgress(date: date, weight: weight));
    }
    return data;
  }

  String _formatDate(DateTime date) {
    final months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return "${months[date.month - 1]} ${date.day}, ${date.year}";
  }

  // Helper widget for each segmented section
  Widget _buildSegment({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color backgroundColor,
    required Color iconColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: iconColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
