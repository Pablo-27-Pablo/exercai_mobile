import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';
import 'package:http/http.dart' as http;
import 'exercise_show_detail.dart';
import 'dart:convert';


class ExerciseApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Exercise List',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: ExerciseListScreen(),
    );
  }
}

class ExerciseListScreen extends StatefulWidget {
  @override
  _ExerciseListScreenState createState() => _ExerciseListScreenState();
}

class _ExerciseListScreenState extends State<ExerciseListScreen> {
  final String apiUrl = 'https://exercisedb.p.rapidapi.com/exercises?limit=1300';
  final Map<String, String> headers = {
    'X-RapidAPI-Key': '81efa21332mshc3d43597ee9e475p14e998jsn7776838f3ddd',
    'X-RapidAPI-Host': 'exercisedb.p.rapidapi.com',
  };

  List<dynamic> exercises = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchExercises();
  }

  Future<void> fetchExercises() async {
    try {
      final response = await http.get(Uri.parse(apiUrl), headers: headers);
      if (response.statusCode == 200) {
        List<dynamic> allExercises = json.decode(response.body);

        // Check if the widget is still in the tree before calling setState
        if (!mounted) return;

        setState(() {
          exercises = allExercises.where((exercise) =>
          exercise['equipment'] == 'body weight' &&
              exercise['bodyPart'] == 'shoulders'
              //
            //
          ).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load exercises');
      }
    } catch (e) {
      print('Error fetching exercises: $e');

      // Prevent calling setState() after the widget is disposed
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Exercises List")),
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
                    builder: (context) => ExerciseShowDetailScreen(exercise: exercise),
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