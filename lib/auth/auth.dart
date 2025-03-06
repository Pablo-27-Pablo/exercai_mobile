import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_or_register.dart';
import 'package:exercai_mobile/homepage/starter_page.dart';
import 'package:flutter/material.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot){
            //user is logged in
            if(snapshot.hasData){
              return MainLandingPage();
            }

            //user is NOT logged in
            else{
              return LoginOrRegister();
            }



          },),
    );
  }
}
