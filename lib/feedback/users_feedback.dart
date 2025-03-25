import 'package:exercai_mobile/main.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailSenderPage extends StatelessWidget {
  const EmailSenderPage({Key? key}) : super(key: key);

  // Corrected target email address
  final String targetEmail = 'exercaimobile@gmail.com';

  Future<void> _sendEmail(BuildContext context) async {
    // Predefined subject and empty body (customize as needed)
    final subject = Uri.encodeComponent('Feedback from ExercAI');
    final body = Uri.encodeComponent('');
    final mailUrl = Uri.parse('mailto:$targetEmail?subject=$subject&body=$body');

    if (await canLaunchUrl(mailUrl)) {
      await launchUrl(mailUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the email app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Minimalistic background
      appBar: AppBar(
        title: const Text(
          'Users Feedback',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios),
        ),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: const [
                  Text(
                    'Any suggestions on how to improve ExercAI?\nMessage Us',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 20,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '( This will redirect to your gmail app.)',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => _sendEmail(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.moresolidPrimary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Send Email',
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
