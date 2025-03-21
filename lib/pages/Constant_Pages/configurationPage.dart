import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:exercai_mobile/utils/constant.dart';
import 'package:exercai_mobile/utils/constant.dart';
import '../../utils/constant.dart';

class ConfigurationPage extends StatefulWidget {
  const ConfigurationPage({super.key});

  @override
  State<ConfigurationPage> createState() => _ConfigurationPageState();
}

class _ConfigurationPageState extends State<ConfigurationPage> {
  Formula() {
    for (int i = 0; i < exercises.length; i++) {
      if (exercises[i]["name"] == ExerciseName) {
        print("Exercise found: ${exercises[i]}");
        double formula =
            (((exercises[i]["MET"]).toDouble() * weight * raise.toDouble()) /
                1000);
        totalCaloriesBurn = totalCaloriesBurn + formula;
        totalCaloriesBurnDatabase =
            (peopleBox.get("finalcoloriesburn")).toDouble();
        double total = totalCaloriesBurn + totalCaloriesBurnDatabase;
        peopleBox.put("finalcoloriesburn", total);
        print(peopleBox.get("finalcoloriesburn"));

        print(
          "         $ExerciseName                " +
              totalCaloriesBurn.toString(),
        );
        print("                         " + totalCaloriesBurn.toString());
        print("                         " + totalCaloriesBurn.toString());
        print("                         " + totalCaloriesBurn.toString());
        print("                         " + totalCaloriesBurn.toString());
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            //print("calories: " + peopleBox.get('finalcoloriesburn').toString());
            peopleBox.get('camera', defaultValue: true);
            peopleBox.put('camera', true);
            print(peopleBox.get('camera', defaultValue: true));
          },
          icon: Icon(Icons.abc_rounded),
        ),
      ),
    );
  }
}
