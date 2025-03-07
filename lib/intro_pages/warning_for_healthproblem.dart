import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';

class WarningPage extends StatefulWidget {
  @override
  _WarningPageState createState() => _WarningPageState();
}

class _WarningPageState extends State<WarningPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/welcomescreen.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SingleChildScrollView( // Prevents overflow on smaller screens
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.all(30),
                decoration: BoxDecoration(
                  border: Border.all(width: 2, color: Colors.yellow),
                  color: Colors.yellow.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12), // Rounded corners for better UI
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Wrap content properly
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.info,
                      size: 100,
                      color: Colors.yellow,
                    ),
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(8), // Rounded corners
                      ),
                      child: Column(
                        children: [
                          Text(
                            "This app is not intended for individuals with medical conditions or physical limitations related to exercise. Please consult a healthcare professional before starting any exercise routine.",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18, // Slightly reduced for better fit
                              color: AppColor.textwhite,
                            ),
                          ),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: () {
                              // Add navigation logic here
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColor.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              'Proceed',
                              style: TextStyle(
                                color: AppColor.textwhite,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
