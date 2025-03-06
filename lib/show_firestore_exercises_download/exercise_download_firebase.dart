import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> fetchAndStoreBodyweightExercises() async {
  const String apiUrl = 'https://exercisedb.p.rapidapi.com/exercises?limit=1300';

  const Map<String, String> headers = {
    'X-RapidAPI-Key': '81efa21332mshc3d43597ee9e475p14e998jsn7776838f3ddd', // Replace with your API key
    'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
  };

  try {
    final response = await http.get(Uri.parse(apiUrl), headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> allExercises = json.decode(response.body);

      // Filter exercises for bodyweight only
      List<dynamic> bodyweightExercises = allExercises
          .where((exercise) => exercise['equipment'].toLowerCase() == 'body weight')
          .toList();

      // Reference Firestore collection
      CollectionReference exercisesRef =
      FirebaseFirestore.instance.collection('BodyweightExercises');

      for (var exercise in bodyweightExercises) {
        String exerciseId = exercise['id'].toString();
        String newGifUrl = exercise['gifUrl'];

        // Check if the exercise already exists
        DocumentSnapshot existingExercise = await exercisesRef.doc(exerciseId).get();

        if (existingExercise.exists) {
          Map<String, dynamic>? existingData = existingExercise.data() as Map<String, dynamic>?;

          // Update gifUrl if it's different
          if (existingData != null && existingData['gifUrl'] != newGifUrl) {
            await exercisesRef.doc(exerciseId).update({'gifUrl': newGifUrl});
            print("Updated gifUrl for exercise ID: $exerciseId");
          } else {
            print("Exercise ID $exerciseId already exists with the same gifUrl. Skipping...");
          }
        } else {
          // Store the full exercise if it doesn't exist
          await exercisesRef.doc(exerciseId).set({
            'id': exerciseId,
            'name': exercise['name'],
            'equipment': exercise['equipment'],
            'bodyPart': exercise['bodyPart'],
            'target': exercise['target'],
            'gifUrl': newGifUrl,
            'instructions': List<String>.from(exercise['instructions'] ?? []),
            'secondaryMuscles': List<String>.from(exercise['secondaryMuscles'] ?? []),
          });

          print("Stored new exercise: ${exercise['name']} (ID: $exerciseId)");
        }
      }

      print("Bodyweight exercises have been stored/updated in Firestore.");
    } else {
      throw Exception('Failed to fetch exercises');
    }
  } catch (e) {
    print('Error fetching/storing exercises: $e');
  }
}
