import 'package:exercai_mobile/login_register_pages/createaccount.dart';
import 'package:exercai_mobile/login_register_pages/login.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  const LoginOrRegister({super.key});

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {


  //initially show login page
  bool showLoginPage = true;


//toggle between login and register page
  void togglePages(){
  setState(() {
    showLoginPage = !showLoginPage;
  });
  }

  @override
  Widget build(BuildContext context) {
    if (showLoginPage){
      return LoginPage(onTap: togglePages);
    }
    else{
      return Createaccount(onTap: togglePages);
    }
  }
}
