import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/pages/Main_Pages/Exercises_Page.dart';
import 'package:exercai_mobile/pages/realtime_2.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:flutter/material.dart';

class AgeSelectorScreen extends StatefulWidget {
  const AgeSelectorScreen({super.key});

  @override
  State<AgeSelectorScreen> createState() => _AgeSelectorScreenState();
}

class _AgeSelectorScreenState extends State<AgeSelectorScreen> {
  FixedExtentScrollController _controller = FixedExtentScrollController();
  int selectedAge = 1; // Default age

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => Trypage()),
            );
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            largeGap,
            Center(
              child: Column(
                children: [
                  Text(
                    'How many reps?',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    'This helps shape your workout.',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ),
            ),

            Expanded(
              child: Center(
                child: ListWheelScrollView.useDelegate(
                  controller: _controller, // ✅ Use the controller
                  itemExtent: 100,
                  diameterRatio: 1.5,
                  physics: FixedExtentScrollPhysics(),
                  overAndUnderCenterOpacity: 0.3,
                  onSelectedItemChanged: (index) {
                    setState(() {
                      selectedAge = index + 1; // ✅ Get the center value
                    });
                  },
                  childDelegate: ListWheelChildBuilderDelegate(
                    builder: (context, index) {
                      return Center(
                        child: Text(
                          '${1 + index}',
                          style: TextStyle(
                            fontSize:
                                index == _controller.selectedItem ? 28 : 22,
                            color:
                                index == _controller.selectedItem
                                    ? AppColor.shadow
                                    : Colors.black,
                            fontWeight:
                                index == _controller.selectedItem
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                          ),
                        ),
                      );
                    },
                    childCount: 100,
                  ),
                ),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              onPressed: () {
                // ✅ Now you can use the selectedAge value
                print("Selected Age: $selectedAge");
                repsWants = selectedAge;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => MyHomePage()),
                );
              },
              child: Text(
                'Next',
                style: TextStyle(
                  color: const Color.fromARGB(255, 255, 255, 255),
                  fontWeight: FontWeight.bold,
                  fontSize: 19,
                ),
              ),
            ),
            SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
