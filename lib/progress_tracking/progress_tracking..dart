import 'package:exercai_mobile/different_exercises/bodypart_exercises/info_exercises/info_card_diffExercises.dart';
import 'package:exercai_mobile/progress_tracking/info_card_exeRecommend.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../utils/constant.dart';

class ProgressTrackingScreen extends StatefulWidget {
  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    computeAndStoreTotalCalories();
  }

  // Fetch user details from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get(const GetOptions(source: Source.server));
  }

  String computeAge(Timestamp? dob) {
    if (dob == null) return "N/A"; // Handle missing DOB

    DateTime birthDate = dob.toDate();
    DateTime today = DateTime.now();

    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }

    return age.toString();
  }

  // Format total exercise time in HH:MM:SS format
  String _formatTotalTime(int totalSeconds) {
    int hours = totalSeconds ~/ 3600;
    int minutes = (totalSeconds % 3600) ~/ 60;
    int seconds = totalSeconds % 60;

    return "$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  // Format date and time from Firestore Timestamp
  String _formatDateTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    return DateFormat('MMM dd, yyyy - hh:mm a').format(dateTime);
  }

  Future<void> computeAndStoreTotalCalories() async {
    if (currentUser == null) return;

    final userExercisesRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.email)
        .collection('UserExercises');

    final totalCaloriesRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.email)
        .collection('TotalCaloriesExercises')
        .doc('TotalCaloriesBurnofUser');

    try {
      // Fetch all exercises
      QuerySnapshot exercisesSnapshot = await userExercisesRef.get(
        const GetOptions(source: Source.server),
      );
      double totalCaloriesBurned = 0;

      for (var doc in exercisesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        double finalTotalBurnCalRep =
            (data['FinalTotalBurnCalRep'] ?? 0).toDouble();
        double totalCalBurnSec = (data['TotalCalBurnSec'] ?? 0).toDouble();

        totalCaloriesBurned += (finalTotalBurnCalRep + totalCalBurnSec);
      }

      // Fetch the existing data
      DocumentSnapshot totalCaloriesDoc = await totalCaloriesRef.get(
        const GetOptions(source: Source.server),
      );
      List<double> totalCaloriesBurnedArray = [];
      double existingFinalTotalCaloriesBurned = 0;

      if (totalCaloriesDoc.exists) {
        final data = totalCaloriesDoc.data() as Map<String, dynamic>;

        if (data.containsKey('TotalCaloriesBurned') &&
            data['TotalCaloriesBurned'] is List) {
          totalCaloriesBurnedArray = List<double>.from(
            (data['TotalCaloriesBurned'] as List).map(
              (e) => (e is num ? e.toDouble() : 0),
            ),
          );
        }

        existingFinalTotalCaloriesBurned =
            (data['FinalTotalCaloriesBurned'] ?? 0).toDouble();
      }

      // Append new totalCaloriesBurned to the array
      totalCaloriesBurnedArray.add(totalCaloriesBurned);

      // Compute the change based on the last two values
      double change = 0;
      if (totalCaloriesBurnedArray.length > 1) {
        double previousValue =
            totalCaloriesBurnedArray[totalCaloriesBurnedArray.length - 2];
        double newValue = totalCaloriesBurnedArray.last;

        if (newValue >= previousValue ||
            (newValue == 0 && previousValue == 0)) {
          change = newValue - previousValue;
        }
      } else {
        // First index case, subtract from 0
        change = totalCaloriesBurnedArray.first;
      }

      // Update FinalTotalCaloriesBurned
      double newFinalTotalCaloriesBurned =
          existingFinalTotalCaloriesBurned + change;

      // Store the updated values in Firestore
      await totalCaloriesRef.set({
        'TotalCaloriesBurned': totalCaloriesBurnedArray, // Store as an array
        'FinalTotalCaloriesBurned': newFinalTotalCaloriesBurned,
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Total Calories Burned updated: $totalCaloriesBurnedArray');
      print(
        'Final Total Calories Burned updated: $newFinalTotalCaloriesBurned',
      );
    } catch (e) {
      print('Error computing total calories: $e');
    }
  }

  Future<int> computeTotalExerciseTimeForAllDays() async {
    if (currentUser == null) return 0;

    final userMetadataRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(currentUser!.email)
        .collection('UserExercises')
        .doc('--metadata--');

    try {
      DocumentSnapshot metadataSnapshot = await userMetadataRef.get(
        const GetOptions(source: Source.server),
      );
      List<dynamic> currentDays =
          metadataSnapshot.exists
              ? (metadataSnapshot.data()
                      as Map<String, dynamic>)['currentDay'] ??
                  []
              : [];

      print('Current Days: $currentDays'); // Debug current days

      int totalExerciseTimeAll = 0;

      for (var day in currentDays) {
        print('Processing Day $day'); // Debug each day

        QuerySnapshot timesSnapshot = await FirebaseFirestore.instance
            .collection('Users')
            .doc(currentUser!.email)
            .collection('UserExerciseTimes')
            .doc('Day$day')
            .collection('times')
            .get(const GetOptions(source: Source.server));

        print(
          'Found ${timesSnapshot.docs.length} time docs for Day $day',
        ); // Debug doc count

        for (var timeDoc in timesSnapshot.docs) {
          int time = (timeDoc['totalExerciseTime'] ?? 0) as int;
          totalExerciseTimeAll += time;
          print(
            'Added $time seconds from doc ${timeDoc.id}',
          ); // Debug each doc's time
        }
      }

      print(
        'Total Exercise Time: $totalExerciseTimeAll seconds',
      ); // Debug total time
      return totalExerciseTimeAll;
    } catch (e) {
      print('Error computing total exercise time: $e');
      return 0;
    }
  }

  Future<int> _calculateTotalExerciseTime(
    List<QueryDocumentSnapshot> exerciseDocs,
  ) async {
    int totalExerciseTime = 0;

    for (var exerciseDoc in exerciseDocs) {
      final data = exerciseDoc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('totalExerciseTime')) {
        totalExerciseTime += (data['totalExerciseTime'] as int? ?? 0);
      }
    }

    return totalExerciseTime;
  }

  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  // Helper widget to create modern info cards
  Widget _buildInfoCard({
    required String title,
    required Widget content,
    GestureTapCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        elevation: 4,
        margin: EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: AppColor.supersolidPrimary,
                size: 30,
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    content,
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper widget for profile info columns (Age, Weight, Height)
  Widget _buildProfileInfo(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColor.backgroundWhite,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(color: AppColor.backgroundgrey, fontSize: 14),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // White background for a clean look
      appBar: AppBar(
        backgroundColor: AppColor.primary,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(onPressed: (){
          Navigator.pop(context);
        }, icon: Icon(Icons.arrow_back_ios,color: AppColor.backgroundWhite,)),
        title: const Text(
          'Progress Tracking',
          style: TextStyle(
            color: AppColor.backgroundWhite,
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                "Error: ${snapshot.error}",
                style: TextStyle(color: Colors.red),
              ),
            );
          }

          if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            print("User data: $user");

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //SizedBox(height: 20),
                  // User Profile Card
                  Container(
                    decoration: BoxDecoration(
                      color: AppColor.primary,
                      
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                      
                    ),
                    //margin: EdgeInsets.symmetric(horizontal: 16),
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    '${_capitalize(user?['firstname'] ?? 'Unknown')} ${_capitalize(user?['lastname'] ?? 'User')}',
                                    style: TextStyle(
                                      color: AppColor.backgroundWhite,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  user?['gender'] == 'Male'
                                      ? Icon(
                                        Icons.male,
                                        color: Colors.blue,
                                        size: 20,
                                      )
                                      : Icon(
                                        Icons.female,
                                        color: Colors.pink,
                                        size: 20,
                                      ),
                                ],
                              ),
                              SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  _buildProfileInfo(
                                    "Age",
                                    user?['dateOfBirth'] != null
                                        ? computeAge(user!['dateOfBirth'])
                                        : 'N/A',
                                  ),
                                  SizedBox(width: 16),
                                  _buildProfileInfo(
                                    "Weight",
                                    '${user?['weight'] ?? 'N/A'} Kg',
                                  ),
                                  SizedBox(width: 16),
                                  _buildProfileInfo(
                                    "Height",
                                    '${user?['height'] ?? 'N/A'} CM',
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Section Title: Workout Log
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Workout Log',
                          style: TextStyle(
                            color: AppColor.backgroundgrey,
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '( Click card for more information. )',
                          style: TextStyle(color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Total Calories Burn Card
                  _buildInfoCard(
                    title: 'Recommended Exercise Calories Burn',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => InfoCardExerecommend(),
                          ),
                        ),
                    content: StreamBuilder<DocumentSnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('Users')
                              .doc(currentUser!.email)
                              .collection('TotalCaloriesExercises')
                              .doc('TotalCaloriesBurnofUser')
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                            'Error',
                            style: TextStyle(color: Colors.red),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        final data =
                            snapshot.data?.data() as Map<String, dynamic>?;

                        List<double> totalCaloriesBurnedArray = [];
                        if (data != null &&
                            data.containsKey('TotalCaloriesBurned') &&
                            data['TotalCaloriesBurned'] is List) {
                          totalCaloriesBurnedArray = List<double>.from(
                            (data['TotalCaloriesBurned'] as List).map(
                              (e) => (e is num ? e.toDouble() : 0),
                            ),
                          );
                        }

                        double finalTotalCalories =
                            (data?['FinalTotalCaloriesBurned'] ?? 0).toDouble();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Total Burned Calories: ${finalTotalCalories.toStringAsFixed(2)} Kcal',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Burned Calories Today: ${totalCaloriesBurnedArray.isNotEmpty ? totalCaloriesBurnedArray.last.toStringAsFixed(2) : "0"} Kcal',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Different Exercises Burn Calories Card
                  _buildInfoCard(
                    title: 'Different Exercises Burn Calories',
                    onTap:
                        () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DiffExeCard(),
                          ),
                        ),
                    content: StreamBuilder<QuerySnapshot>(
                      stream:
                          FirebaseFirestore.instance
                              .collection('Users')
                              .doc(currentUser!.email)
                              .collection('AllExercises')
                              .snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) {
                          return Text(
                            'Error: ${snapshot.error}',
                            style: TextStyle(color: Colors.black87),
                          );
                        }
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        }

                        double totalRepCalories = 0.0;
                        double totalTimeCalories = 0.0;

                        for (var doc in snapshot.data!.docs) {
                          final data = doc.data() as Map<String, dynamic>;
                          final bool isRepBased =
                              data['baseSetsReps'] != null &&
                              data['baseReps'] != null;
                          final bool isTimeBased =
                              data['baseSetsSecs'] != null ||
                              data['baseSecs'] != null;

                          if (isRepBased) {
                            totalRepCalories +=
                                (data['FinalTotalBurnCalRep'] ?? 0).toDouble();
                          } else if (isTimeBased) {
                            totalTimeCalories +=
                                (data['TotalCalBurnSec'] ?? 0).toDouble();
                          }
                        }

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Repetition Based Exercise: ${totalRepCalories.toStringAsFixed(2)} Kcal',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Time Based Exercise: ${totalTimeCalories.toStringAsFixed(2)} Kcal',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                            Text(
                              'Total: ${(totalRepCalories + totalTimeCalories).toStringAsFixed(2)} Kcal',
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  // Pose Estimation Burn Calories Card
                  _buildInfoCard(
                    title: 'Pose Estimation Burn Calories',
                    content: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '100 days exercise calories burn: ${(peopleBox.get("daychallenge", defaultValue: 0)).toStringAsFixed(2)} Kcal',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Arcade calories burn: ${(peopleBox.get("arcadecoloriesburn", defaultValue: 0)).toStringAsFixed(2)} Kcal',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Pose Correction: ${(peopleBox.get("posecorrectionburn", defaultValue: 0)).toStringAsFixed(2)} Kcal',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Total: ${(peopleBox.get("finalcoloriesburn", defaultValue: 0)).toStringAsFixed(2)} Kcal',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          }

          return Center(child: Text("No user data found."));
        },
      ),
    );
  }
}
