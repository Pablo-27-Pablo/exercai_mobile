import 'package:flutter/material.dart';
import 'dart:async';
import 'package:exercai_mobile/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../workout_complete/workoutcomplete.dart';

class TimerRepsExercise extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final List<int> setValues;
  final bool isRepBased;
  final int restTime;

  const TimerRepsExercise({
    super.key,
    required this.exercise,
    required this.setValues,
    required this.isRepBased,
    required this.restTime,
  });

  @override
  State<TimerRepsExercise> createState() => _TimerRepsExerciseState();
}

class _TimerRepsExerciseState extends State<TimerRepsExercise> {
  late int _currentStepIndex;
  late int _secondsRemaining;
  late int _currentCount;
  Timer? _timer;
  bool _isRunning = false;
  late List<Step> _steps;
  int _totalExerciseTime = 0;
  bool _initialDataLoaded = false;
  List<int> _baseRepsConcat = [];
  List<double> _totalBurnCalRep = [];


  @override
  void initState() {
    super.initState();
    _currentStepIndex = 0;
    _steps = _createSteps();
    _secondsRemaining = _steps[_currentStepIndex].duration;
    _currentCount = 0;
    _baseRepsConcat = List.filled(widget.setValues.length, 0);

    _loadTotalExerciseTime().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimer();
      });
    });
  }

  // Define the _createSteps method
  List<Step> _createSteps() {
    List<Step> steps = [];
    for (int i = 0; i < widget.setValues.length; i++) {
      steps.add(Step(type: StepType.set, duration: widget.setValues[i]));
      steps.add(Step(type: StepType.rest, duration: widget.restTime));
    }
    return steps;
  }


  Future<void> _saveTotalBurnCalRep(int setIndex) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    double setCalories = (_baseRepsConcat[setIndex] as num).toDouble() *
        (widget.exercise['burnCalperRep']?.toDouble() ?? 0.0);

    DocumentReference exerciseRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .collection('UserExercises')
        .doc(widget.exercise['name'].toString());

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(exerciseRef);

      List<dynamic> totalBurnCalRep = [];

      if (!snapshot.exists || snapshot.data() == null || !(snapshot.data() as Map<String, dynamic>).containsKey('TotalBurnCalRep')) {
        // Initialize the document with an empty TotalBurnCalRep array
        transaction.set(exerciseRef, {
          'TotalBurnCalRep': [],
          'FinalTotalBurnCalRep': 0.0,
          'burnCalperRep': widget.exercise['burnCalperRep']?.toDouble() ?? 0.0,
          'lastUpdated': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else {
        totalBurnCalRep = List.from((snapshot.data() as Map<String, dynamic>)['TotalBurnCalRep'] ?? []);
      }

      // Append new value, even if it's a duplicate
      totalBurnCalRep.add(setCalories);

      transaction.update(exerciseRef, {
        'TotalBurnCalRep': totalBurnCalRep,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });

    print("Saved TotalBurnCalRep[$setIndex]: $setCalories kcal");

    // Update the final total burned calories
    await _updateFinalTotalBurnCalRep();
  }


  Future<void> _updateFinalTotalBurnCalRep() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    DocumentReference exerciseRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .collection('UserExercises')
        .doc(widget.exercise['name'].toString());

    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(exerciseRef);

      if (snapshot.exists) {
        List<dynamic> totalBurnCalRep = snapshot['TotalBurnCalRep'] as List<dynamic>? ?? [];

        // Calculate sum of all values in TotalBurnCalRep
        double finalTotalBurnCalRep = totalBurnCalRep.fold(0.0, (sum, val) => sum + (val as num).toDouble());

        // Update Firestore document with the final sum
        transaction.update(exerciseRef, {
          'FinalTotalBurnCalRep': finalTotalBurnCalRep,
          'lastUpdated': FieldValue.serverTimestamp(),
        });

        print("Updated FinalTotalBurnCalRep: $finalTotalBurnCalRep kcal");
      }
    });
  }








  Future<void> _loadTotalExerciseTime() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Load total time from the new collection UserExerciseTimes
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .collection('UserExerciseTimes')
        .doc(widget.exercise['name'].toString())
        .get();

    if (doc.exists) {
      setState(() {
        _totalExerciseTime = doc['totalExerciseTime'] ?? 0;
        _initialDataLoaded = true;
      });
    }
  }

  Future<void> _saveTotalExerciseTime() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    // Save total time to the new collection UserExerciseTimes
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .collection('UserExerciseTimes')
        .doc(widget.exercise['name'].toString())
        .set({
      'exerciseId': widget.exercise['id'],
      'exerciseName': widget.exercise['name'],
      'totalExerciseTime': _totalExerciseTime,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true)); // Merge to avoid overwriting other fields
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final currentStep = _steps[_currentStepIndex];

        // Track exercise time only during sets (not rest)
        if (_isRunning && currentStep.type == StepType.set) {
          _totalExerciseTime++;
          _saveTotalExerciseTime(); // Save total time to Firestore every second
        }

        if (currentStep.type == StepType.set && widget.isRepBased) {
          _currentCount++;
        } else {
          if (_secondsRemaining > 0) {
            _secondsRemaining--;
          } else {
            _handleStepCompletion();
          }
        }
      });
    });
  }

  void _handleStepCompletion() {
    _stopTimer();
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _secondsRemaining = _steps[_currentStepIndex].duration;
        _currentCount = 0;
      });
      _startTimer();
    } else {
      _saveTotalExerciseTime();
      _markExerciseAsCompleted();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CompleteWorkout()),
      );
    }
  }

  void _markExerciseAsCompleted() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .collection('UserExercises')
          .doc(widget.exercise['name'].toString())
          .update({'completed': true, 'lastCompleted': FieldValue.serverTimestamp()});
    } catch (e) {
      print('Error marking exercise as completed: $e');
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() => _isRunning = false);
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _secondsRemaining = _steps[_currentStepIndex].duration;
      _currentCount = 0;
    });
  }

  void _skipForward() {
    _stopTimer();
    _saveTotalExerciseTime();
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _secondsRemaining = _steps[_currentStepIndex].duration;
        _currentCount = 0;
      });
      _startTimer();
    } else {
      _markExerciseAsCompleted();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => CompleteWorkout()),
      );
    }
  }

  void _rewindStep() {
    _stopTimer();
    if (_currentStepIndex > 0) {
      setState(() {
        _currentStepIndex--;
        _secondsRemaining = _steps[_currentStepIndex].duration;
        _currentCount = 0;
      });
      _startTimer();
    }
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return minutes > 0 ? '$minutes:${secs.toString().padLeft(2, '0')}' : '$secs';
  }

  @override
  void dispose() {
    // Save total exercise time when the screen is exited
    if (_initialDataLoaded) {
      _saveTotalExerciseTime();
    }
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _steps[_currentStepIndex];
    final setNumber = (_currentStepIndex ~/ 2) + 1;
    final isRestAfterSet = currentStep.type == StepType.rest && _currentStepIndex > 0;
    final isLastRest = isRestAfterSet && _currentStepIndex == _steps.length - 1;

    final progress = currentStep.type == StepType.set && widget.isRepBased
        ? 0.0
        : 1 - (_secondsRemaining / currentStep.duration);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise['name'] ?? 'Exercise Timer'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.network(
              widget.exercise['gifUrl'] ?? '',
              height: 180,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) =>
              const Icon(Icons.error_outline, size: 100),
            ),
            const SizedBox(height: 10),
            Text(
              currentStep.type == StepType.set
                  ? 'Set $setNumber of ${widget.setValues.length}'
                  : 'Rest $setNumber',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              currentStep.type == StepType.set
                  ? widget.isRepBased
                  ? '${_formatTime(_currentCount)} / ${currentStep.duration} Reps'
                  : '$_secondsRemaining Seconds'
                  : '$_secondsRemaining Seconds Rest',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 200,
                  height: 200,
                  child: CircularProgressIndicator(
                    value: progress.clamp(0.0, 1.0),
                    strokeWidth: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      currentStep.type == StepType.set && widget.isRepBased
                          ? Colors.grey
                          : Theme.of(context).primaryColor,
                    ),
                  ),
                ),
                Text(
                  currentStep.type == StepType.set
                      ? widget.isRepBased
                      ? _formatTime(_currentCount)
                      : '$_secondsRemaining'
                      : '$_secondsRemaining',
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
           // if (!isLastRest) // Hide icon buttons during the last rest para sa last button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Ensures equal spacing
                children: [
                  IconButton(
                    icon: const Icon(Icons.fast_rewind),
                    iconSize: 40,
                    onPressed: _currentStepIndex > 0 ? _rewindStep : null,
                  ),
                  IconButton(
                    icon: const Icon(Icons.replay),
                    iconSize: 40,
                    onPressed: _resetTimer,
                  ),
                  IconButton(
                    icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                    iconSize: 50,
                    onPressed: () => _isRunning ? _stopTimer() : _startTimer(),
                  ),
                  IconButton(
                    icon: const Icon(Icons.double_arrow),
                    iconSize: 40,
                    onPressed: _skipForward,
                  ),
                ],
              ),
            if (isRestAfterSet)
              Column(
                children: [
                  const SizedBox(height: 10,),
                  Text(
                    'Calories Burnt in Set: ${_calculateCurrentSetCalories(setNumber - 1).toStringAsFixed(2)} kcal',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10,),
        
                  // Show TextField only for Rep-Based exercises
                  if (widget.isRepBased)
                    SizedBox(
                      width: 120, // Adjust width as needed
                      height: 40, // Adjust height as needed
                      child: TextField(
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: InputDecoration(
                          hintText: 'Enter reps', // Keeps text inside the field
                          floatingLabelBehavior: FloatingLabelBehavior.never, // Prevents label from moving up
                          border: OutlineInputBorder(), // Adds a border for better visibility
                          contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 10), // Reduces internal padding
                        ),
                        style: TextStyle(fontSize: 14), // Smaller text size
                        onChanged: (value) {
                          setState(() {
                            _baseRepsConcat[setNumber - 1] = int.tryParse(value) ?? 0;
                          });
                        },
                      ),
                    ),

                  const SizedBox(height: 15,),
                  ElevatedButton(
                    onPressed: () {
                      double burnedCalories = _calculateCurrentSetCalories(setNumber - 1);
        
                      // Save the burned calories in Firestore
                      _saveTotalBurnCalRep(setNumber - 1);
        
                      // Add to the local list of TotalBurnCalRep
                      setState(() {
                        _totalBurnCalRep.add(burnedCalories);
                      });
        
                      print("TotalBurnCalRep updated: $_totalBurnCalRep");
        
                      _skipForward();
                    },
        
        
                    child: Text('Confirm & Proceed'),
                  ),
                ],
              ),
        
          ],
        ),
      ),
    );
  }
  double _calculateCurrentSetCalories(int setIndex) {
    if (widget.isRepBased) {
      return (_baseRepsConcat[setIndex] * (widget.exercise['burnCalperRep']?.toDouble() ?? 0.0)).toDouble();
    }
    return (widget.setValues[setIndex] * (widget.exercise['burnCalperSec']?.toDouble() ?? 0.0)).toDouble();
  }
}

enum StepType { set, rest }

class Step {
  final StepType type;
  final int duration;

  Step({required this.type, required this.duration});
}