import 'package:exercai_mobile/components/my_button.dart';
import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:exercai_mobile/homepage/starter_page.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'createaccount.dart';
import 'package:exercai_mobile/helper/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:exercai_mobile/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class LoginPage extends StatefulWidget {
  final void Function()? onTap;
  LoginPage({super.key, required this.onTap});

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  @override
  State<LoginPage> createState() => _LoginPageState();
}



      // Save user token for session management
      Future<void> saveUserSession(String token) async {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_token', token);
      }

      // Login function with loading indicator and token storage
      void login(BuildContext context) async {
        showDialog(
          context: context,
          barrierDismissible: false, // Prevent user from dismissing
          builder: (context) => const Center(child: CircularProgressIndicator()),
        );

        try {
          UserCredential userCredential = await FirebaseAuth.instance
              .signInWithEmailAndPassword(
            email: emailController.text,
            password: passwordController.text,
          );

          // Save session token
          await saveUserSession(userCredential.user!.uid);


          // Pop loading indicator and navigate
          if (context.mounted) {
            Navigator.pop(context); // Close loading
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => MainLandingPage()),
            );
          }
        } on FirebaseAuthException catch (e) {
          Navigator.pop(context); // Close loading
          displayMessagetoUser(e.message ?? "Login Failed", context);
        }
      }







class _LoginPageState extends State<LoginPage> {
  var _obsecurepass = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:  AppColor.backgroundgrey,
      appBar: AppbarSection(),
      body: ListView(
        children: [
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
            onTap:widget.onTap,
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
                    'Username or email',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppColor.solidtext),
                  ),
                  SizedBox(
                    height: 15,
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
                        hintText: 'Enter Username or Email',
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
                    height: 15,
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
                        hintText: 'Enter Password',
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
                print("Wala pang Data to");
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
            Text(
              "Hey There,",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  fontSize: 20),
            ),
            Text("Welcome",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 35)),
            SizedBox(height: 20,),
            Text("Enjoy Real-Time Exercising\nwhile you Track your Weigth Progression With Us\nWith Us",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                    fontSize: 15)),
          ],
        ),
      ),
    );
  }

  AppBar AppbarSection() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      //leading: Icon(),
      title: Text(
        "Login",
        style: TextStyle(color: AppColor.yellowtext, fontWeight: FontWeight.bold),
      ),
    );
  }
}
