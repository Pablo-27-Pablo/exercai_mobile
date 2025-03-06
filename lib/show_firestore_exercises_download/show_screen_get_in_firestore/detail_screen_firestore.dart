import 'package:flutter/material.dart';

class FirestoreExerciseShow extends StatelessWidget {
  final Map<String, dynamic> exercise;

  FirestoreExerciseShow({required this.exercise});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(exercise['name'] ?? 'Exercise Details')),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.network(
                exercise['gifUrl'] ?? '',
                width: 250,
                height: 250,
              ),
            ),
            SizedBox(height: 20),
            Text("Body Part: ${exercise['bodyPart']}", style: _headerStyle()),
            SizedBox(height: 10),
            Text("Equipment: ${exercise['equipment']}", style: _headerStyle()),
            SizedBox(height: 10),
            Text("Target Muscle: ${exercise['target']}", style: _headerStyle()),
            SizedBox(height: 20),
            Text("Instructions:", style: _headerStyle()),
            SizedBox(height: 10),
            ...List.generate(
              exercise['instructions'].length,
                  (index) => Text("• ${exercise['instructions'][index]}"),
            ),
            SizedBox(height: 20),
            Text("Secondary Muscles:", style: _headerStyle()),
            SizedBox(height: 10),
            ...List.generate(
              exercise['secondaryMuscles'].length,
                  (index) => Text("• ${exercise['secondaryMuscles'][index]}"),
            ),
          ],
        ),
      ),
    );
  }

  TextStyle _headerStyle() => TextStyle(fontSize: 18, fontWeight: FontWeight.bold);
}
