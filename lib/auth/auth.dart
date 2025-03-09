import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:exercai_mobile/intro_pages/openingpage.dart'; // Your WelcomePage/Onboarding
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_or_register.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:exercai_mobile/login_register_pages/login.dart';

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  _AuthPageState createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  bool _isLoading = true;
  bool _isFirstLaunch = false;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
  }
  Future<void> onMessageReceived(RemoteMessage message) async {
    print("New message: ${message.notification?.title}");
  }

  Future<void> _checkFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    bool isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

    if (isFirstLaunch) {
      await prefs.setBool('isFirstLaunch', false); // Mark as launched
      setState(() => _isFirstLaunch = true);
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // Show onboarding/WelcomePage on first launch
    if (_isFirstLaunch) {
      return WelcomePage(); // Your onboarding screen
    }

    // Check authentication state
    return StreamBuilder(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasData) {
          return const MainLandingPage(); // User is logged in
        } else {
          return LoginPage(); // Show auth flow
        }
      },
    );
  }
}