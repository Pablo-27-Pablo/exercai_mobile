import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:exercai_mobile/utils/constant.dart';
import 'package:exercai_mobile/progress_tracking/activity_card_widget.dart';

class DiffExeCard extends StatefulWidget {
  const DiffExeCard({super.key});

  @override
  State<DiffExeCard> createState() => _DiffExeCardState();
}

class _DiffExeCardState extends State<DiffExeCard> {
  // Helper method to format seconds as HH:MM:SS
  String _formatTotalTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  @override
  Widget build(BuildContext context) {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Different Exercises Time"),
          backgroundColor: AppColor.primary,
        ),
        body: const Center(child: Text("User not logged in")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Different Exercises Time"),
        backgroundColor: AppColor.primary,
      ),
      backgroundColor: AppColor.backgroundgrey,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Different Exercises Time (Hours:Min:Sec)",
              style: TextStyle(
                color: AppColor.yellowtext,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            // StreamBuilder to listen for realtime updates
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(currentUser.email)
                  .collection('AllExercisesTime')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text(
                        'Error: ${snapshot.error}',
                        style: const TextStyle(color: Colors.red),
                      ));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                int totalTime = 0;
                for (var doc in snapshot.data!.docs) {
                  final data = doc.data() as Map<String, dynamic>;
                  final value = data['totalExerciseTime'];
                  totalTime += value is num ? value.toInt() : int.tryParse(value.toString()) ?? 0;
                }

                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColor.buttonPrimary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.timer, color: AppColor.primary, size: 30),
                      const SizedBox(width: 16),
                      Text(
                        'Total Time: ${_formatTotalTime(totalTime)}',
                        style: TextStyle(
                          color: AppColor.textwhite,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            const SizedBox(height: 24),
            // Section 2: List of activities (each exercise entry)
            Text(
              'Activities Performed',
              style: TextStyle(
                color: AppColor.yellowtext,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(currentUser.email)
                  .collection('AllExercisesTime')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Error: ${snapshot.error}'),
                  );
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final exerciseDocs = snapshot.data!.docs;

                return Column(
                  children: exerciseDocs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>?;
                    if (data == null) return const SizedBox();

                    final String exerciseName =
                        data['exerciseName'] ?? 'Unknown Exercise';
                    final int totalTime = data['totalExerciseTime'] ?? 0;
                    final Timestamp? lastUpdated = data['lastUpdated'] as Timestamp?;
                    final String formattedDate = lastUpdated != null
                        ? DateFormat('MMM dd, yyyy - hh:mm a')
                        .format(lastUpdated.toDate())
                        : 'N/A';
                    final double burnCalories =
                    (data['burnCalories'] ?? 0).toDouble();

                    return ActivityCard(
                      title: exerciseName,
                      //exeID: 'Date: $formattedDate',
                      duration: _formatTotalTime(totalTime),
                      timeanddate: 'Date: $formattedDate',
                      burnCalories: burnCalories,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}


