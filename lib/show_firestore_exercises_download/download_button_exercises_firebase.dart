import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';
import 'exercise_download_firebase.dart';

class ButtonDownloadExercises extends StatelessWidget {
  const ButtonDownloadExercises({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Button To Download Exercises To Firebase'),centerTitle: true),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton(
              onPressed: () async {
                await fetchAndStoreBodyweightExercises();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Exercises saved to Firestore!")),
                );
              },
              child: Text("Download Bodyweight Exercises"),
            ),
          )

        ],
      ),
    );
  }
}
