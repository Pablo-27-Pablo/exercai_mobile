import 'package:exercai_mobile/components/my_button.dart';
import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:exercai_mobile/homepage/starter_page.dart';
import 'package:exercai_mobile/reset_password/forgot_pw_page.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'createaccount.dart';
import 'package:exercai_mobile/helper/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exercai_mobile/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io'; // For Internet check


class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override

  State<LoginPage> createState() => _LoginPageState();
}

// Check Internet Connection
      Future<bool> _isConnected() async {
        try {
          final result = await InternetAddress.lookup('google.com');
          return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
        } on SocketException catch (_) {
          return false;
        }
      }



      // Save user token for session management
      Future<void> saveUserSession(String token) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', token);
      }

void login(BuildContext context) async {
  String email = emailController.text.trim();
  String password = passwordController.text.trim();

  // Check if email or password fields are empty
  if (email.isEmpty || password.isEmpty) {
    displayMessagetoUser("Please enter both email and password.", context);
    return;
  }

  // Check if email format is valid
  bool emailValid = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email);
  if (!emailValid) {
    displayMessagetoUser("Please enter a valid email address.", context);
    return;
  }

  // Check for internet connection
  bool hasInternet = await _isConnected();
  if (!hasInternet) {
    displayMessagetoUser("No Internet Connection", context);
    return;
  }

  // Show loading indicator
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent user from dismissing
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    UserCredential userCredential = await FirebaseAuth.instance
        .signInWithEmailAndPassword(email: email, password: password);

    // Save session token
    await saveUserSession(userCredential.user!.uid);

    // Clear text fields after successful login
    emailController.clear();
    passwordController.clear();

    // Close loading indicator and navigate
    if (context.mounted) {
      Navigator.pop(context); // Close loading
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MainLandingPage()),
      );
    }
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context); // Close loading

    // Handle Firebase Authentication errors
    if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      displayMessagetoUser("Login Failed: Incorrect email or password.", context);
    } else if (e.code == 'invalid-email') {
      displayMessagetoUser("Invalid email format. Please check your email.", context);
    } else if (e.code == 'network-request-failed') {
      displayMessagetoUser("Network error. Please check your connection.", context);
    } else {
      displayMessagetoUser("Login Failed: \nYour email or password is incorrect", context);
      //displayMessagetoUser("Login Failed: ${e.message ?? "Unknown error occurred"}", context);
    }
  }
}


class _LoginPageState extends State<LoginPage> {
  var _obsecurepass = true;

  @override
  void dispose() {
    // Clear the email and password fields when the user leaves the page
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppColor.backgroundgrey,
      //appBar: AppbarSection(),
      body: ListView(
        children: [
          const SizedBox(height: 30,),
          TextSection(),
          TextFieldSection(),
          SizedBox(
            height: 30,
          ),
          LoginButton(text: "Login", onTap: ()=>login(context)),
          SizedBox(
            height: 15,
          ),
          dividerSection(),
          SizedBox(
            height: 15,
          ),
          signUpSection()
        ],
      ),
    );
  }

  Container dividerSection() {
    return Container(
      child: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "----------------------------",
              style: TextStyle(
                  color: AppColor.buttonSecondary.withOpacity(.5),
                  fontSize: 15),
            ),
            Text("  Or  ",
                style: TextStyle(
                    color: AppColor.buttonSecondary.withOpacity(.5),
                    fontSize: 15)),
            Text("----------------------------",
                style: TextStyle(
                    color: AppColor.buttonSecondary.withOpacity(.5),
                    fontSize: 15))
          ],
        ),
      ),
    );
  }

  Row signUpSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Dont have an account yet? ",
          style: TextStyle(color: Colors.white),
        ),
        GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => Createaccount()));
            },
                    //(){Navigator.push(context, MaterialPageRoute(builder: (context) => Createaccount()));},
            child: Text("Sign Up",
                style: TextStyle(
                    color: AppColor.yellowtext, fontWeight: FontWeight.bold)))
      ],
    );
  }



  Container TextFieldSection() {
    return Container(
      decoration: BoxDecoration(
          color: AppColor.primary.withOpacity(0.9),
          ),
      margin: EdgeInsets.only(top: 20),
      padding: EdgeInsets.only(top: 20, bottom: 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: const EdgeInsets.only(right: 25.0, left: 25),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Email',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColor.solidtext),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                          color: AppColor.shadow.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 0.0)
                    ]),
                    child: TextField(
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.email_outlined),
                        hintText: 'Enter Your Email',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: emailController,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 25.0, left: 25),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Password',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColor.solidtext),
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Container(
                    height: 50,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                          color: AppColor.shadow.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 0.0)
                    ]),
                    child: TextField(
                      obscureText: _obsecurepass,
                      decoration: InputDecoration(
                        suffix: IconButton(
                          padding: const EdgeInsetsDirectional.only(end: 20),
                          onPressed: () {
                            setState(() {
                              _obsecurepass = !_obsecurepass;
                            });
                          },
                          icon: _obsecurepass
                              ? const Icon(Icons.visibility_off_outlined)
                              : const Icon(Icons.visibility_outlined),
                        ),
                        prefixIcon: Icon(Icons.lock_clock_outlined),
                        hintText: 'Enter Your Password',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Colors.transparent),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      controller: passwordController,
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          GestureDetector(
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context)=>ForgotPasswordPage()));

              },
              child: Padding(
                padding: const EdgeInsets.only(right: 30),
                child: Text(
                  "Forgot Password?",
                  style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  textAlign: TextAlign.start,
                ),
              ))
        ],
      ),
    );
  }

  Container TextSection() {
    return Container(
      height: 190,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Image.asset('assets/exercai-logo-violet.png',height: 130,),
            SizedBox(height: 20,),
            Text("Enjoy Exercising With Us",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 20)),
          ],
        ),
      ),
    );
  }

/*  AppBar AppbarSection() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      //leading: Icon(),
      title: Text(
        "Login",
        style: TextStyle(color: AppColor.yellowtext, fontWeight: FontWeight.bold),
      ),
    );
  }*/
}
