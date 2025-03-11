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
    for (int i = 0; i < exercises2.length; i++) {
      if (exercises2[i]["name"] == ExerciseName) {
        print("Exercise found: ${exercises2[i]}");
        double formula =
            (((exercises2[i]["MET"]).toDouble() * 85 * raise.toDouble()) /
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
            raise = 50;
            //print("calories: " + peopleBox.get('finalcoloriesburn').toString());
            peopleBox.put('squat', 97);

            Formula();
          },
          icon: Icon(Icons.abc_rounded),
        ),
      ),
    );
  }
}
