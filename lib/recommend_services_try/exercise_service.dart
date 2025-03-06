// exercise_service.dart
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'exercise_detail_screen.dart';
import 'exercise_model.dart';
import 'exercise_detail_screen.dart';

class ExerciseRecommendationService {
  final String apiUrl = 'https://exercisedb.p.rapidapi.com/exercises?limit=15';
  final Map<String, String> headers = {
    'X-RapidAPI-Key': '81efa21332mshc3d43597ee9e475p14e998jsn7776838f3ddd',
    'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
  };

  // Target area mapping
  static const Map<String, List<String>> targetMapping = {
    'upper body': ['back', 'chest', 'shoulders', 'arms'],
    'lower body': ['legs', 'glutes', 'calves', 'thighs'],
    'full body': ['full body']
  };

  final Map<String, List<String>> goalTargets = {
    'lose weight': ['cardiovascular system', 'full body', 'core'],
    'muscle mass gain': ['biceps', 'triceps', 'chest', 'back', 'quadriceps', 'hamstrings', 'abs', 'lats', 'shoulders'],
    'maintain': ['cardiovascular system', 'biceps', 'triceps', 'chest', 'core']
  };

  final Map<String, List<String>> injuryAvoidance = {
    'none of them': [],
    'knee': ['squat', 'lunge'],
    'shoulder': ['overhead press', 'lateral raise'],
    'back': ['deadlift', 'bent-over row'],
    'ankle': ['box jump', 'plyometric'],
    'wrist': ['handstand', 'wrist curl']
  };

  Future<List<Exercise>> fetchExercises() async {
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List;
        return data.map((e) => Exercise.fromJson(e)).toList();
      }
      return [];
    } catch (e) {
      print('Error fetching exercises: $e');
      return [];
    }
  }

  Future<List<Exercise>> filterExercises() async {
    final exercises = await fetchExercises();
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return [];

    final userDoc = await FirebaseFirestore.instance.collection('Users').doc(user.email).get();
    final userData = userDoc.data() as Map<String, dynamic>? ?? {};

    // Get user preferences
    final String goal = (userData['goal'] ?? '').toLowerCase();
    final String workoutLevel = (userData['workoutLevel'] ?? '').toLowerCase();
    final List<String> injuries = (userData['injuryArea']?.toString().toLowerCase().split(', ') ?? []);

    // Process target area
    final String targetArea = (userData['targetArea'] ?? '').toLowerCase().split(' ')[0];
    final allowedBodyParts = targetMapping[targetArea] ?? [];

    const difficultyMap = {
      'beginner': ['beginner'],
      'intermediate': ['beginner', 'intermediate'],
      'advanced': ['beginner', 'intermediate', 'advanced']
    };

    return exercises.where((exercise) {
      // 1. Difficulty filter
      if (!(difficultyMap[workoutLevel]?.contains(exercise.difficulty?.toLowerCase()) ?? true)) {
        return false;
      }

      // 2. Goal filter
      if (!(goalTargets[goal]?.any((t) => exercise.target.toLowerCase().contains(t)) ?? false)) {
        return false;
      }

      // 3. Injury filter
      if (injuries.isNotEmpty && !injuries.contains('none of them')) {
        final shouldAvoid = injuries.any((injury) {
          final avoidedExercises = injuryAvoidance[injury] ?? [];
          return avoidedExercises.any((avoid) =>
              exercise.name.toLowerCase().contains(avoid.toLowerCase()));
        });
        if (shouldAvoid) return false;
      }

      // 4. Target area filter
      if (allowedBodyParts.isNotEmpty) {
        final exerciseBodyPart = exercise.bodyPart?.toLowerCase() ?? '';
        if (!allowedBodyParts.any((part) => exerciseBodyPart.contains(part))) {
          return false;
        }
      }

      return true;
    }).take(15).toList();
  }

  Future<void> saveRecommendedExercises() async {
    final filtered = await filterExercises();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('Users').doc(user.email).set(
        {'recommendedExercises': filtered.map((e) => e.toMap()).toList()},
        SetOptions(merge: true),
      );
    }
  }
}


void updatePreferences(BuildContext context) async {
  await ExerciseRecommendationService().saveRecommendedExercises();
  Navigator.pop(context); // Close the current page
}


class RecommendedExercisePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Row(
        children: [
          Text('Recommended Exercises'),
          TextButton(onPressed: (){
            updatePreferences(context);
          }, child: Icon(Icons.change_circle_outlined))
        ],
      )),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('Users')
            .doc(FirebaseAuth.instance.currentUser?.email)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text("No user data found"));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final exercises = List<Map<String, dynamic>>.from(data['recommendedExercises'] ?? []);

          if (exercises.isEmpty) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("No exercises found"),
                ElevatedButton(
                  onPressed: () => updatePreferences(context),
                  child: Text("Retry"),
                )
              ],
            );
          }

          return ListView.builder(
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              final exercise = exercises[index];
              return Card(
                margin: EdgeInsets.all(8),
                elevation: 2,
                child: ListTile(
                  leading: CachedNetworkImage(
                    imageUrl: exercise['gifUrl'] ?? '',
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                  title: Text(exercise['name'] ?? 'Unnamed Exercise'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Target: ${exercise['target']?.toString().toTitleCase() ?? 'General'}'),
                      Text('Equipment: ${exercise['equipment'] ?? 'Body Weight'}'),
                      Text('Difficulty: ${(exercise['difficulty'] ?? 'Medium').toString().toTitleCase()}'),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ExerciseDetailScreen(
                          exercise: Exercise(
                            id: exercise['id']?.toString() ?? '',
                            name: exercise['name'] ?? 'Unnamed Exercise',
                            bodyPart: exercise['bodyPart'] ?? 'Unknown',
                            equipment: exercise['equipment'] ?? 'None',
                            target: exercise['target'] ?? 'General',
                            difficulty: exercise['difficulty'] ?? 'Medium', // Add this line
                            gifUrl: exercise['gifUrl'] ?? '',
                            secondaryMuscles: (exercise['secondaryMuscles'] as List<dynamic>?)
                                ?.map((e) => e.toString())
                                .toList() ?? [],
                            instructions: (exercise['instructions'] as List<dynamic>?)
                                ?.map((e) => e.toString())
                                .toList() ?? ['No instructions available'],
                          ),

                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );

        },
      ),
    );
  }
}

extension StringExtensions on String {
  String toTitleCase() {
    return split(' ').map((word) => word[0].toUpperCase() + word.substring(1)).join(' ');
  }
}
