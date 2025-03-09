import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math';


class BMIEditProfilePage extends StatefulWidget {
  const BMIEditProfilePage({super.key});

  @override

  State<BMIEditProfilePage> createState() => _BMIEditProfilePageState();
}


class WeightChart extends StatelessWidget {
  final double targetWeight;
  final List<Map<String, dynamic>> weightEntries;

  const WeightChart({
    super.key,
    required this.targetWeight,
    required this.weightEntries,
  });

  double _calculateInterval(double range) {
    if (range <= 10) return 2;
    if (range <= 20) return 5;
    if (range <= 50) return 10;
    return 20;
  }

  @override

  Widget build(BuildContext context) {
    final sortedEntries = weightEntries..sort((a, b) => a['date'].compareTo(b['date']));
    final minDate = sortedEntries.isNotEmpty ? sortedEntries.first['date'] : DateTime.now();
    final maxDate = sortedEntries.isNotEmpty ? sortedEntries.last['date'] : DateTime.now();
    final maxXDate = maxDate.add(const Duration(days: 30));

    // Calculate Y-axis parameters
    List<double> allWeights = sortedEntries.map((e) => e['weight'] as double).toList();
    allWeights.add(targetWeight);
    double dataMinY = allWeights.reduce((a, b) => a < b ? a : b);
    double dataMaxY = allWeights.reduce((a, b) => a > b ? a : b);
    double range = dataMaxY - dataMinY;
    double padding = range == 0 ? 5 : max(range * 0.1, 5);
    double interval = _calculateInterval(dataMaxY - dataMinY + 2 * padding);

    double effectiveMinY = ((dataMinY - padding) / interval).floor() * interval;
    double effectiveMaxY = ((dataMaxY + padding) / interval).ceil() * interval;

    return SizedBox(
      height: 300,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Container(
          width: (maxXDate.millisecondsSinceEpoch - minDate.millisecondsSinceEpoch) / 86400000 * 100,
          child: LineChart(
            LineChartData(
              minX: minDate.millisecondsSinceEpoch.toDouble(),
              maxX: maxXDate.millisecondsSinceEpoch.toDouble(),
              minY: effectiveMinY,
              maxY: effectiveMaxY,
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final date = DateTime.fromMillisecondsSinceEpoch(value.toInt());
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(DateFormat('d').format(date),
                          style: TextStyle(
                            color: AppColor.textwhite,
                            fontSize: 12,
                          ),
                        ),
                      );
                    },
                    interval: 86400000 * 5,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: interval,
                    getTitlesWidget: (value, meta) {
                      if ((value - targetWeight).abs() < 0.1) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Text('Goal\n${value.toInt()}kg',
                            style: TextStyle(
                              color: Colors.green,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        );
                      }
                      return Text('${value.toInt()}kg',
                        style: TextStyle(
                          color: AppColor.textwhite,
                          fontSize: 12,
                        ),
                      );
                    },
                  ),
                ),
                rightTitles: const AxisTitles(),
                topTitles: const AxisTitles(),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey),
              ),
              lineTouchData: LineTouchData(
                getTouchedSpotIndicator: (barData, indexes) => indexes.map((index) {
                  return TouchedSpotIndicatorData(
                    const FlLine(color: Colors.transparent),
                    FlDotData(show: false),
                  );
                }).toList(),
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots.map((spot) {
                    final date = DateTime.fromMillisecondsSinceEpoch(spot.x.toInt());
                    return LineTooltipItem(
                      '${DateFormat('MMM dd').format(date)}\n${spot.y.toStringAsFixed(1)}kg',
                      const TextStyle(color: Colors.white),
                    );
                  }).toList(),
                ),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    FlSpot(minDate.millisecondsSinceEpoch.toDouble(), targetWeight),
                    FlSpot(maxXDate.millisecondsSinceEpoch.toDouble(), targetWeight),
                  ],
                  color: Colors.green,
                  dashArray: [5, 5],
                  dotData: const FlDotData(show: false),
                ),
                LineChartBarData(
                  spots: sortedEntries.map((entry) => FlSpot(
                    entry['date'].millisecondsSinceEpoch.toDouble(),
                    entry['weight'],
                  )).toList(),
                  color: AppColor.yellowtext,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                      radius: 4,
                      color: AppColor.yellowtext,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                  //isCurved: true,
                  isCurved: false,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BMIEditProfilePageState extends State<BMIEditProfilePage> {
  @override
  void initState() {
    super.initState();
    _loadUserData();
  }
  late Map<String, dynamic> userData = {};
  double? bmi;
  String bmiCategory = '';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final User? user = FirebaseAuth.instance.currentUser;
  List<Map<String, dynamic>> weightEntries = [];
  final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');



  List<Map<String, dynamic>> _processWeightEntries(List<Map<String, dynamic>> entries) {
    final Map<String, Map<String, dynamic>> dateMap = {};

    for (var entry in entries) {
      final date = (entry['date'] as DateTime).toUtc().add(const Duration(hours: 8));
      final dateKey = DateTime(date.year, date.month, date.day);

      // Keep only the latest entry for each day
      if (!dateMap.containsKey(dateKey.toString()) ||
          entry['date'].isAfter(dateMap[dateKey.toString()]!['date'])) {
        dateMap[dateKey.toString()] = {
          'weight': entry['weight'],
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
            List<Map<String, dynamic>>.from(data['weightHistory'] ?? [])
                .map((entry) => {
              'weight': (entry['weight'] as num).toDouble(),
              'date': (entry['date'] as Timestamp).toDate(),
            }).toList()
        );

        // Add current weight as today's entry if missing
        DateTime today = DateTime.now().toUtc().add(const Duration(hours: 8));
        today = DateTime(today.year, today.month, today.day);
        bool hasTodayEntry = weightEntries.any((entry) {
          DateTime entryDate = entry['date'];
          return entryDate == today;
        });

        if (!hasTodayEntry && data['weight'] != null) {
          weightEntries.add({
            'weight': (data['weight'] as num).toDouble(),
            'date': today,
          });
        }

        weightEntries.sort((a, b) => a['date'].compareTo(b['date']));
        _calculateBMI();
      });
    }
  }

  void _calculateBMI() {
    double weight = double.tryParse(userData['weight'] ?? '0') ?? 0;
    double height = double.tryParse(userData['height'] ?? '0') ?? 0;
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
      double newWeight = double.tryParse(value) ?? 0;
      DateTime today = DateTime.now().toUtc().add(const Duration(hours: 8));
      today = DateTime(today.year, today.month, today.day);

      List<dynamic> weightHistory = List.from(userData['weightHistory'] ?? []);

      // Remove existing entries for today
      weightHistory.removeWhere((entry) {
        DateTime entryDate = (entry['date'] as Timestamp).toDate().toUtc().add(const Duration(hours: 8));
        entryDate = DateTime(entryDate.year, entryDate.month, entryDate.day);
        return entryDate == today;
      });

      // Add new entry
      weightHistory.add({
        'weight': newWeight,
        'date': Timestamp.fromDate(today),
      });

      await _firestore.collection("Users").doc(user!.email).update({
        'weight': newWeight.toString(),
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
            title: const Text('Log Weight'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: weightController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    suffixText: 'kg',
                    hintText: 'Enter weight',
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Date:', style: TextStyle(fontSize: 16)),
                    const SizedBox(width: 10),
                    TextButton(
                      style: TextButton.styleFrom(
                        backgroundColor: AppColor.yellowtext,
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
                        style: const TextStyle(color: Colors.black),
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
                    final newWeight = double.parse(weightController.text);
                    final normalizedDate = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                    );

                    List<dynamic> weightHistory = List.from(userData['weightHistory'] ?? []);

                    // Remove existing entries for the selected date
                    weightHistory.removeWhere((entry) {
                      DateTime entryDate = (entry['date'] as Timestamp).toDate();
                      entryDate = DateTime(
                        entryDate.year,
                        entryDate.month,
                        entryDate.day,
                      );
                      return entryDate == normalizedDate;
                    });

                    // Add new entry
                    weightHistory.add({
                      'weight': newWeight,
                      'date': Timestamp.fromDate(normalizedDate),
                    });

                    // Update current weight if it's today
                    if (normalizedDate == DateTime(
                      DateTime.now().year,
                      DateTime.now().month,
                      DateTime.now().day,
                    )) {
                      await _firestore.collection("Users").doc(user!.email).update({
                        'weight': newWeight.toString(),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(color: AppColor.textwhite, fontSize: 18)),
                Text(value, style: TextStyle(color: Colors.grey, fontSize: 16)),
              ],
            ),
          ),
          IconButton(
            icon: Icon(Icons.edit, color: AppColor.yellowtext),
            onPressed: onEdit,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundgrey,
      appBar: AppBar(
        title: const Text(
          'BMI and Other Settings',
          style: TextStyle(color: AppColor.primary),
        ),
        backgroundColor: Colors.transparent,
        leading: BackButton(
          color: AppColor.primary, // Change color if needed
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text("Editable Fields for Customization",style: TextStyle(color: Colors.white,fontSize: 25,fontWeight: FontWeight.bold),),
            SizedBox(height: 20),
            _buildEditableField('Height', '${userData['height'] ?? ''} cm', () => _showNumberEditDialog('height')),
            _buildEditableField('Goal', userData['goal']?.toString().capitalize() ?? '', () => _showSelectionDialog('goal', ['lose weight', 'muscle mass gain', 'maintain'])),
            _buildEditableField('Activity Level', userData['nutriActivitylevel']?.toString().capitalize() ?? '', () => _showSelectionDialog('nutriActivitylevel', ['Inactive', 'Low Active', 'Active', 'Very Active'])),
            _buildEditableField('Workout Level', userData['workoutLevel']?.toString().capitalize() ?? '', () => _showSelectionDialog('workoutLevel', ['beginner', 'intermediate', 'advanced'])),
            _buildEditableField('Injuries', userData['injuryArea']?.toString().capitalize() ?? '', _showInjurySelectionDialog),

            const Divider(color: Colors.grey),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Column(
                children: [

                  Column(
                    children: [
                      _buildEditableField('Target Weight', '${userData['targetWeight'] ?? ''} kg', () => _showNumberEditDialog('targetWeight')),

                      _buildEditableField('Weight', '${userData['weight'] ?? ''} kg', () => _showNumberEditDialog('weight')),
                      if (bmi != null) Text('BMI: ${bmi!.toStringAsFixed(1)} ($bmiCategory)',
                          style: TextStyle(color: Colors.white, fontSize: 18)),

                      const Divider(color: Colors.grey),
                    ],
                  ),
                  const Text('Weight Chart',
                    style: TextStyle(
                      color: AppColor.textwhite,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  WeightChart(
                    targetWeight: double.tryParse(userData['targetWeight'] ?? '72.1') ?? 72.1,
                    weightEntries: weightEntries,
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.yellowtext,
                    ),
                    onPressed: _logWeight,
                    child: const Text('Log Today\'s Weight',
                        style: TextStyle(color: Colors.black)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNumberEditDialog(String field) {
    TextEditingController controller = TextEditingController(text: userData[field]?.toString() ?? '');
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
                children: options.map((option) => RadioListTile<String>(
                  title: Text(option.capitalize()),
                  value: option,
                  groupValue: tempValue,
                  onChanged: (value) {
                    setState(() => tempValue = value);
                  },
                )).toList(),
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
    List<String> currentInjuries = (userData['injuryArea']?.toString().split(', ') ?? []).where((e) => e.isNotEmpty).toList();
    Set<String> tempSelected = Set.from(currentInjuries);
    List<String> options = [
      "none of them", "chest", "back", "shoulders", "neck",
      "lower arms", "upper arms", "lower legs", "upper legs", "waist"
    ];

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Select Injuries'),
            content: SingleChildScrollView(
              child: Column(
                children: options.map((injury) => CheckboxListTile(
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
                )).toList(),
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
                  if (tempSelected.contains('none of them')) injuryValue = 'none of them';
                  _updateField('injuryArea', injuryValue);
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
}

extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}