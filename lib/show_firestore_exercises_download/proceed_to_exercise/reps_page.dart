import 'package:exercai_mobile/show_firestore_exercises_download/show_with_reps_kcals/show_reps_kcal.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/main.dart';
import '../start_timer_exercise/timer_reps_exercise.dart';

class RepsPage extends StatefulWidget {
  final Map<String, dynamic> exercise;

  const RepsPage({Key? key, required this.exercise}) : super(key: key);

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

    if (isRepBased && widget.exercise['baseRepsConcat'] != null) {
      setValues = List<int>.from(widget.exercise['baseRepsConcat']);
    } else if (!isRepBased && widget.exercise['baseSecConcat'] != null) {
      setValues = List<int>.from(widget.exercise['baseSecConcat']);
    } else {
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

  Future<void> _saveToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    Map<String, dynamic> updateData = {};
    double totalCalories = 0;

    if (isRepBased) {
      totalCalories = setValues.fold(
          0.0,
              (sum, reps) =>
          sum + (reps * (widget.exercise['burnCalperRep']?.toDouble() ?? 0.0)));
      final totalReps = setValues.fold(0, (sum, reps) => sum + reps);
      updateData['baseReps'] = totalReps ~/ setCount;
      updateData['baseRepsConcat'] = setValues;
      updateData['baseSetsReps'] = setCount;
    } else {
      int totalSeconds = setValues.fold(0, (sum, secs) => sum + secs);
      totalCalories = (totalSeconds *
          (widget.exercise['burnCalperSec']?.toDouble() ?? 0.0))
          .toDouble();
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

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 2,
          centerTitle: true,
          iconTheme: const IconThemeData(color: Colors.black),
          title: Text(
            (widget.exercise['name']?.toString().toUpperCase() ?? 'UNNAMED EXERCISE'),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ShowRepsKcal(exercise: widget.exercise,))),
          ),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // List of set rows in a modern Card design
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: setCount,
                itemBuilder: (context, index) => _buildSetRow(index),
              ),
              const SizedBox(height: 20),
              // Rest Time Input Card
              _buildRestTimeInput(),
              const SizedBox(height: 20),
              // Save Button Card
              _buildSaveButton(),
              const SizedBox(height: 20),
            ],
          ),
        ),
        // Fixed Start Exercise Button at the bottom
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _buildStartButton(),
        ),
      ),
    );
  }

  Widget _buildSetRow(int index) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Set number and input field
            Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: index == 0 ? AppColor.primary : Colors.grey.shade400,
                  child: Text(
                    (index + 1).toString(),
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 80,
                  child: TextFormField(
                    initialValue: setValues[index].toString(),
                    keyboardType: TextInputType.number,
                    onChanged: isEditable
                        ? (value) {
                      int newValue = int.tryParse(value) ?? setValues[index];
                      setState(() => setValues[index] = newValue);
                    }
                        : null,
                    enabled: isEditable,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(vertical: 4),
                      border: OutlineInputBorder(),
                    ),
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  isRepBased ? "Reps" : "Seconds",
                  style: const TextStyle(fontSize: 18, color: Colors.grey),
                ),
              ],
            ),
            // Add/Remove buttons (only on the last set row)
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
      ),
    );
  }

  Widget _buildRestTimeInput() {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        child: Row(
          children: [
            const Icon(Icons.timer, color: Colors.grey),
            const SizedBox(width: 10),
            const Text('Rest Time (seconds): ', style: TextStyle(fontSize: 16)),
            Expanded(
              child: TextFormField(
                initialValue: restTime.toString(),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  int newValue = int.tryParse(value) ?? restTime;
                  setState(() => restTime = newValue);
                },
                decoration: const InputDecoration(
                  contentPadding: EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                  border: OutlineInputBorder(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          if (isEditable) await _saveToFirestore();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.lightPrimary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        child: Text(
          isEditable ? 'Save Changes' : 'View Progress',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => TimerRepsExercise(
                exercise: widget.exercise,
                setValues: setValues,
                isRepBased: isRepBased,
                restTime: restTime,
              ),
            ),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColor.moresolidPrimary.withOpacity(0.8),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(50),
          ),
          elevation: 5,
        ),
        child: const Text(
          'Start Exercise',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
