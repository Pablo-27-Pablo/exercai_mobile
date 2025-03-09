import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/login_register_pages/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import'package:exercai_mobile/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';


class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final _emailController = TextEditingController();

  @override
  void dispose(){
    _emailController.dispose();
    super.dispose();
  }

  Future<void> passwordReset() async {
    String email = _emailController.text.trim();

    try {
      // Check if the email exists in Firestore
      var querySnapshot = await FirebaseFirestore.instance
          .collection('Users') // Change this to match your Firestore collection name
          .where('email', isEqualTo: email)
          .get();

      if (querySnapshot.docs.isEmpty) {
        // If no user with this email exists, show an error message
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('No account found with this email. Please check and try again.'),
            );
          },
        );
        return; // Exit the function
      }

      // If the email exists, send the password reset email
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Password reset link sent! Check your email'),
          );
        },
      );

    } on FirebaseAuthException catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text(e.message.toString()),
          );
        },
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundgrey,
      appBar: AppBar(
        backgroundColor: AppColor.backgroundgrey,
        title: const Text('Forgot Password',style: TextStyle(color: AppColor.primary),),
        centerTitle: true,
        leading: IconButton(onPressed: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>LoginPage()));
        }, icon: Icon(Icons.arrow_back,color: AppColor.primary,))
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: AppColor.primary.withOpacity(0.9),
              ),
              margin: EdgeInsets.only(top: 20),
              padding: EdgeInsets.only(top: 20, bottom: 30),
              child: Padding(
                padding: const EdgeInsets.only(right: 25.0, left: 25),
                child: Column(
                children: [
                  Text('Enter Your Email and we will send you a link to reset your password',style: TextStyle(color: Colors.white,fontSize: 20,fontWeight: FontWeight.bold),textAlign: TextAlign.center,),
                  SizedBox(
                    height: 10,
                  ),
                  Row(
                    children: [
                      Text(
                        'Email',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColor.solidtext),
                      ),
                    ],
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
                      controller: _emailController,
                    ),
                  ),
                  SizedBox(height: 20,),

                  MaterialButton(
                    onPressed: passwordReset,
                    color: AppColor.backgroundgrey,
                    padding: EdgeInsets.symmetric(vertical: 16, horizontal: 32), // Increases button size
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30), // Adds rounded corners
                    ),
                    child: Text(
                      'Reset Password',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18), // Bigger text
                    ),
                  )

                ],
                            ),
              ),
            ),
          ],

        ),
      ),
    );
  }
}
