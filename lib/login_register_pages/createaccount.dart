import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/auth/login_or_register.dart';
import 'package:exercai_mobile/login_register_pages/welcome.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercai_mobile/helper/helper_functions.dart';
import 'package:flutter/material.dart';
import 'login.dart';
import 'package:exercai_mobile/components/my_button.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';
import 'package:hive/hive.dart';


class Createaccount extends StatefulWidget {
  final void Function()? onTap;
  Createaccount({super.key, required this.onTap});


  @override
  State<Createaccount> createState() => _CreateaccountState();
}
final TextEditingController fnameController = TextEditingController();
final TextEditingController lnameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController confirmpassController = TextEditingController();

//register page
// Inside the registerUser function in Createaccount.dart
void registerUser(BuildContext context) async {
  // Show loading circle
  showDialog(
    context: context,
    builder: (context) => const Center(
      child: CircularProgressIndicator(),
    ),
  );

  // Make passwords match
  if (passwordController.text != confirmpassController.text) {
    Navigator.pop(context);
    displayMessagetoUser("Passwords don't match", context);
    return;
  }

  try {
    // Create user in Firebase Authentication
    UserCredential? userCredential =
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: emailController.text.trim(),
      password: passwordController.text,
    );

    // Create user document in Firestore
    await createUserDocument(userCredential);

    // Pop loading circle
    if (context.mounted) Navigator.pop(context);

    // Navigate to WelcomeUser screen
    if (context.mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => WelcomeUser()),
      );
    }
  } on FirebaseAuthException catch (e) {
    // Pop loading circle
    if (context.mounted) Navigator.pop(context);

    // Display error message to user
    displayMessagetoUser(e.code, context);
  }
}


  //create a user document and collect them in firestore
  Future<void> createUserDocument(UserCredential? userCredential) async {
    if (userCredential != null && userCredential.user != null) {
      await FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'email': userCredential.user!.email,
        'firstname': fnameController.text.trim(), // Save exactly as typed
        'lastname': lnameController.text.trim(),  // Save exactly as typed
      });
    }
  }


class _CreateaccountState extends State<Createaccount> {
  bool? isChecked = false;
  var _obsecurefirst = true;
  var _obsecuresec = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundgrey,
      appBar: AppbarSection(),
      body: ListView(
        children: [
          TextSection(),
          TextFieldSection(),
          SizedBox(height: 10,),
          LoginButton(
            text: 'Register',
            onTap: () => registerUser(context), // Pass the context using a lambda
          ),
          SizedBox(
            height: 10,
          ),
          dividerSection(),
          SizedBox(
            height: 10,
          ),
          ToLogInSection()
        ],
      ),
    );
  }

  AppBar AppbarSection() {
    return AppBar(
      centerTitle: true,
      backgroundColor: Colors.transparent,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: AppColor.yellowtext),
        onPressed: () => navigateWithSlideTransition(context, LoginOrRegister(), slideRight: false), // Slide left to go back
      ),

      title: Text(
        "Create Account",
        style: TextStyle(color: AppColor.yellowtext, fontWeight: FontWeight.bold),
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

  Row ToLogInSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.white),
        ),
        GestureDetector(
            onTap: widget.onTap,//() {Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));},
            child: Text("Log In",
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
      child: Padding(
        padding: const EdgeInsets.only(right: 25.0, left: 25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            //First First Name Text Field
            Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: AppColor.shadow.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 0.0)
              ]),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'First Name',

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
                controller: fnameController,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            //First Last Name Text Field
            Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: AppColor.shadow.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 0.0)
              ]),
              child: TextField(
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person_outline),
                  hintText: 'Last Name',
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
                controller: lnameController,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            //First Email Text Field
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
                  hintText: 'Email',
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
            ),
            SizedBox(
              height: 20,
            ),
            //First Password Text Field
            Container(
              height: 50,
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: AppColor.shadow.withOpacity(0.5),
                    blurRadius: 40,
                    spreadRadius: 0.0)
              ]),
              child: TextField(
                obscureText: _obsecurefirst,
                decoration: InputDecoration(
                  suffix: IconButton(
                    padding: const EdgeInsetsDirectional.only(end: 20),
                    onPressed: () {
                      setState(() {
                        _obsecurefirst = !_obsecurefirst;
                      });
                    },
                    icon: _obsecurefirst
                        ? Icon(Icons.visibility_off_outlined)
                        : Icon(Icons.visibility_outlined),
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
            ),
            SizedBox(
              height: 20,
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
                obscureText: _obsecuresec,
                decoration: InputDecoration(
                  suffix: IconButton(
                    padding: const EdgeInsetsDirectional.only(end: 20),
                    onPressed: () {
                      setState(() {
                        _obsecuresec = !_obsecuresec;
                      });
                    },
                    icon: _obsecuresec
                        ? Icon(Icons.visibility_off_outlined)
                        : Icon(Icons.visibility_outlined),
                  ),
                  prefixIcon: Icon(Icons.lock_clock_outlined),
                  hintText: 'Confirm Password',
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
                controller: confirmpassController,
              ),

            ),
            SizedBox(
              height: 15,
            ),
            Container(
              child: Row(
                children: [
                  Checkbox(
                      value: isChecked,
                      onChanged: (newBool) {
                        setState(() {
                          isChecked = newBool;
                        });
                      }),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        print("to privacy policy and term of use");
                      },
                      child: Text(
                        "By continuing you accept out Privacy Policy and Term  of Use",
                        style: TextStyle(decoration: TextDecoration.underline),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Container TextSection() {
    return Container(
      height: 78,
      child: Center(
        child: Text("Let's Start!",
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontSize: 32)),
      ),
    );
  }
}
