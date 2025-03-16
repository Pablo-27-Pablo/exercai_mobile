import 'dart:async';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/pages/Main_Pages/daysChallenge.dart';
import 'package:exercai_mobile/pages/realtime_2.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:flutter/material.dart';

class StartIn extends StatefulWidget {
  const StartIn({super.key});

  @override
  State<StartIn> createState() => _StartInState();
}

class _StartInState extends State<StartIn> {
  int _countdown = 5;
  double _fontSize = 80;
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    Timer.periodic(Duration(seconds: 1), (timer) {
      if (_countdown == 1) {
        timer.cancel();
        
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => MyHomePage()),
          );
        
      }
      setState(() {
        _countdown--;
        _isAnimating = !_isAnimating;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "Start in",
              style: TextStyle(
                color: AppColor.primary,
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            AnimatedDefaultTextStyle(
              duration: Duration(milliseconds: 500),
              style: TextStyle(
                color:
                    _isAnimating
                        ? AppColor.primary
                        : AppColor.primary.withOpacity(0.7),
                fontSize: _isAnimating ? 100 : 80,
                fontWeight: _isAnimating ? FontWeight.bold : FontWeight.normal,
              ),
              child: Text("$_countdown"),
            ),
          ],
        ),
      ),
    );
  }
}
