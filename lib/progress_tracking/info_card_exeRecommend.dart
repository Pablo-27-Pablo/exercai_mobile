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
  Future<int> _calculateTotalExerciseTime(List<QueryDocumentSnapshot> docs) async {
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

  // Helper widget for section headers.
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16),
      child: Text(
        title,
        style: TextStyle(
          color: AppColor.primary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Helper widget for metric cards.
  Widget _buildMetricCard({required Widget child}) {
    return Card(
      elevation: 8,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          gradient: LinearGradient(
            colors: [AppColor.buttonPrimary, AppColor.primary.withOpacity(0.85)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text("Exercise Summary",style: TextStyle(color: AppColor.backgroundWhite),),
          backgroundColor: AppColor.primary,
          leading: IconButton(onPressed: (){
            Navigator.pop(context);
          }, icon: Icon(Icons.arrow_back_ios)),
        ),
        body: const Center(child: Text("User not logged in.")),
      );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text("Exercise Summary",style: TextStyle(color: AppColor.backgroundWhite),),
        backgroundColor: AppColor.primary,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: AppColor.backgroundWhite,)),
      ),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Today's Exercise Time Section ---
            _buildSectionHeader("Today's Exercise Time (HH:MM:SS)"),
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
                    if (totalTimeSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    int totalExerciseTime = totalTimeSnapshot.data ?? 0;
                    return _buildMetricCard(
                      child: Row(
                        children: [
                          Icon(Icons.timer, color: Colors.white, size: 30),
                          const SizedBox(width: 16),

                          //Today\'s Total Time:
                          Text(
                            ' ${_formatTotalTime(totalExerciseTime)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            // --- Recent Exercise Time Section ---
            _buildSectionHeader("Recent Exercise Time (HH:MM:SS)"),
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
                return FutureBuilder<int>(
                  future: computeTotalExerciseTimeForAllDays(),
                  builder: (context, totalSnapshot) {
                    if (totalSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    int recentTotalTime = totalSnapshot.data ?? 0;
                    return _buildMetricCard(
                      child: Row(
                        children: [
                          Icon(Icons.timer, color: Colors.white, size: 30),
                          const SizedBox(width: 16),
                          // Recent Exercise Total TIme
                          Text(
                            '${_formatTotalTime(recentTotalTime)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            // --- Activities Today Section ---
            _buildSectionHeader("Activities Today"),
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
                    final String exerciseName = data['exerciseName'] ?? 'Unknown Exercise';
                    final int totalTime = data['totalExerciseTime'] ?? 0;
                    final Timestamp? lastUpdated = data['lastUpdated'] as Timestamp?;
                    final String formattedDate = _formatDate(lastUpdated);
                    final double burnCalories = (data['burnCalories'] ?? 0).toDouble();
                    return ActivityCard(
                      title: exerciseName,
                      duration: _formatTotalTime(totalTime),
                      timeanddate: 'Date: $formattedDate',
                      burnCalories: burnCalories,
                    );
                  }).toList(),
                );
              },
            ),
            // --- Recent Activities Today Section ---
            _buildSectionHeader("Recent Activities Today"),
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
                        final String exerciseName = data['exerciseName'] ?? 'Unknown Exercise';
                        final int totalTime = data['totalExerciseTime'] ?? 0;
                        final Timestamp? lastUpdated = data['lastUpdated'] as Timestamp?;
                        final String formattedDate = _formatDate(lastUpdated);
                        final double burnCalories = (data['burnCalories'] ?? 0).toDouble();
                        return ActivityCard(
                          title: exerciseName,
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
