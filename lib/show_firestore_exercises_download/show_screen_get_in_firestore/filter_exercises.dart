import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'detail_screen_firestore.dart';

class FilterExerciseFirestore extends StatefulWidget {
  @override
  _FilterExerciseFirestoreState createState() => _FilterExerciseFirestoreState();
}

class _FilterExerciseFirestoreState extends State<FilterExerciseFirestore> {
  List<Map<String, dynamic>> exercises = [];
  bool isLoading = true;
  String? selectedDifficulty;
  String? selectedBMI;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  // Fetch user data (bmiCategory & workoutLevel) from Firestore
  Future<void> fetchUserData() async {
    try {
      setState(() => isLoading = true);

      User? user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        print("No user logged in.");
        setState(() => isLoading = false);
        return;
      }

      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .get();

      if (!userDoc.exists) {
        print("User document not found.");
        setState(() => isLoading = false);
        return;
      }

      final userData = userDoc.data() as Map<String, dynamic>;
      String bmiCategory = userData['bmiCategory'] ?? 'normal';
      String workoutLevel = userData['workoutLevel'] ?? 'beginner';

      setState(() {
        selectedBMI = bmiCategory;
        selectedDifficulty = workoutLevel;
      });

      fetchExercisesFromFirestore();
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  // Fetch and filter exercises from Firestore based on user's difficulty & BMI
  Future<void> fetchExercisesFromFirestore() async {
    if (selectedDifficulty == null || selectedBMI == null) return;

    try {
      setState(() => isLoading = true);

      final difficultyMap = exerciseData[selectedDifficulty!] ?? {};
      final bmiMap = difficultyMap[selectedBMI!] ?? {};

      List<Map<String, dynamic>> fetchedExercises = [];

      for (var bodyPart in bmiMap.keys) {
        QuerySnapshot snapshot = await FirebaseFirestore.instance
            .collection('BodyweightExercises')
            .where('bodyPart', isEqualTo: bodyPart)
            .get();

        final allowedExercises = bmiMap[bodyPart] ?? [];
        fetchedExercises.addAll(
          snapshot.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .where(
                (exercise) => allowedExercises.contains(
              exercise['name'].toString().toLowerCase(),
            ),
          )
              .toList(),
        );
      }

      if (!mounted) return;
      setState(() {
        exercises = fetchedExercises;
        isLoading = false;
      });
    } catch (e) {
      print('Error fetching exercises from Firestore: $e');
      setState(() => isLoading = false);
    }
  }

  // Exercise data structure
  final Map<String, Map<String, Map<String, List<String>>>> exerciseData = {
    'beginner': {
      'underweight': {
        'back': ['seated lower back stretch', 'spine stretch'],
        'chest': ['push-up (wall)'],
        'cardio': ['high knee against wall'],
      },
      'normal': {
        'back': ['standing lateral stretch', 'kneeling lat stretch'],
        'chest': ['kneeling push-up (male)', 'dynamic chest stretch (male)'],
        'cardio': ['run'],
      },
      'overweight': {
        'back': ['side lying floor stretch', 'standing pelvic tilt'],
        'chest': ['isometric chest squeeze'],
        'cardio': ['high knee against wall'],
      },
      'obese': {
        'back': ['lower back curl'],
        'chest': ['push-up (wall)'],
      },
      'extreme_obese': {
        'back': ['sphinx'],
        'chest': ['isometric chest squeeze'],
      },
    },
    'intermediate': {
      'underweight': {
        'back': ['upward facing dog'],
        'chest': ['incline push-up'],
        'cardio': ['mountain climber'],
      },
      'normal': {
        'back': ['two toe touch (male)'],
        'chest': ['decline push-up'],
        'cardio': ['burpee'],
      },
      'overweight': {
        'back': ['lower back curl'],
        'chest': ['shoulder tap push-up'],
        'cardio': ['push to run'],
      },
      'obese': {
        'back': ['upper back stretch'],
        'chest': ['wide hand push up'],
      },
      'extreme_obese': {
        'back': ['sphinx'],
        'chest': ['clock push-up'],
      },
    },
    'advanced': {
      'underweight': {
        'back': ['one arm against wall'],
        'chest': ['archer push up'],
        'cardio': ['star jump (male)'],
      },
      'normal': {
        'back': ['one arm against wall'],
        'chest': ['push and pull bodyweight'],
        'cardio': ['semi squat jump (male)'],
      },
      'overweight': {
        'back': ['one arm against wall'],
        'chest': ['isometric wipers'],
      },
      'obese': {
        'back': [],
        'chest': ['push-up'],
      },
      'extreme_obese': {
        'back': [],
        'chest': [],
      },
    },
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          selectedDifficulty == null || selectedBMI == null
              ? "Loading..."
              : "Exercises for $selectedDifficulty ($selectedBMI)",
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : exercises.isEmpty
          ? Center(child: Text("No exercises found for your category."))
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
                    builder: (context) =>
                        FirestoreExerciseShow(exercise: exercise),
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
