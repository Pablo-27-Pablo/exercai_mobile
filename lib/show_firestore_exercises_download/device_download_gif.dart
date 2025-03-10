import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';


class DownloadGifsScreen extends StatefulWidget {
  @override
  _DownloadGifsScreenState createState() => _DownloadGifsScreenState();
}

class _DownloadGifsScreenState extends State<DownloadGifsScreen> {
  bool isDownloading = false;

  Future<void> fetchAndDownloadGifs() async {
    setState(() {
      isDownloading = true;
    });

    try {
      // Request storage permission
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print("Storage permission denied.");
        setState(() {
          isDownloading = false;
        });
        return;
      }

      CollectionReference exercisesRef = FirebaseFirestore.instance.collection('BodyweightExercises');

      // Get all documents from Firestore
      QuerySnapshot snapshot = await exercisesRef.get();

      for (var doc in snapshot.docs) {
        String exerciseName = doc['name'];
        String gifUrl = doc['gifUrl'];

        print("Downloading: $exerciseName");
        await downloadAndSaveGif(gifUrl, exerciseName);
      }

      print("All GIFs downloaded.");
    } catch (e) {
      print("Error fetching GIFs: $e");
    } finally {
      setState(() {
        isDownloading = false;
      });
    }
  }
 //IF YOU WANT TO SAVE YOU GIF TO Android/data/com.example.exercai_mobile/files/ IN YOUR FILE MANAGE
  Future<void> downloadAndSaveGif(String gifUrl, String fileName) async {
    try {
      // Get device's storage directory
      Directory? dir = await getExternalStorageDirectory();
      if (dir == null) {
        print("Failed to get storage directory.");
        return;
      }

      // Create the file path
      String filePath = '${dir.path}/$fileName.gif';

      // Download the GIF
      var response = await http.get(Uri.parse(gifUrl));
      if (response.statusCode == 200) {
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print("GIF saved to: $filePath");
      } else {
        print("Failed to download GIF.");
      }
    } catch (e) {
      print("Error downloading GIF: $e");
    }
  }


    //IF YOU WANT TO SAVE THE GIF IN THE GALLERY
  /*Future<void> downloadGif(String gifUrl, String gifName) async {
    try {
      // Request storage permission (for Android 10+)
      var status = await Permission.storage.request();
      if (!status.isGranted) {
        print("Storage permission denied.");
        return;
      }

      // Save to Pictures folder (visible in Gallery)
      String filePath = "/storage/emulated/0/Pictures/$gifName.gif";

      // Download the GIF
      var response = await http.get(Uri.parse(gifUrl));
      if (response.statusCode == 200) {
        File file = File(filePath);
        await file.writeAsBytes(response.bodyBytes);
        print("✅ GIF saved to: $filePath");

        // Refresh gallery so the file appears
        await Process.run('am', [
          'broadcast',
          '-a',
          'android.intent.action.MEDIA_SCANNER_SCAN_FILE',
          '-d',
          'file://$filePath'
        ]);

      } else {
        print("❌ Failed to download GIF.");
      }
    } catch (e) {
      print("⚠️ Error saving GIF: $e");
    }
  }*/


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Download GIFs")),
      body: Center(
        child: isDownloading
            ? CircularProgressIndicator()
            : ElevatedButton(
          onPressed: fetchAndDownloadGifs,
          child: Text("Download GIFs"),
        ),
      ),
    );
  }
}
