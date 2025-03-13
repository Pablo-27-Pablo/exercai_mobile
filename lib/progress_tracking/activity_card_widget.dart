import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';

class ActivityCard extends StatelessWidget {
  final String title;
  //final String exeID;
  final String duration;
  final String timeanddate;
  final double burnCalories; // New field

  const ActivityCard({
    required this.title,
    //required this.exeID,
    required this.duration,
    required this.timeanddate,
    required this.burnCalories,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColor.textwhite.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_run, color: AppColor.primary, size: 30),
          SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title
                    .toLowerCase()
                    .split(' ')
                    .map((word) => word.isNotEmpty
                    ? '${word[0].toUpperCase()}${word.substring(1)}'
                    : '')
                    .join(' '),
                style: TextStyle(color: AppColor.textwhite, fontSize: 16),
              ),
              Text(
                '$timeanddate',
                style: TextStyle(color: AppColor.yellowtext, fontSize: 14),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration: $duration',
                    style: TextStyle(
                      color: AppColor.yellowtext,
                      fontSize: 14,
                    ),
                  ),
/*                  Text(
                    '$exeID',
                    style: TextStyle(
                      color: AppColor.yellowtext,
                      fontSize: 14,
                    ),
                  ),*/
                  Text(
                    'Calories: ${burnCalories.toStringAsFixed(2)} kcal',
                    style: TextStyle(
                      color: AppColor.yellowtext,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}