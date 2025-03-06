import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/main.dart';
import '../start_timer_exercise/timer_reps_exercise.dart';

class RepsPage extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const RepsPage({super.key, required this.exercise});

  @override
  State<RepsPage> createState() => _RepsPageState();
}

class _RepsPageState extends State<RepsPage> {
  late bool isRepBased;
  late int setCount;
  List<int> setValues = [];
  bool isEditable = true;
  int restTime = 30;

  @override
  void initState() {
    super.initState();
    isRepBased = widget.exercise['baseSetsReps'] != null &&
        widget.exercise['baseReps'] != null;

    setCount = isRepBased
        ? widget.exercise['baseSetsReps'] ?? 1
        : widget.exercise['baseSetsSecs'] ?? 1;

    // Initialize setValues with baseRepsConcat or baseSecConcat if they exist
    if (isRepBased && widget.exercise['baseRepsConcat'] != null) {
      setValues = List<int>.from(widget.exercise['baseRepsConcat']);
    } else if (!isRepBased && widget.exercise['baseSecConcat'] != null) {
      setValues = List<int>.from(widget.exercise['baseSecConcat']);
    } else {
      // Fallback to baseReps or baseSecs if baseRepsConcat/baseSecConcat is null
      int initialValue = isRepBased
          ? widget.exercise['baseReps'] ?? 10
          : widget.exercise['baseSecs'] ?? 30;
      setValues = List.generate(setCount, (_) => initialValue);
    }

    restTime = widget.exercise['restTime'] ?? 30;
  }

  void _addSet() {
    setState(() {
      setCount++;
      setValues.add(isRepBased ? 10 : 30);
    });
  }

  void _removeSet() {
    if (setCount > 1) {
      setState(() {
        setCount--;
        setValues.removeLast();
      });
    }
  }

// ... Keep all existing code above ...

  Future<void> _saveToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, dynamic> updateData = {};
    double totalCalories = 0;

    // CALORIE CALCULATION LOGIC
    if (isRepBased) {
      // Calculate total calories based on actual reps completed
      totalCalories = setValues.fold(0.0, (sum, reps) =>
      sum + (reps * (widget.exercise['burnCalperRep']?.toDouble() ?? 0.0)));

          // Calculate average reps per set
          final totalReps = setValues.fold(0, (sum, reps) => sum + reps);
      updateData['baseReps'] = totalReps ~/ setCount;
      updateData['baseRepsConcat'] = setValues;
      updateData['baseSetsReps'] = setCount;

    } else {
      // Calculate total calories based on actual time spent
      int totalSeconds = setValues.fold(0, (sum, secs) => sum + secs);
      totalCalories = (totalSeconds * (widget.exercise['burnCalperSec']?.toDouble() ?? 0.0)).toDouble();

      // Calculate average seconds per set
      updateData['baseSecs'] = totalSeconds ~/ setCount;
      updateData['baseSecConcat'] = setValues;
      updateData['baseSetsSecs'] = setCount;
    }

    updateData.addAll({
      'baseCalories': totalCalories,
      'restTime': restTime,
    });

    try {
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(user.email)
          .collection('UserExercises')
          .doc(widget.exercise['name'].toString())
          .update(updateData);

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Progress saved successfully!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving progress: $e')));
    }
  }

// ... Keep all existing code below ...



  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.exercise['name']),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16.0),
                itemCount: setCount + 2,
                itemBuilder: (context, index) {
                  if (index < setCount) {
                    return _buildSetRow(index);
                  } else if (index == setCount) {
                    return _buildRestTimeInput();
                  } else {
                    return _buildSaveButton();
                  }
                },
              ),
            ),
            _buildStartButton(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSetRow(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: index == 0 ? Colors.blue : Colors.grey,
                child: Text(
                  (index + 1).toString(),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              SizedBox(
                width: 60,
                child: TextFormField(
                  initialValue: setValues[index].toString(),
                  keyboardType: TextInputType.number,
                  onChanged: isEditable ? (value) {
                    int newValue = int.tryParse(value) ?? setValues[index];
                    setState(() => setValues[index] = newValue);
                  } : null,
                  enabled: isEditable,
                  decoration: const InputDecoration(
                    border: UnderlineInputBorder(),
                    contentPadding: EdgeInsets.zero,
                    isDense: true,
                  ),
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
              const SizedBox(width: 5),
              Text(
                isRepBased ? "Reps" : "Seconds",
                style: const TextStyle(fontSize: 18, color: Colors.grey),
              ),
            ],
          ),
          if (index == setCount - 1)
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.add_circle, color: Colors.green),
                  onPressed: isEditable ? _addSet : null,
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle, color: Colors.red),
                  onPressed: isEditable ? _removeSet : null,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRestTimeInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        children: [
          const Text('Rest Time (seconds): ', style: TextStyle(fontSize: 16)),
          SizedBox(
            width: 100,
            child: TextFormField(
              initialValue: restTime.toString(),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                int newValue = int.tryParse(value) ?? restTime;
                setState(() => restTime = newValue);
              },
              decoration: const InputDecoration(
                border: UnderlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Center(
      child: ElevatedButton(
        onPressed: () async {
          if (isEditable) await _saveToFirestore();
        },
        child: Text(isEditable ? 'Save Changes' : 'View Progress'),
      ),
    );
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(
            builder: (context) => TimerRepsExercise(
              exercise: widget.exercise,
              setValues: setValues,
              isRepBased: isRepBased,
              restTime: restTime,
            )
        ));
      },
      child: Container(
        height: 55,
        width: 200,
        decoration: BoxDecoration(
          color: AppColor.buttonPrimary.withOpacity(0.7),
          borderRadius: BorderRadius.circular(50),
          border: Border.all(width: 2, color: AppColor.buttonSecondary),
          boxShadow: [
            BoxShadow(
              color: AppColor.buttonSecondary.withOpacity(0.7),
              blurRadius: 90,
              spreadRadius: 0.1,
            ),
          ],
        ),
        child: Center(
          child: Text(
            'Start Exercise',
            style: TextStyle(
              color: AppColor.textwhite,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}