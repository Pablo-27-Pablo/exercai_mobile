import 'package:exercai_mobile/show_firestore_exercises_download/proceed_to_exercise/reps_page.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:exercai_mobile/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import '../../workout_complete/workoutcomplete.dart';
import 'package:exercai_mobile/different_exercises/bodypart_exercises/configurations/reps_page_allExercises.dart';

// 1. Import audioplayers package.
import 'package:audioplayers/audioplayers.dart';

enum StepType { set, rest }

class Step {
  final StepType type;
  final int duration;
  Step({required this.type, required this.duration});
}

class TimerRepsExercise extends StatefulWidget {
  final Map<String, dynamic> exercise;
  final List<int> setValues;
  final bool isRepBased;
  final int restTime;

  const TimerRepsExercise({
    Key? key,
    required this.exercise,
    required this.setValues,
    required this.isRepBased,
    required this.restTime,
  }) : super(key: key);

  @override
  State<TimerRepsExercise> createState() => _TimerRepsExerciseState();
}

class _TimerRepsExerciseState extends State<TimerRepsExercise> {
  DateTime? _setStartTime; //Dinagdag para sa Time based Compute
  List<int> _elapsedSetTimes = [];  // Stores elapsed seconds for each set //Dinagdag para sa Time based Compute

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

  // 2. Create an AudioPlayer instance and track the playing state.
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isMusicPlaying = false;

  @override
  void initState() {
    super.initState();
    _currentStepIndex = 0;
    _steps = _createSteps();
    _secondsRemaining = _steps[_currentStepIndex].duration;
    _currentCount = 0;
    _baseRepsConcat = List.filled(widget.setValues.length, 0);

    // Initialize _elapsedSetTimes with 0s for each set.
    _elapsedSetTimes = List.filled(widget.setValues.length, 0);

    // 3. Set the AudioPlayer to loop the music.
    _audioPlayer.setReleaseMode(ReleaseMode.loop);

    //OLD ONE DATI TO PAG GUSTO IBALIK SA DATI COMPUTATION
    /*_loadTotalExerciseTime().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _startTimer();
      });
    });*/

    //Dinagdag para sa Time based Compute
    _loadTotalExerciseTime().then((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // If the first non-initial step is a set, record its start time.
        if (_steps.length > 1 && _steps[1].type == StepType.set) {
          _setStartTime = DateTime.now();
        }
        _startTimer();
      });
    });

  }

  //Dinagdag para sa Time based Compute
  // When skipping forward (or confirming during a rest period),
  // if the previous step was a time-based set, record the elapsed time.
  void _recordElapsedTimeForSet() {
    // Ensure we are not in the initial rest period.
    if (_currentStepIndex > 0 && !widget.isRepBased) {
      // Calculate the set index; both for set or rest step, it is (_currentStepIndex - 1) ~/ 2.
      int setIndex = ((_currentStepIndex - 1) ~/ 2);
      if (_setStartTime != null) {
        int elapsed = DateTime.now().difference(_setStartTime!).inSeconds;
        _elapsedSetTimes[setIndex] = elapsed;
      }
    }
  }


  // 4. Toggle music playback.
  void _toggleMusic() async {
    if (_isMusicPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play(AssetSource('audio/musicbackground.mp3'));
    }
    setState(() {
      _isMusicPlaying = !_isMusicPlaying;
    });
  }

  // Updated _createSteps(): add an initial rest period ("Get Ready") before the first set.
  List<Step> _createSteps() {
    List<Step> steps = [];
    // Initial rest period before the first set
    steps.add(Step(type: StepType.rest, duration: widget.restTime));
    for (int i = 0; i < widget.setValues.length; i++) {
      steps.add(Step(type: StepType.set, duration: widget.setValues[i]));
      steps.add(Step(type: StepType.rest, duration: widget.restTime));
    }
    return steps;
  }

  String _getDocKey() {
    return widget.exercise['name'].toString();
  }

  Future<void> _saveTotalBurnCalRep(int setIndex) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    double setCalories = (_baseRepsConcat[setIndex]).toDouble() *
        (widget.exercise['burnCalperRep']?.toDouble() ?? 0.0);
    DocumentReference exerciseRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .collection('UserExercises')
        .doc(_getDocKey());
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(exerciseRef);
      List<dynamic> totalBurnCalRep = [];
      if (!snapshot.exists ||
          snapshot.data() == null ||
          !(snapshot.data() as Map<String, dynamic>)
              .containsKey('TotalBurnCalRep')) {
        transaction.set(
          exerciseRef,
          {
            'TotalBurnCalRep': [],
            'FinalTotalBurnCalRep': 0.0,
            'burnCalperRep': widget.exercise['burnCalperRep']?.toDouble() ?? 0.0,
            'lastUpdated': FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } else {
        totalBurnCalRep = List.from(
            (snapshot.data() as Map<String, dynamic>)['TotalBurnCalRep'] ?? []);
      }
      totalBurnCalRep.add(setCalories);
      transaction.update(exerciseRef, {
        'TotalBurnCalRep': totalBurnCalRep,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    });
    await _updateFinalTotalBurnCalRep();
  }

  Future<void> _updateFinalTotalBurnCalRep() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    DocumentReference exerciseRef = FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .collection('UserExercises')
        .doc(_getDocKey());
    await FirebaseFirestore.instance.runTransaction((transaction) async {
      DocumentSnapshot snapshot = await transaction.get(exerciseRef);
      if (snapshot.exists) {
        List<dynamic> totalBurnCalRep =
            snapshot['TotalBurnCalRep'] as List<dynamic>? ?? [];
        double finalTotalBurnCalRep = totalBurnCalRep.fold(
            0.0, (sum, val) => sum + (val as num).toDouble());
        transaction.update(exerciseRef, {
          'FinalTotalBurnCalRep': finalTotalBurnCalRep,
          'lastUpdated': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  // Updated to use the correct collection name "UserExerciseTimes"
  Future<void> _loadTotalExerciseTime() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .collection('UserExerciseTimes')
        .doc(_getDocKey())
        .get();
    if (doc.exists) {
      setState(() {
        _totalExerciseTime = doc['totalExerciseTime'] ?? 0;
        _initialDataLoaded = true;
      });
    }
  }

  // Updated to use the correct collection name "UserExerciseTimes"
  Future<void> _saveTotalExerciseTime() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    double burnedCalories = 0.0;
    if (widget.isRepBased) {
      burnedCalories =
          _totalBurnCalRep.fold(0.0, (sum, cal) => sum + (cal as double));
    } else {
      DocumentReference exerciseRef = FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .collection('UserExercises')
          .doc(widget.exercise['name'].toString());
      DocumentSnapshot snapshot = await exerciseRef.get();
      burnedCalories = snapshot.exists && snapshot.data() != null
          ? (snapshot.data() as Map<String, dynamic>)['TotalCalBurnSec']?.toDouble() ?? 0.0
          : 0.0;
    }
    await FirebaseFirestore.instance
        .collection('Users')
        .doc(user.email)
        .collection('UserExerciseTimes')
        .doc(_getDocKey())
        .set({
      'exerciseId': widget.exercise['id'],
      'exerciseName': widget.exercise['name'],
      'totalExerciseTime': _totalExerciseTime,
      'burnCalories': burnedCalories,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    if (!widget.isRepBased) {
      double burnCalPerSec = widget.exercise['burnCalperSec']?.toDouble() ?? 0.0;
      double totalCalBurnSec = _totalExerciseTime * burnCalPerSec;
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .collection('UserExercises')
          .doc(_getDocKey())
          .update({'TotalCalBurnSec': totalCalBurnSec});
    }
  }

  void _startTimer() {
    _isRunning = true;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        final currentStep = _steps[_currentStepIndex];
        if (_isRunning && currentStep.type == StepType.set) {
          _totalExerciseTime++;
          _saveTotalExerciseTime();
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
    //Dinagdag para sa Time based Compute
    // Before transitioning, if the current step was a time-based set, record its elapsed time.
    if (_steps[_currentStepIndex].type == StepType.set && !widget.isRepBased) {
      _recordElapsedTimeForSet();
    }

    _stopTimer();
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _secondsRemaining = _steps[_currentStepIndex].duration;
        _currentCount = 0;
      });

      //Dinagdag para sa Time based Compute
      // If the new step is a set, record its start time.
      if (_steps[_currentStepIndex].type == StepType.set && !widget.isRepBased) {
        _setStartTime = DateTime.now();
      }

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
          .doc(_getDocKey())
          .update({
        'completed': true,
        'lastCompleted': FieldValue.serverTimestamp()
      });
    } catch (e) {
      print('Error marking exercise as completed: $e');
    }
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _secondsRemaining = _steps[_currentStepIndex].duration;
      _currentCount = 0;
    });
  }

  void _skipForward() {
    //Dinagdag para sa Time based Compute
    // If skipping during a set and the exercise is time-based, record elapsed time.
    if (_steps[_currentStepIndex].type == StepType.set && !widget.isRepBased) {
      _recordElapsedTimeForSet();
    }

    _stopTimer();
    _saveTotalExerciseTime();
    if (_currentStepIndex < _steps.length - 1) {
      setState(() {
        _currentStepIndex++;
        _secondsRemaining = _steps[_currentStepIndex].duration;
        _currentCount = 0;
      });

      //Dinagdag para sa Time based Compute
      // If the new step is a set and time-based, record its start time.
      if (_steps[_currentStepIndex].type == StepType.set && !widget.isRepBased) {
        _setStartTime = DateTime.now();
      }

      _startTimer();
    } else {
      _markExerciseAsCompleted();
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteWorkout(),
        ),
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

// OLD calculation function.
  /*double _calculateCurrentSetCalories(int setIndex) {
    if (widget.isRepBased) {
      return (_baseRepsConcat[setIndex] *
          (widget.exercise['burnCalperRep']?.toDouble() ?? 0.0))
          .toDouble();
    }
    return (widget.setValues[setIndex] *
        (widget.exercise['burnCalperSec']?.toDouble() ?? 0.0))
        .toDouble();
  }*/

  //Dinagdag para sa Time based Compute
  // Updated calculation function.
  double _calculateCurrentSetCalories(int setIndex) {
    if (widget.isRepBased) {
      return (_baseRepsConcat[setIndex] *
          (widget.exercise['burnCalperRep']?.toDouble() ?? 0.0)).toDouble();
    } else {
      // Use the elapsed time if available; if not, fallback to the full set duration.
      int elapsedTime = _elapsedSetTimes[setIndex] > 0
          ? _elapsedSetTimes[setIndex]
          : widget.setValues[setIndex];
      return (elapsedTime * (widget.exercise['burnCalperSec']?.toDouble() ?? 0.0)).toDouble();
    }
  }

  @override
  void dispose() {
    if (_initialDataLoaded) {
      _saveTotalExerciseTime();
    }
    _timer?.cancel();
    // 5. Stop the music when disposing.
    _audioPlayer.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentStep = _steps[_currentStepIndex];
    // Check if we're in the initial rest period (i.e. "Get Ready")
    bool isInitialRest = _currentStepIndex == 0 && currentStep.type == StepType.rest;

    // Calculate set number only when not in the initial rest period.
    int setNumber = 0;
    if (!isInitialRest) {
      if (currentStep.type == StepType.set) {
        setNumber = ((_currentStepIndex - 1) ~/ 2) + 1;
      } else {
        setNumber = _currentStepIndex ~/ 2;
      }
    }

    final progress = currentStep.type == StepType.set && widget.isRepBased
        ? 0.0
        : 1 - (_secondsRemaining / currentStep.duration);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        // 6. Add the AppBar with the music icon button in actions.
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          title: Text(
            (widget.exercise['name'] ?? 'Exercise Timer').toString().toUpperCase(),
            style: const TextStyle(color: AppColor.supersolidPrimary),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: AppColor.supersolidPrimary),
            onPressed: () async {
              bool? exitConfirmed = await showDialog<bool>(
                context: context,
                builder: (context) => Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  elevation: 10,
                  backgroundColor: Colors.white,
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                "Exit Workout",
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: AppColor.supersolidPrimary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Are you sure you want to exit?\nDon't worry, your recent progress will be saved.",
                          style: TextStyle(fontSize: 18, color: Colors.black87),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.grey[300],
                                foregroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(false),
                              child: Text("Cancel", style: TextStyle(fontSize: 16)),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.moresolidPrimary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: () => Navigator.of(context).pop(true),
                              child: Text("Exit", style: TextStyle(fontSize: 16)),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              );
              if (exitConfirmed == true) {
                String bodyPart = widget.exercise['bodyPart']?.toString().toLowerCase() ?? 'neck';
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RepsPage(exercise: widget.exercise),
                  ),
                );
              }
            },
          ),
          actions: [
            // 7. Music toggle icon button.
            IconButton(
              icon: Icon(_isMusicPlaying ? Icons.music_note : Icons.music_off,size: 35,),
              color: _isMusicPlaying ? AppColor.supersolidPrimary : AppColor.lightPrimary,
              onPressed: _toggleMusic,
            ),
          ],
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Display exercise title and step details.
                Text(
                  isInitialRest
                      ? 'Get Ready'
                      : currentStep.type == StepType.set
                      ? 'Set $setNumber of ${widget.setValues.length}'
                      : 'Rest $setNumber',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentStep.type == StepType.set
                      ? widget.isRepBased
                      ? 'Timer: ${_formatTime(_currentCount)}\n${currentStep.duration} Reps'
                      : 'Timer: ${_formatTime(_secondsRemaining)}'    //'$_secondsRemaining Seconds'
                      : 'Rest: $_secondsRemaining Seconds',
                  style: const TextStyle(fontSize: 18, color: Colors.black54),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                // Circular progress indicator with GIF inside.
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 220,
                      height: 220,
                      child: CircularProgressIndicator(
                        value: progress.clamp(0.0, 1.0),
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[300],
                        valueColor: AlwaysStoppedAnimation<Color>(
                          currentStep.type == StepType.set && widget.isRepBased
                              ? Colors.grey
                              : Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                    ClipOval(
                      child: Image.asset(
                        widget.exercise['gifPath'] ?? 'assets/exercaiGif/fallback.gif',
                        width: 180,
                        height: 180,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.error_outline, size: 100),
                      ),
                    ),
                    Positioned(
                      bottom: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          currentStep.type == StepType.set
                              ? (widget.isRepBased ? _formatTime(_currentCount) : '${_formatTime(_secondsRemaining)}')
                              :  '${_formatTime(_secondsRemaining)}',          //'$_secondsRemaining',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                // Control buttons row.
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white70,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.fast_rewind),
                        iconSize: 40,
                        onPressed: _currentStepIndex > 0 ? _rewindStep : null,
                        color: Theme.of(context).primaryColor,
                      ),
                      IconButton(
                        icon: const Icon(Icons.replay),
                        iconSize: 40,
                        onPressed: _resetTimer,
                        color: Theme.of(context).primaryColor,
                      ),
                      IconButton(
                        icon: Icon(_isRunning ? Icons.pause : Icons.play_arrow),
                        iconSize: 50,
                        onPressed: () => _isRunning ? _stopTimer() : _startTimer(),
                        color: Theme.of(context).primaryColor,
                      ),
                      IconButton(
                        icon: const Icon(Icons.double_arrow),
                        iconSize: 40,
                        onPressed: _skipForward,
                        color: Theme.of(context).primaryColor,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                // If in rest period (and not the initial "Get Ready"), display calorie info and, if rep-based, rep selector.
                if (currentStep.type == StepType.rest && _currentStepIndex > 0)
                  Column(
                    children: [
                      Text(
                        'Calories Burnt in Set: ${_calculateCurrentSetCalories(setNumber - 1).toStringAsFixed(2)} kcal',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 15),
                      if (widget.isRepBased)
                        Column(
                          children: [
                            const Text(
                              'Select Reps',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(height: 8),
                            SizedBox(
                              height: 50,
                              width: 300,
                              child: RotatedBox(
                                quarterTurns: 1,
                                child: CupertinoPicker(
                                  scrollController: FixedExtentScrollController(
                                    initialItem: 99 - _baseRepsConcat[setNumber - 1],
                                  ),
                                  itemExtent: 40,
                                  onSelectedItemChanged: (int index) {
                                    setState(() {
                                      _baseRepsConcat[setNumber - 1] = 99 - index;
                                    });
                                  },
                                  children: List<Widget>.generate(
                                    100,
                                        (index) {
                                      final displayNumber = 99 - index;
                                      return RotatedBox(
                                        quarterTurns: -1,
                                        child: Center(
                                          child: Text(
                                            "$displayNumber",
                                            style: const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          double burnedCalories = _calculateCurrentSetCalories(setNumber - 1);
                          _saveTotalBurnCalRep(setNumber - 1);
                          setState(() {
                            _totalBurnCalRep.add(burnedCalories);
                          });
                          _skipForward();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text(
                          'Confirm & Proceed',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
