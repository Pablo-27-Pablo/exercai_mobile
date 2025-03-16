import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class BMIEditProfilePage extends StatefulWidget {
  const BMIEditProfilePage({super.key});

  @override
  State<BMIEditProfilePage> createState() => _BMIEditProfilePageState();
}

// A newly styled weight chart matching the provided screenshot
class WeightChart extends StatelessWidget {
  final double targetWeight;
  final List<Map<String, dynamic>> weightEntries;

  const WeightChart({
    super.key,
    required this.targetWeight,
    required this.weightEntries,
  });

  @override
  Widget build(BuildContext context) {
    // Sort entries by date so they plot in ascending order
    final sortedEntries = [...weightEntries]
      ..sort((a, b) => a['date'].compareTo(b['date']));

    if (sortedEntries.isEmpty) {
      return const SizedBox(
        height: 200,
        child: Center(
          child: Text('No weight entries to display.'),
        ),
      );
    }

    // Extract min & max dates
    final minDate = sortedEntries.first['date'];
    final maxDate = sortedEntries.last['date'];

    // Convert data to FlSpot
    final List<FlSpot> mainSpots = sortedEntries.map((entry) {
      final date = entry['date'] as DateTime;
      final weight = entry['weight'] as double;
      return FlSpot(date.millisecondsSinceEpoch.toDouble(), weight);
    }).toList();

    // Build a dashed line for the goal weight
    final double minX = minDate.millisecondsSinceEpoch.toDouble();
    final double maxX = maxDate.millisecondsSinceEpoch.toDouble() + (86400000 * 3);
    // Add a few extra days so the “Goal” text is more visible on the right

    // For labeling the last data point
    final FlSpot lastSpot = mainSpots.last;

    // Y-axis range
    final allWeights = mainSpots.map((e) => e.y).toList()..add(targetWeight);
    final double minY = allWeights.reduce(min);
    final double maxY = allWeights.reduce(max);
    final double range = maxY - minY;
    final double padding = range == 0 ? 5 : max(range * 0.15, 5);

    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          // Chart range
          minX: minX,
          maxX: maxX,
          minY: (minY - padding),
          maxY: (maxY + padding),

          // Chart border & grid lines
          gridData: FlGridData(show: false),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey.shade300),
          ),

          // Titles & Axis labels
          titlesData: FlTitlesData(
            bottomTitles: AxisTitles(
              axisNameWidget: Text(
                DateFormat('MMMM').format(DateTime.now()), // Displays the current month
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              axisNameSize: 22, // space for "March"
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 86400000 * 7, // label every 7 days
                getTitlesWidget: (value, meta) {
                  final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                  return Padding(
                    padding: const EdgeInsets.only(top: 6.0),
                    child: Text(
                      DateFormat('d').format(date), // day of month
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  );
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  );
                },
              ),
            ),
            rightTitles: const AxisTitles(),
            topTitles: const AxisTitles(),
          ),

          // Interactions
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: Colors.black87,
              getTooltipItems: (spots) => spots.map((spot) {
                final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                return LineTooltipItem(
                  '${DateFormat('MMM dd').format(date)}\n${spot.y.toStringAsFixed(1)} kg',
                  const TextStyle(color: Colors.white),
                );
              }).toList(),
            ),
          ),

          // Plot the lines
          lineBarsData: [
            // 1) The dashed "Goal" line
            LineChartBarData(
              spots: [
                FlSpot(minX, targetWeight),
                FlSpot(maxX, targetWeight),
              ],
              isCurved: false,
              color: Colors.grey,
              dashArray: [6, 6],
              barWidth: 2,
              dotData: const FlDotData(show: false),
              showingIndicators: [1], // so we can label "Goal"
            ),

            // 2) The main weight line with gradient fill
            LineChartBarData(
              spots: mainSpots,
              isCurved: true,
              curveSmoothness: 0.3,
              color: Colors.green.shade600,
              barWidth: 3,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 3,
                    color: Colors.green.shade600,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.green.shade300.withOpacity(0.4),
                    Colors.green.shade100.withOpacity(0.1),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],

          // Extra lines or text for labeling
          extraLinesData: ExtraLinesData(horizontalLines: [
            HorizontalLine(
              y: targetWeight,
              color: Colors.transparent, // We already have a dashed line
              // We just want a text label near the end
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                padding: const EdgeInsets.only(right: 50, bottom: 2),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
                labelResolver: (line) => 'Goal',
              ),
            ),
          ]),
          // A final label on the last data point
          showingTooltipIndicators: [
            ShowingTooltipIndicators([
              LineBarSpot(
                LineChartBarData(spots: []), // dummy
                0,
                lastSpot,
              )
            ]),
          ],
        ),
      ),
    );
  }
}

class _BMIEditProfilePageState extends State<BMIEditProfilePage> {
  List<String> selectedInjuries = [];
    Future<void> _saveSelectedInjuries(downloaddb) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('selectedInjuries', downloaddb);
  }

  Future<void> _loadSelectedInjuries() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedInjuries = prefs.getStringList('selectedInjuries') ?? [];
      print(selectedInjuries);
    });
  }
  late Map<String, dynamic> userData = {};
  double? bmi;
  String bmiCategory = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> weightEntries = [];
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Safely parse numeric fields that might be stored as String or num in Firestore
  double parseWeight(dynamic val) {
    if (val is num) return val.toDouble();
    if (val is String) return double.tryParse(val) ?? 0.0;
    return 0.0;
  }

  List<Map<String, dynamic>> _processWeightEntries(List<Map<String, dynamic>> entries) {
    final Map<String, Map<String, dynamic>> dateMap = {};
    for (var entry in entries) {
      final date = (entry['date'] as DateTime).toUtc().add(const Duration(hours: 8));
      final dateKey = DateTime(date.year, date.month, date.day);

      // Keep only the latest entry for each day
      if (!dateMap.containsKey(dateKey.toString()) ||
          entry['date'].isAfter(dateMap[dateKey.toString()]!['date'])) {
        dateMap[dateKey.toString()] = {
          'weight': parseWeight(entry['weight']),
          'date': dateKey,
        };
      }
    }
    return dateMap.values.toList();
  }

  Future<void> _loadUserData() async {
    if (user == null) return;
    DocumentSnapshot doc = await _firestore.collection("Users").doc(user!.email).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>;
      setState(() {
        userData = data;
        weightEntries = _processWeightEntries(
          List<Map<String, dynamic>>.from(data['weightHistory'] ?? []).map((entry) {
            return {
              'weight': parseWeight(entry['weight']),
              'date': (entry['date'] as Timestamp).toDate(),
            };
          }).toList(),
        );

        // If today's weight is missing, add it
        DateTime today = DateTime.now().toUtc().add(const Duration(hours: 8));
        today = DateTime(today.year, today.month, today.day);
        bool hasTodayEntry = weightEntries.any((entry) => entry['date'] == today);

        double currentWeight = parseWeight(data['weight'] ?? '0');
        if (!hasTodayEntry && currentWeight > 0) {
          weightEntries.add({
            'weight': currentWeight,
            'date': today,
          });
        }
        weightEntries.sort((a, b) => a['date'].compareTo(b['date']));

        _calculateBMI();
      });
    }
  }

  void _calculateBMI() {
    double weight = parseWeight(userData['weight'] ?? '0');
    double height = parseWeight(userData['height'] ?? '0');
    if (height > 0) {
      double heightM = height / 100;
      bmi = weight / (heightM * heightM);
      if (bmi! < 18.5) {
        bmiCategory = 'Underweight';
      } else if (bmi! < 25) {
        bmiCategory = 'Normal';
      } else if (bmi! < 30) {
        bmiCategory = 'Overweight';
      } else {
        bmiCategory = 'Obese';
      }
    }
  }

  Future<void> _updateField(String field, dynamic value) async {
    if (user == null) return;
    if (field == 'weight') {
      double newWeight = parseWeight(value);
      DateTime today = DateTime.now().toUtc().add(const Duration(hours: 8));
      today = DateTime(today.year, today.month, today.day);

      List<dynamic> weightHistory = List.from(userData['weightHistory'] ?? []);

      // Remove existing entries for today
      weightHistory.removeWhere((entry) {
        DateTime entryDate =
        (entry['date'] as Timestamp).toDate().toUtc().add(const Duration(hours: 8));
        entryDate = DateTime(entryDate.year, entryDate.month, entryDate.day);
        return entryDate == today;
      });

      // Add new entry
      weightHistory.add({
        'weight': newWeight,
        'date': Timestamp.fromDate(today),
      });

      await _firestore.collection("Users").doc(user!.email).update({
        'weight': newWeight,
        'weightHistory': weightHistory,
      });
    } else {
      await _firestore.collection("Users").doc(user!.email).update({field: value});
    }
    await _loadUserData();
  }

  Future<void> _logWeight() async {
    final TextEditingController weightController = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Log Your Weight'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    suffixText: '(kg)',
                    hintText: 'Enter weight in kg',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Date:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColor.supersolidPrimary,
                      ),
                      onPressed: () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (pickedDate != null) {
                          setState(() => selectedDate = pickedDate);
                        }
                      },
                      child: Text(
                        DateFormat('MMM dd, yyyy').format(selectedDate),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  if (weightController.text.isNotEmpty) {
                    final newWeight = parseWeight(weightController.text);
                    final normalizedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                    );

                    List<dynamic> weightHistory = List.from(userData['weightHistory'] ?? []);

                    // Remove existing entries for the selected date
                    weightHistory.removeWhere((entry) {
                      DateTime entryDate = (entry['date'] as Timestamp).toDate();
                      entryDate = DateTime(entryDate.year, entryDate.month, entryDate.day);
                      return entryDate == normalizedDate;
                    });

                    // Add new entry
                    weightHistory.add({
                      'weight': newWeight,
                      'date': Timestamp.fromDate(normalizedDate),
                    });

                    // If logging today's weight, also update the 'weight' field
                    DateTime nowLocal = DateTime.now();
                    if (normalizedDate.year == nowLocal.year &&
                        normalizedDate.month == nowLocal.month &&
                        normalizedDate.day == nowLocal.day) {
                      await _firestore.collection("Users").doc(user!.email).update({
                        'weight': newWeight,
                        'weightHistory': weightHistory,
                      });
                    } else {
                      await _firestore.collection("Users").doc(user!.email).update({
                        'weightHistory': weightHistory,
                      });
                    }

                    await _loadUserData();
                    Navigator.pop(context);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEditableField(String label, String value, VoidCallback onEdit) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        // Spread label-value on left, edit icon on right
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value.isEmpty ? 'N/A' : value,
                  style: const TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: AppColor.supersolidPrimary),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  void _showNumberEditDialog(String field) {
    TextEditingController controller =
    TextEditingController(text: userData[field]?.toString() ?? '');
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit ${field.capitalize()}'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            suffixText: field == 'height' ? 'cm' : 'kg',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _updateField(field, controller.text);
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showSelectionDialog(String field, List<String> options) {
    String? tempValue = userData[field];
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Text('Select ${field.capitalize()}'),
            content: SingleChildScrollView(
              child: Column(
                children: options.map((option) {
                  return RadioListTile<String>(
                    title: Text(option.capitalize()),
                    value: option,
                    groupValue: tempValue,
                    onChanged: (value) {
                      setState(() => tempValue = value);
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (tempValue != null) _updateField(field, tempValue);
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showInjurySelectionDialog() {
    List<String> currentInjuries = (userData['injuryArea']?.toString().split(', ') ?? [])
        .where((e) => e.isNotEmpty)
        .toList();
    Set<String> tempSelected = Set.from(currentInjuries);
    List<String> options = [
      "none of them",
      "chest",
      "back",
      "shoulders",
      "neck",
      "lower arms",
      "upper arms",
      "lower legs",
      "upper legs",
      "waist",
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Injuries'),
            content: SingleChildScrollView(
              child: Column(
                children: options.map((injury) {
                  return CheckboxListTile(
                    title: Text(injury.capitalize()),
                    value: tempSelected.contains(injury),
                    onChanged: (bool? value) {
                      setState(() {
                        if (injury == 'none of them') {
                          if (value!) tempSelected = {'none of them'};
                        } else {
                          tempSelected.remove('none of them');
                          if (value!) {
                            tempSelected.add(injury);
                          } else {
                            tempSelected.remove(injury);
                          }
                        }
                      });
                    },
                  );
                }).toList(),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  String injuryValue = tempSelected.join(', ');
                      if (tempSelected.contains('none of them'))
                        injuryValue = 'none of them';
                      _updateField('injuryArea', injuryValue);
                      _saveSelectedInjuries(tempSelected.toList());
                      print(injuryValue);
                      _loadSelectedInjuries();
                  Navigator.pop(context);
                },
                child: const Text('Save'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show a loader until data is loaded
    if (userData.isEmpty) {
      return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black87),
          title: const Text(
            'BMI and Other Settings',
            style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    // Calculate BMI
    double heightVal = parseWeight(userData['height'] ?? '0');
    double weightVal = parseWeight(userData['weight'] ?? '0');
    double? currentBmi;
    String category = '';
    if (heightVal > 0) {
      double hM = heightVal / 100;
      currentBmi = weightVal / (hM * hM);
      if (currentBmi < 18.5) {
        category = 'Underweight';
      } else if (currentBmi < 25) {
        category = 'Normal';
      } else if (currentBmi < 30) {
        category = 'Overweight';
      } else {
        category = 'Obese';
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black87),
        title: const Text(
          'BMI and Other Settings',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: const BackButton(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Column(
          children: [
            // Card for editing height, goal, activity, injuries, etc.
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Customize Your Profile",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildEditableField(
                      'Height',
                      '${userData['height'] ?? ''} cm',
                          () => _showNumberEditDialog('height'),
                    ),
                    _buildEditableField(
                      'Goal',
                      userData['goal']?.toString().capitalize() ?? '',
                          () => _showSelectionDialog(
                        'goal',
                        ['lose weight', 'muscle mass gain', 'maintain'],
                      ),
                    ),
                    _buildEditableField(
                      'Activity Level',
                      userData['nutriActivitylevel']?.toString().capitalize() ?? '',
                          () => _showSelectionDialog(
                        'nutriActivitylevel',
                        ['Inactive', 'Low Active', 'Active', 'Very Active'],
                      ),
                    ),
                    _buildEditableField(
                      'Workout Level',
                      userData['workoutLevel']?.toString().capitalize() ?? '',
                          () => _showSelectionDialog(
                        'workoutLevel',
                        ['beginner', 'intermediate', 'advanced'],
                      ),
                    ),
                    _buildEditableField(
                      'Injuries',
                      userData['injuryArea']?.toString().capitalize() ?? '',
                      _showInjurySelectionDialog,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Card for weight, BMI, and chart
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(
                      "Weight & BMI",
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _buildEditableField(
                      'Target Weight',
                      '${userData['targetWeight'] ?? ''} kg',
                          () => _showNumberEditDialog('targetWeight'),
                    ),
                    _buildEditableField(
                      'Weight',
                      '${userData['weight'] ?? ''} kg',
                          () => _showNumberEditDialog('weight'),
                    ),
                    if (currentBmi != null)
                      Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              'BMI: ${currentBmi.toStringAsFixed(1)} ($category)',
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          // Example color-coded BMI bar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 20,
                                height: 6,
                                color: Colors.blue, // Underweight
                              ),
                              Container(
                                width: 20,
                                height: 6,
                                color: Colors.green, // Normal
                              ),
                              Container(
                                width: 20,
                                height: 6,
                                color: Colors.orange, // Overweight
                              ),
                              Container(
                                width: 20,
                                height: 6,
                                color: Colors.red, // Obese
                              ),
                            ],
                          ),
                        ],
                      ),
                    const Divider(),
                    const SizedBox(height: 8),
                    const Text(
                      'Weight Chart',
                      style: TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 16),
                    WeightChart(
                      targetWeight: parseWeight(userData['targetWeight'] ?? '72.1'),
                      weightEntries: weightEntries,
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: 150,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.moresolidPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: _logWeight,
                        child: const Text(
                          'Log Weight',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}
