import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmailSenderPage extends StatefulWidget {
  const EmailSenderPage({Key? key}) : super(key: key);

  @override
  _EmailSenderPageState createState() => _EmailSenderPageState();
}

class _EmailSenderPageState extends State<EmailSenderPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  // Set the target email address here
  final String targetEmail = 'riveramiko5@gmail.com';

  Future<void> _sendEmail() async {
    final senderEmail = _emailController.text.trim();
    final message = _messageController.text.trim();

    if (senderEmail.isEmpty || message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter both your email and a message.'),
        ),
      );
      return;
    }

    final subject = Uri.encodeComponent('Message from $senderEmail');
    final body = Uri.encodeComponent(message);
    final mailUrl = Uri.parse('mailto:riveramiko5@gmail.com?subject=$subject&body=$body');

    // Debug print to see the mailUrl
    print(mailUrl.toString());

    if (await canLaunchUrl(mailUrl)) {
      await launchUrl(mailUrl, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Could not launch the email app.'),
        ),
      );
    }

  }


  @override
  void dispose() {
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Your Gmail Address',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                labelText: 'Message',
              ),
              maxLines: 5,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _sendEmail,
              child: const Text('Send Email'),
            ),
          ],
        ),
      ),
    );
  }
}
