import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/show_firestore_exercises_download/show_with_reps_kcals/filter_reps_kcal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/show_firestore_exercises_download/proceed_to_exercise/reps_page.dart';

class ShowRepsKcal extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const ShowRepsKcal({Key? key, required this.exercise}) : super(key: key);

  @override
  _ShowRepsKcalState createState() => _ShowRepsKcalState();
}

class _ShowRepsKcalState extends State<ShowRepsKcal> {
  late Stream<DocumentSnapshot> _exerciseStream;
  late User _currentUser;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser!;
    _initializeExerciseStream();
  }

  void _initializeExerciseStream() {
    _exerciseStream = FirebaseFirestore.instance
        .collection('Users')
        .doc(_currentUser.email)
        .collection('UserExercises')
        .doc(widget.exercise['name'].toString())
        .snapshots();
  }

  String _formatDuration(int? totalSecs) {
    final safeSecs = totalSecs ?? 0;
    if (safeSecs >= 60) {
      int minutes = safeSecs ~/ 60;
      int seconds = safeSecs % 60;
      String result = "$minutes minute${minutes != 1 ? 's' : ''}";
      if (seconds > 0) result += " $seconds second${seconds != 1 ? 's' : ''}";
      return result;
    }
    return "$safeSecs second${safeSecs != 1 ? 's' : ''}";
  }

  TextStyle _headerStyle() =>
      const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          leading: IconButton(
            onPressed: () {
              setState(() {
                _initializeExerciseStream();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => FilterRepsKcal()),
                );
              });
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: Text(
            widget.exercise['name'] ?? 'Unnamed Exercise',
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        body: StreamBuilder<DocumentSnapshot>(
          stream: _exerciseStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red),
                ),
              );
            }

            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!snapshot.hasData || !snapshot.data!.exists) {
              return const Center(child: Text('Exercise data not found'));
            }

            final exercise = snapshot.data!.data() as Map<String, dynamic>;
            final baseSetsReps = exercise['baseSetsReps'] as int?;
            final baseReps = exercise['baseReps'] as int?;
            final baseSetsSecs = exercise['baseSetsSecs'] as int?;
            final baseSecs = exercise['baseSecs'] as int?;
            final baseRepsConcat = exercise['baseRepsConcat'] as List<dynamic>?;
            final baseSecConcat = exercise['baseSecConcat'] as List<dynamic>?;

            final isRepBased = baseSetsReps != null && baseReps != null;
            final isTimeBased = baseSetsSecs != null && baseSecs != null;
            final isSingleDuration = baseSecs != null && !isTimeBased;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image with elegant design and shadow
                  Center(
                    child: Container(
                      width: double.infinity,
                      height: 190,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.asset(
                          exercise['gifPath'] ?? 'assets/exercaiGif/fallback.gif',
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) =>
                          const Icon(Icons.error_outline, size: 100),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Header Section
                  Text(
                    'Exercise Details',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 10),
                  // Target Muscle Information
                  Text(
                    'Target Muscle: ${exercise['target'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[800],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Card for Sets/Reps or Timer Details
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey.shade300),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        if (isRepBased)
                          Column(
                            children: [
                              Text(
                                '${baseSetsReps ?? 0} Sets',
                                style: const TextStyle(fontSize: 18, color: AppColor.primary),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${baseReps ?? 0} Reps',
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primary),
                              ),
                              if (baseRepsConcat != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Reps per Set: ${baseRepsConcat.join(', ')}',
                                    style: const TextStyle(fontSize: 14, color: AppColor.primary),
                                  ),
                                ),
                            ],
                          ),
                        if (isTimeBased || isSingleDuration)
                          Column(
                            children: [
                              const Icon(Icons.timer, size: 30, color: AppColor.primary),
                              const SizedBox(height: 4),
                              if (isTimeBased)
                                Text(
                                  '${baseSetsSecs ?? 0} Sets',
                                  style: const TextStyle(fontSize: 18, color: AppColor.primary),
                                ),
                              const SizedBox(height: 4),
                              Text(
                                _formatDuration(baseSecs),
                                style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppColor.primary),
                              ),
                              if (baseSecConcat != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    'Seconds per Set: ${baseSecConcat.join(', ')}',
                                    style: const TextStyle(fontSize: 14, color: AppColor.primary),
                                  ),
                                ),
                            ],
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Estimated Burn Calories Section
                  Center(
                    child: Column(
                      children: [
                        Text(
                          'Estimated Burn Calories',
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          backgroundColor: AppColor.primary.withOpacity(0.1),
                          label: Text(
                                () {
                              final exerciseData = snapshot.data!.data() as Map<String, dynamic>;
                              final dynamicCalories = exerciseData['baseCalories'] ?? widget.exercise['baseCalories'];
                              return '${(dynamicCalories is num) ? dynamicCalories.toStringAsFixed(2) : 'N/A'} kcal';
                            }(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColor.primary,
                            ),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Instructions Section
                  Text(
                    "Instructions:",
                    style: _headerStyle(),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(
                    exercise['instructions']?.length ?? 0,
                        (index) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.arrow_right, color: AppColor.primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${exercise['instructions'][index]}",
                              style: const TextStyle(color: Colors.black87, fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Proceed to Exercise Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => RepsPage(exercise: exercise),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.moresolidPrimary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: const Text(
                      'Proceed to Exercise',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
