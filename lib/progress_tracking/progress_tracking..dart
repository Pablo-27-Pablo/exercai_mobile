import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

class ProgressTrackingScreen extends StatefulWidget {
  @override
  State<ProgressTrackingScreen> createState() => _ProgressTrackingScreenState();
}

class _ProgressTrackingScreenState extends State<ProgressTrackingScreen> {
  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    computeAndStoreTotalCalories(); // Recalculate total calories on startup
  }

  // Fetch user details from Firestore
  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
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
      QuerySnapshot exercisesSnapshot = await userExercisesRef.get();

      double totalCaloriesBurned = 0;

      // Calculate total calories burned from exercises
      for (var doc in exercisesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        double finalTotalBurnCalRep = (data['FinalTotalBurnCalRep'] ?? 0).toDouble();
        double totalCalBurnSec = (data['TotalCalBurnSec'] ?? 0).toDouble();

        totalCaloriesBurned += (finalTotalBurnCalRep + totalCalBurnSec);
      }

      // Fetch the existing FinalTotalCaloriesBurned
      DocumentSnapshot totalCaloriesDoc = await totalCaloriesRef.get();
      double existingFinalTotalCaloriesBurned = 0;

      if (totalCaloriesDoc.exists) {
        existingFinalTotalCaloriesBurned =
            (totalCaloriesDoc.data() as Map<String, dynamic>)['FinalTotalCaloriesBurned'] ?? 0;
      }

      // Calculate the new FinalTotalCaloriesBurned
      double newFinalTotalCaloriesBurned = existingFinalTotalCaloriesBurned + totalCaloriesBurned;

      // Store the updated values in Firestore
      await totalCaloriesRef.set({
        'TotalCaloriesBurned': totalCaloriesBurned, // Current session's calories
        'FinalTotalCaloriesBurned': newFinalTotalCaloriesBurned, // Cumulative total
        'lastUpdated': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Total Calories Burned updated: $totalCaloriesBurned');
      print('Final Total Calories Burned updated: $newFinalTotalCaloriesBurned');
    } catch (e) {
      print('Error computing total calories: $e');
    }
  }

  // Add this helper function
  /*Future<int> _calculateTotalExerciseTime(List<QueryDocumentSnapshot> dayDocs) async {
    int totalExerciseTime = 0;

    for (var dayDoc in dayDocs) {
      final timesSnapshot = await dayDoc.reference.collection('times').get();
      for (var timeDoc in timesSnapshot.docs) {
        totalExerciseTime += (timeDoc['totalExerciseTime'] as int? ?? 0);
      }
    }

    return totalExerciseTime;
  }*/

  Future<int> _calculateTotalExerciseTime(List<QueryDocumentSnapshot> exerciseDocs) async {
    int totalExerciseTime = 0;

    for (var exerciseDoc in exerciseDocs) {
      final data = exerciseDoc.data() as Map<String, dynamic>?;

      if (data != null && data.containsKey('totalExerciseTime')) {
        totalExerciseTime += (data['totalExerciseTime'] as int? ?? 0);
      }
    }

    return totalExerciseTime;
  }





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundgrey,
      appBar: AppBar(
        title: const Text(
          'Progress Tracking',
          style: TextStyle(color: AppColor.primary,fontSize: 25),
        ),
        backgroundColor: Colors.transparent,
        leading: BackButton(
          color: AppColor.primary, // Change color if needed
        ),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            print("User data: $user");

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    color: AppColor.primary,
                    padding: EdgeInsets.all(16),
                    child: Row(
                      children: [
                        /*CircleAvatar(
                          radius: 30,
                          backgroundImage: AssetImage(
                              'assets/MikoProfile.jpg'), // Replace with your asset
                        ),*/
                        SizedBox(width: 16),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  '${user?['firstname'] ?? 'Unknown'} ${user?['lastname'] ?? 'User'}',
                                  style: TextStyle(
                                      color: AppColor.textwhite,
                                      fontSize: 25,
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(width: 8),
                                // Ternary condition to display gender icon
                                user?['gender'] == 'Male'
                                    ? Icon(
                                  Icons.male,
                                  color: AppColor.yellowtext,
                                )
                                    : Icon(
                                  Icons.female,
                                  color: Colors.pink,
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Text(
                                  'Age: ',
                                  style: TextStyle(
                                      color: AppColor.yellowtext,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  user?['dateOfBirth'] != null
                                      ? computeAge(user!['dateOfBirth'])
                                      : 'N/A',
                                  style: TextStyle(
                                      color: AppColor.textwhite, fontSize: 14),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Row(
                                  children: [
                                    Text('Weight: ',
                                        style: TextStyle(
                                            color: AppColor.yellowtext,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    Text('${user?['weight'] ?? 'N/A'} Kg',
                                        style: TextStyle(
                                            color: AppColor.textwhite,
                                            fontSize: 14)),
                                  ],
                                ),
                                SizedBox(width: 8),
                                Row(
                                  children: [
                                    Text('Height: ',
                                        style: TextStyle(
                                            color: AppColor.yellowtext,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold)),
                                    Text('${user?['height'] ?? 'N/A'} CM',
                                        style: TextStyle(
                                            color: AppColor.textwhite,
                                            fontSize: 14)),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.yellowtext),
                          child: Text('Workout Log',
                              style: TextStyle(color: AppColor.buttonPrimary)),
                        ),
                        /*OutlinedButton(
                          onPressed: () {
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => WarningPage()));
                          },
                          style: OutlinedButton.styleFrom(
                              side: BorderSide(color: AppColor.buttonPrimary)),
                          child: Text('Charts',
                              style: TextStyle(color: AppColor.yellowtext)),
                        )*/
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Calories Burn',
                            style: TextStyle(
                                color: AppColor.yellowtext,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColor.buttonPrimary,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.local_fire_department, color: AppColor.primary, size: 30),
                              SizedBox(width: 16),
                              StreamBuilder<DocumentSnapshot>(
                                stream: FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(currentUser!.email)
                                    .collection('TotalCaloriesExercises')
                                    .doc('TotalCaloriesBurnofUser')
                                    .snapshots(),
                                builder: (context, snapshot) {
                                  if (snapshot.hasError) {
                                    return Text('Error', style: TextStyle(color: Colors.red));
                                  }

                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    return CircularProgressIndicator();
                                  }

                                  double totalCalories = snapshot.data?.get('TotalCaloriesBurned') ?? 0;
                                  double finalTotalCalories = snapshot.data?.get('FinalTotalCaloriesBurned') ?? 0;

                                  return Column(
                                    children: [
                                      Text(
                                        'Total Burned Calories: ${finalTotalCalories.toStringAsFixed(2)} Kcal',
                                        style: TextStyle(color: AppColor.textwhite, fontSize: 16),textAlign: TextAlign.start,
                                      ),
                                      Text(
                                        ' Burned Calories Today: ${totalCalories.toStringAsFixed(2)} Kcal',
                                        style: TextStyle(color: AppColor.textwhite, fontSize: 16),
                                      ),

                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 16),
                        Text('Total Minutes Exercise Today (Hours:Min:Sec)',
                            style: TextStyle(
                                color: AppColor.yellowtext,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        // Updated StreamBuilder for Total Exercise Time
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(currentUser!.email)
                              .collection('UserExerciseTimes')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            return FutureBuilder<int>(
                              future: _calculateTotalExerciseTime(snapshot.data!.docs),
                              builder: (context, totalTimeSnapshot) {
                                if (totalTimeSnapshot.connectionState == ConnectionState.waiting) {
                                  return CircularProgressIndicator();
                                }

                                int totalExerciseTime = totalTimeSnapshot.data ?? 0;

                                return Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: AppColor.buttonPrimary,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.access_time, color: AppColor.primary, size: 30),
                                      SizedBox(width: 16),
                                      Text(
                                        'Total Time: ${_formatTotalTime(totalExerciseTime)}',
                                        style: TextStyle(color: AppColor.textwhite, fontSize: 18),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        ),

                        SizedBox(height: 16),
                        Text('Total Minutes Exercise (Hours:Min:Sec)',
                            style: TextStyle(
                                color: AppColor.yellowtext,
                                fontSize: 18,
                                fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),



                        SizedBox(height: 16),
                        Text(
                          'Activities Today',
                          style: TextStyle(
                            color: AppColor.yellowtext,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(currentUser!.email)
                              .collection('UserExerciseTimes')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            final exerciseTimes = snapshot.data!.docs;

                            return Column(
                              children: exerciseTimes.map((doc) {
                                final data = doc.data() as Map<String, dynamic>?; // Ensure data is a map

                                if (data == null) return SizedBox(); // Handle null case safely

                                final String exerciseName = data['exerciseName'] ?? 'Unknown Exercise';
                                final int totalTime = data['totalExerciseTime'] ?? 0;
                                final Timestamp? lastUpdated = data['lastUpdated'] as Timestamp?;

                                // Convert timestamp to readable date format
                                final String formattedDate = lastUpdated != null
                                    ? DateFormat('MMM dd, yyyy - hh:mm a').format(lastUpdated.toDate())
                                    : 'N/A';

                                return ActivityCard(
                                  title: exerciseName,
                                  exeID: 'Date: $formattedDate',
                                  duration: _formatTotalTime(totalTime),
                                  timeanddate: '',
                                );
                              }).toList(),
                            );
                          },
                        ),


                        SizedBox(height: 16),
                        Text(
                          'Recent Activities',
                          style: TextStyle(
                            color: AppColor.yellowtext,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        StreamBuilder<DocumentSnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('Users')
                              .doc(currentUser!.email)
                              .collection('UserExercises')
                              .doc('--metadata--')
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) {
                              return Center(child: Text('Error: ${snapshot.error}'));
                            }

                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(child: CircularProgressIndicator());
                            }

                            final data = snapshot.data?.data() as Map<String, dynamic>?;

                            // Get all stored days and reverse the order (latest day first)
                            final List<dynamic> days = List.from(data?['currentDay'] ?? []);
                            days.sort((a, b) => b.compareTo(a)); // Sort descending (last index first)

                            if (days.isEmpty) {
                              return Center(child: Text('No exercise data available.'));
                            }

                            return StreamBuilder<List<QuerySnapshot>>(
                              stream: Stream.fromFuture(Future.wait(
                                days.map((day) => FirebaseFirestore.instance
                                    .collection('Users')
                                    .doc(currentUser!.email)
                                    .collection('UserExerciseTimes')
                                    .doc('Day$day') // Fetch data for each stored day
                                    .collection('times')
                                    .get(),
                                ),
                              )),
                              builder: (context, snapshot) {
                                if (snapshot.hasError) {
                                  return Center(child: Text('Error: ${snapshot.error}'));
                                }

                                if (snapshot.connectionState == ConnectionState.waiting) {
                                  return Center(child: CircularProgressIndicator());
                                }

                                // Flatten the list of QuerySnapshots into a list of documents
                                final List<QueryDocumentSnapshot> exerciseTimes = snapshot.data!
                                    .expand((querySnapshot) => querySnapshot.docs)
                                    .toList();

                                if (exerciseTimes.isEmpty) {
                                  return Center(child: Text('No recent activities available.'));
                                }

                                return Column(
                                  children: exerciseTimes.map((doc) {
                                    final data = doc.data() as Map<String, dynamic>;

                                    final String exerciseName = data['exerciseName'] ?? 'Unknown Exercise';
                                    final int totalTime = data['totalExerciseTime'] ?? 0;
                                    final Timestamp? lastUpdated = data['lastUpdated'] as Timestamp?;

                                    final String formattedDate = lastUpdated != null
                                        ? DateFormat('MMM dd, yyyy - hh:mm a').format(lastUpdated.toDate())
                                        : 'N/A';

                                    return ActivityCard(
                                      title: exerciseName,
                                      exeID: 'Date: $formattedDate',
                                      duration: _formatTotalTime(totalTime),
                                      timeanddate: '',
                                    );
                                  }).toList(),
                                );
                              },
                            );
                          },
                        )




                      ],
                    ),
                  ),
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

class ActivityCard extends StatelessWidget {
  final String title;
  final String exeID;
  final String duration;
  final String timeanddate;

  const ActivityCard({
    required this.title,
    required this.exeID,
    required this.duration,
    required this.timeanddate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColor.textwhite.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10)),
      child: Row(
        children: [
          Icon(Icons.directions_run, color: AppColor.primary, size: 30),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(color: AppColor.textwhite, fontSize: 16)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('$timeanddate',
                      style:
                      TextStyle(color: AppColor.yellowtext, fontSize: 14)),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Duration: $duration',
                          style:
                          TextStyle(color: AppColor.yellowtext, fontSize: 14,)),
                      Text('$exeID',
                          style:
                          TextStyle(color: AppColor.yellowtext, fontSize: 14)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}