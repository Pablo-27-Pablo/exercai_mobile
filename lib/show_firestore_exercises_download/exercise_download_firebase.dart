import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<void> fetchAndStoreBodyweightExercises() async {
  const String apiUrl = 'https://exercisedb.p.rapidapi.com/exercises?limit=1300';

  const Map<String, String> headers = {
    'X-RapidAPI-Key': '81efa21332mshc3d43597ee9e475p14e998jsn7776838f3ddd', // Replace with your API key
    'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
  };

  // List of specific bodyweight exercises (case-sensitive)
  const List<String> specificExercises = [
    "seated lower back stretch", "standing lateral stretch", "kneeling lat stretch", "lower back curl", "one arm against wall", "side lying floor stretch", "sphinx", "spine stretch", "standing pelvic tilt", "upper back stretch", "upward facing dog", "two toe touch (male)",
    "mountain climber", "run", "burpee", "astride jumps (male)", "half knee bends (male)", "semi squat jump (male)", "star jump (male)", "skater hops", "high knee against wall", "push to run",
    "clock push-up", "decline push-up", "incline push-up", "isometric wipers", "push-up (wall)", "push-up", "shoulder tap push-up", "dynamic chest stretch (male)", "isometric chest squeeze", "wide hand push-up", "push and pull bodyweight", "kneeling push-up (male)", "archer push up",
    "side wrist pull stretch", "modified push up to lower arms", "wrist circles",
    "circles knee stretch", "ankle circles", "bodyweight standing calf raise", "calf stretch with hands against wall", "one leg floor calf raise", "standing calves", "calf push stretch with hands against wall", "standing calf raise (on a staircase)",
    "side push neck stretch", "neck side stretch",
    "rear deltoid stretch", "left hook. boxing",
    "body-up", "close-grip push-up", "diamond push-up", "overhead triceps stretch", "reverse dip", "side push-up", "triceps dips floor", "triceps stretch", "push-up on lower arms", "bodyweight side lying biceps curl", "biceps leg concentration curl", "bodyweight kneeling triceps extension", "close-grip push-up (on knees)", "bench dip (knees bent)",
    "jump squat", "kick out sit", "lying (side) quads stretch", "march sit (wall)", "rear decline bridge", "side hip abduction", "single leg platform slide", "standing single leg curl", "hug keens to chest", "iron cross stretch", "pelvic tilt into bridge", "seated glute stretch", "straight leg outer hip abductor", "walking lunge", "twist hip lift", "forward jump", "backward jump", "butterfly yoga pose", "hamstring stretch", "all fours squad stretch", "leg up hamstring stretch", "runners stretch", "seated wide angle pose sequence", "world greatest stretch", "squat to overhead reach", "side bridge hip abduction", "split squats", "bodyweight drop jump squat", "quick feet v. 2", "lunge with jump",
    "3/4 sit-up", "air bike", "alternate heel touchers", "bottoms-up", "cocoons", "cross body crunch", "crunch (hands overhead)", "crunch floor", "dead bug", "elbow-to-knee", "flexion leg sit up (bent knee)", "flexion leg sit up (straight arm)", "front plank with twist", "groin crunch", "hip raise (bent knee)", "jackknife sit-up", "janda sit-up", "oblique crunches floor", "push-up to side plank", "russian twist", "seated side crunch (wall)", "side bridge v. 2", "sit-up v. 2", "butt-ups", "tuck crunch", "reverse crunch", "crab twist toe touch", "inchworm", "posterior step to overhead reach", "lunge with twist", "lying elbow to knee", "spine twist", "frog crunch", "bridge - mountain climber (cross body)", "curl-up", "pelvic tilt", "potty squat", "quarter sit-up", "knee touch crunch"


  ];

  try {
    final response = await http.get(Uri.parse(apiUrl), headers: headers);
    if (response.statusCode == 200) {
      List<dynamic> allExercises = json.decode(response.body);

      // Filter only the exercises from the specified list
      List<dynamic> selectedExercises = allExercises
          .where((exercise) => exercise['equipment'].toLowerCase() == 'body weight' &&
          specificExercises.contains(exercise['name']))
          .toList();

      // Reference Firestore collection
      CollectionReference exercisesRef =
      FirebaseFirestore.instance.collection('BodyweightExercises');

      for (var exercise in selectedExercises) {
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

      print("Selected bodyweight exercises have been stored/updated in Firestore.");
    } else {
      throw Exception('Failed to fetch exercises');
    }
  } catch (e) {
    print('Error fetching/storing exercises: $e');
  }
}
