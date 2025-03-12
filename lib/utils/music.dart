import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';
import 'music_background.dart';

class MusicBackground extends StatefulWidget {
  const MusicBackground();

  @override
  State<MusicBackground> createState() => _MusicBackgroundState();
}

class _MusicBackgroundState extends State<MusicBackground> {
  final musicPlayer = MusicPlayerService();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                musicPlayer.play();
              },
              child: const Text('Play Audio'),
            ),

            ElevatedButton(onPressed: () {}, child: const Text('Stop Audio')),

            ElevatedButton(onPressed: () {}, child: const Text('Pause')),

            ElevatedButton(onPressed: () {}, child: const Text('Resume')),
          ],
        ),
      ),
    );
  }
}
