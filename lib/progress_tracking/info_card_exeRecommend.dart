import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:exercai_mobile/main.dart';
import 'activity_card_widget.dart';

class InfoCardExerecommend extends StatefulWidget {
  const InfoCardExerecommend({Key? key}) : super(key: key);

  @override
  State<InfoCardExerecommend> createState() => _InfoCardExerecommendState();
}

class _InfoCardExerecommendState extends State<InfoCardExerecommend> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  // Helper method to format seconds as HH:MM:SS.
  String _formatTotalTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;
    return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  // Calculate total exercise time from a list of documents.
  Future<int> _calculateTotalExerciseTime(
      List<QueryDocumentSnapshot> docs,
      ) async {
    int totalExerciseTime = 0;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey('totalExerciseTime')) {
        totalExerciseTime += (data['totalExerciseTime'] as int? ?? 0);
      }
    }
    return totalExerciseTime;
  }

  // Compute total exercise time for all days from metadata.
  Future<int> computeTotalExerciseTimeForAllDays() async {
    if (currentUser == null) return 0;
    final metadataRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.email)
        .collection('UserExercises')
        .doc('--metadata--');

    try {
      DocumentSnapshot metadataSnapshot = await metadataRef.get();
      List<dynamic> currentDays = metadataSnapshot.exists
          ? (metadataSnapshot.data() as Map<String, dynamic>)['currentDay'] ?? []
          : [];
      int totalExerciseTimeAll = 0;
      for (var day in currentDays) {
        QuerySnapshot timesSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.email)
            .collection('UserExerciseTimes')
            .doc('Day$day')
            .collection('times')
            .get();
        for (var timeDoc in timesSnapshot.docs) {
          int time = (timeDoc['totalExerciseTime'] ?? 0) as int;
          totalExerciseTimeAll += time;
        }
      }
      return totalExerciseTimeAll;
    } catch (e) {
      print('Error computing total exercise time for all days: $e');
      return 0;
    }
  }

  // Format timestamp into a readable string.
  String _formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('MMM dd, yyyy - hh:mm a').format(timestamp.toDate());
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Exercise Summary"),
          backgroundColor: AppColor.primary,
        ),
        body: const Center(child: Text("User not logged in.")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exercise Summary"),
        backgroundColor: AppColor.primary,
      ),
      backgroundColor: AppColor.backgroundgrey,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Today's Exercise Time Section ---
            Text(
              "Today's Exercise Time (Hours:Min:Sec)",
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
                  .doc(currentUser!.email)
                  .collection('UserExerciseTimes')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return FutureBuilder<int>(
                  future: _calculateTotalExerciseTime(snapshot.data!.docs),
                  builder: (context, totalTimeSnapshot) {
                    if (totalTimeSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    int totalExerciseTime = totalTimeSnapshot.data ?? 0;
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
                            'Total Time: ${_formatTotalTime(totalExerciseTime)}',
                            style: TextStyle(
                              color: AppColor.textwhite,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            // --- Recent Exercise Time Section ---
            Text(
              "Recent Exercise Time (Hours:Min:Sec)",
              style: TextStyle(
                color: AppColor.yellowtext,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(currentUser!.email)
                  .collection('UserExercises')
                  .doc('--metadata--')
                  .snapshots(),
              builder: (context, metadataSnapshot) {
                if (metadataSnapshot.hasError) {
                  return Center(
                      child: Text('Error: ${metadataSnapshot.error}'));
                }
                if (metadataSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                return FutureBuilder<int>(
                  future: computeTotalExerciseTimeForAllDays(),
                  builder: (context, totalSnapshot) {
                    if (totalSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    int recentTotalTime = totalSnapshot.data ?? 0;
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
                            'Total Time: ${_formatTotalTime(recentTotalTime)}',
                            style: TextStyle(
                              color: AppColor.textwhite,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 24),
            // --- Activities Today Section ---
            Text(
              'Activities Today',
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
                  .doc(currentUser!.email)
                  .collection('UserExerciseTimes')
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                      child: Text('Error: ${snapshot.error}',
                          style: const TextStyle(color: Colors.red)));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final exerciseTimes = snapshot.data!.docs;
                return Column(
                  children: exerciseTimes.map((doc) {
                    final data = doc.data() as Map<String, dynamic>?;
                    if (data == null) return const SizedBox();
                    final String exerciseName =
                        data['exerciseName'] ?? 'Unknown Exercise';
                    final int totalTime = data['totalExerciseTime'] ?? 0;
                    final Timestamp? lastUpdated = data['lastUpdated'] as Timestamp?;
                    final String formattedDate = _formatDate(lastUpdated);
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
            const SizedBox(height: 24),
            // --- Recent Activities Today Section ---
            Text(
              'Recent Activities Today',
              style: TextStyle(
                color: AppColor.yellowtext,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            StreamBuilder<DocumentSnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('Users')
                  .doc(currentUser!.email)
                  .collection('UserExercises')
                  .doc('--metadata--')
                  .snapshots(),
              builder: (context, metadataSnapshot) {
                if (metadataSnapshot.hasError) {
                  return Center(child: Text('Error: ${metadataSnapshot.error}'));
                }
                if (metadataSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = metadataSnapshot.data?.data() as Map<String, dynamic>?;
                final List<dynamic> days = data?['currentDay'] ?? [];
                if (days.isEmpty) return const SizedBox();
                return StreamBuilder<List<QuerySnapshot>>(
                  stream: Stream.fromFuture(
                    Future.wait(
                      days.map(
                            (day) => FirebaseFirestore.instance
                            .collection('Users')
                            .doc(currentUser!.email)
                            .collection('UserExerciseTimes')
                            .doc('Day$day')
                            .collection('times')
                            .get(),
                      ),
                    ),
                  ),
                  builder: (context, timesSnapshot) {
                    if (timesSnapshot.hasError) {
                      return Center(child: Text('Error: ${timesSnapshot.error}'));
                    }
                    if (timesSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    // Flatten the list of query snapshots into a single list of documents.
                    List<QueryDocumentSnapshot> recentDocs = timesSnapshot.data!
                        .expand((querySnapshot) => querySnapshot.docs)
                        .toList();
                    if (recentDocs.isEmpty) {
                      return const Center(child: Text('No recent activities available.'));
                    }
                    // Sort by lastUpdated descending.
                    recentDocs.sort((a, b) {
                      Timestamp timeA = a['lastUpdated'] ?? Timestamp(0, 0);
                      Timestamp timeB = b['lastUpdated'] ?? Timestamp(0, 0);
                      return timeB.compareTo(timeA);
                    });
                    return Column(
                      children: recentDocs.map((doc) {
                        final data = doc.data() as Map<String, dynamic>;
                        final String exerciseName =
                            data['exerciseName'] ?? 'Unknown Exercise';
                        final int totalTime = data['totalExerciseTime'] ?? 0;
                        final Timestamp? lastUpdated = data['lastUpdated'] as Timestamp?;
                        final String formattedDate = _formatDate(lastUpdated);
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
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// A reusable widget to display an activity card.
