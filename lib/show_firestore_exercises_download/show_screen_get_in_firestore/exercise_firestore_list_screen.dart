import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'detail_screen_firestore.dart';
import 'package:exercai_mobile/main.dart';


class ExerciseFirestore extends StatefulWidget {
  @override
  _ExerciseFirestoreState createState() => _ExerciseFirestoreState();
}

class _ExerciseFirestoreState extends State<ExerciseFirestore> {
  List<Map<String, dynamic>> exercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExercisesFromFirestore();
  }

  Future<void> fetchExercisesFromFirestore() async {
    try {
      List<Map<String, dynamic>> fetchedExercises = [];

      // Fetch exercises with 'bodyPart' == 'shoulders'
      QuerySnapshot lowerArmsSnapshot = await FirebaseFirestore.instance
          .collection('BodyweightExercises')
          .where('bodyPart', isEqualTo: 'lower arms')
          .get();

      QuerySnapshot backSnapshot = await FirebaseFirestore.instance
          .collection('BodyweightExercises')
          .where('bodyPart', isEqualTo: 'back')
          .get();

      // Fetch exercises with 'bodyPart' == 'shoulders'
      QuerySnapshot shouldersSnapshot = await FirebaseFirestore.instance
          .collection('BodyweightExercises')
          .where('bodyPart', isEqualTo: 'shoulders')
          .get();

      // Fetch exercises with 'bodyPart' == 'neck'
      QuerySnapshot neckSnapshot = await FirebaseFirestore.instance
          .collection('BodyweightExercises')
          .where('bodyPart', isEqualTo: 'neck')
          .get();

      // Merge results into a single list
      fetchedExercises.addAll(lowerArmsSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>));
      fetchedExercises.addAll(backSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>));
      fetchedExercises.addAll(shouldersSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>));
      fetchedExercises.addAll(neckSnapshot.docs.map((doc) => doc.data() as Map<String, dynamic>));

      setState(() {
        exercises = fetchedExercises;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching exercises from Firestore: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Shoulders & Neck Exercises")),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: exercises.length,
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          return Card(
            margin: EdgeInsets.all(8),
            elevation: 3,
            child: ListTile(
              leading: Image.network(
                exercise['gifUrl'],
                width: 60,
                height: 60,
                fit: BoxFit.cover,
              ),
              title: Text(exercise['name']),
              subtitle: Text(
                "Target: ${exercise['target']}\n"
                    "Body Part: ${exercise['bodyPart']}\n"
                    "Equipment: ${exercise['equipment']}\n"
                    "ID: ${exercise['id']}",
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FirestoreExerciseShow(exercise: exercise),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
