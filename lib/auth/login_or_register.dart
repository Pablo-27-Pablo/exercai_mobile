import 'package:exercai_mobile/login_register_pages/createaccount.dart';
import 'package:exercai_mobile/login_register_pages/login.dart';
import 'package:flutter/material.dart';

class LoginOrRegister extends StatefulWidget {
  final bool initialShowLoginPage; // Add this line
  const LoginOrRegister({super.key, this.initialShowLoginPage = true}); // Modify this line

  @override
  State<LoginOrRegister> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegister> {


  //initially show login page
  bool showLoginPage = true;

  @override
  void initState() {
    super.initState();
    showLoginPage = widget.initialShowLoginPage; // Initialize with the parameter
  }


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
