import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

const String apiUrl = 'https://exercisedb.p.rapidapi.com/exercises?limit=1300';
const Map<String, String> headers = {
  'X-RapidAPI-Key': '81efa21332mshc3d43597ee9e475p14e998jsn7776838f3ddd', // Replace with your API key
  'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
};

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
    fetchCardioExercises();
  }

  Future<void> fetchCardioExercises() async {
    try {
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: headers,
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        List<Map<String, dynamic>> filteredExercises = data
            .where((e) => e['bodyPart'] == 'cardio' && e['equipment'] == 'body weight')
            .map((e) => e as Map<String, dynamic>)
            .toList();

        setState(() {
          exercises = filteredExercises;
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load cardio exercises');
      }
    } catch (e) {
      print('Error fetching cardio exercises from API: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Cardio Exercises (Body Weight)")),
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
/*                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FirestoreExerciseShow(exercise: exercise),
                  ),
                );*/
              },
            ),
          );
        },
      ),
    );
  }
}
