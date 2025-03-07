import 'package:flutter/material.dart';

//display error message to the user

void displayMessagetoUser(String message, BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16), // Rounded corners
      ),
      title: Row(
        children: [
          Icon(Icons.info, color: Colors.blue), // Info icon
          SizedBox(width: 10),
          Text(
            "Notice",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      content: Text(
        message,
        style: TextStyle(fontSize: 16),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // Close the dialog
          },
          child: Text(
            "OK",
            style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    ),
  );
}
