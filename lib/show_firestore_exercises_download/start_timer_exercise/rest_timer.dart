import 'package:flutter/material.dart';
import 'dart:async';
import 'package:exercai_mobile/main.dart';

class RestTimer extends StatefulWidget {
  final int initialSeconds;

  const RestTimer({super.key, required this.initialSeconds});

  @override
  State<RestTimer> createState() => _RestTimerState();
}

class _RestTimerState extends State<RestTimer> {
  late int _secondsRemaining;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _secondsRemaining = widget.initialSeconds;
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_secondsRemaining > 0) {
          _secondsRemaining--;
        } else {
          _stopTimer();
        }
      });
    });
    setState(() => _isRunning = true);
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _stopTimer();
    setState(() => _secondsRemaining = widget.initialSeconds);
  }

  void _skipForward() {
    setState(() => _secondsRemaining = 0);
    _stopTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final progress = 1 - (_secondsRemaining / widget.initialSeconds);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Rest Time'),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(
                    Theme.of(context).primaryColor,
                  ),
                ),
              ),
              Text(
                '$_secondsRemaining',
                style: const TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.replay),
                iconSize: 40,
                onPressed: _resetTimer,
              ),
              const SizedBox(width: 30),
              IconButton(
                icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                iconSize: 50,
                onPressed: () => _isRunning ? _stopTimer() : _startTimer(),
              ),
              const SizedBox(width: 30),
              IconButton(
                icon: const Icon(Icons.forward),
                iconSize: 40,
                onPressed: _skipForward,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Usage example:
// Navigator.push(context, MaterialPageRoute(builder: (context) =>
//   FrogStandTimer(initialSeconds: 21)));