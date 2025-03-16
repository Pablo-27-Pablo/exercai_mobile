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
        borderRadius: BorderRadius.circular(15),
        gradient: LinearGradient(
          colors: [AppColor.buttonPrimary, AppColor.primary.withOpacity(0.85)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.directions_run, color: AppColor.supersolidPrimary, size: 30),
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
                style: TextStyle(color: AppColor.backgroundWhite, fontSize: 16,fontWeight: FontWeight.bold),
              ),
              Text(
                '$timeanddate',
                style: TextStyle(color: AppColor.backgroundWhite, fontSize: 14),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Duration: $duration',
                    style: TextStyle(
                      color: AppColor.backgroundWhite,
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
                      color: AppColor.backgroundWhite,
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