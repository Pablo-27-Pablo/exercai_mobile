import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';

class SimpleEmailPage extends StatelessWidget {
  const SimpleEmailPage({Key? key}) : super(key: key);

  Future<void> _sendEmail(BuildContext context) async {
    // Get the currently authenticated user
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User not logged in or email not available.')),
      );
      return;
    }

    final userEmail = user.email!;
    // Prepopulate the subject and body using the user's email
    final subject = Uri.encodeComponent('Message from $userEmail');
    final body = Uri.encodeComponent('Hello, this message is sent from my Flutter app.');
    // Set your target email here
    final targetEmail = 'targetemail@gmail.com';

    final mailUrl = 'mailto:$targetEmail?subject=$subject&body=$body';

    // Check if the device can open the URL
    if (await canLaunch(mailUrl)) {
      await launch(mailUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the email app.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Email'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _sendEmail(context),
          child: const Text('Send Email'),
        ),
      ),
    );
  }
}
