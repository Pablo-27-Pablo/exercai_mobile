import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AnotherPage extends StatefulWidget {
  @override
  _AnotherPageState createState() => _AnotherPageState();
}

class _AnotherPageState extends State<AnotherPage> {
  List<String> selectedInjuries = [];

  @override
  void initState() {
    super.initState();
    _loadSelectedInjuries();
  }

  Future<void> _loadSelectedInjuries() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedInjuries = prefs.getStringList('selectedInjuries') ?? [];
    });
    print(selectedInjuries);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Selected Injuries"),
        leading: IconButton(
          onPressed: () {
            // selectedInjuries.remove("chest");
            selectedInjuries.addAll(["giveway", "asdf", "asdf"]);
            print(selectedInjuries[1]);
            for (String injury in selectedInjuries) {
              if (injury == "chest") {
                print("Chest injury is selected!");
                // Stop looping after finding it (optional)
              }if (injury == "giveway") {
                print("giveway injury is selected!");
                 // Stop looping after finding it (optional)
              }
            }
          },
          icon: Icon(Icons.add_ic_call_outlined),
        ),
      ),
      body: Center(
        child: Text(
          "Selected Injuries: ${selectedInjuries.join(", ")}",
          style: TextStyle(fontSize: 18),
        ),
      ),
    );
  }
}
