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
import 'dart:io';


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

void registerUser(BuildContext context) async {
  // Trim input values
  String email = emailController.text.trim();
  String password = passwordController.text;
  String confirmPassword = confirmpassController.text;
  String firstName = fnameController.text.trim();
  String lastName = lnameController.text.trim();

  // Check if fields are empty
  if (firstName.isEmpty || lastName.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
    displayMessagetoUser("Please fill in all fields.", context);
    return;
  }

  // Validate email format
  bool emailValid = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email);
  if (!emailValid) {
    displayMessagetoUser("Please enter a valid email address.", context);
    return;
  }

  // Check if passwords match
  if (password != confirmPassword) {
    displayMessagetoUser("Passwords don't match", context);
    return;
  }

  // Check for internet connection
  bool hasInternet = await _isConnected();
  if (!hasInternet) {
    displayMessagetoUser("No Internet Connection", context);
    return;
  }

  // Check if email is already registered in Firebase
  bool isEmailAvailable = await checkIfEmailExists(email, context);
  if (!isEmailAvailable) {
    displayMessagetoUser("Email is already registered. Please use a different email.", context);
    return;
  }


  // Show loading circle
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent user from dismissing dialog
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // Create user in Firebase Authentication
    UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email,
      password: password,
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

    // Handle Firebase errors
    String errorMessage;
    if (e.code == 'email-already-in-use') {
      errorMessage = "This email is already registered. Please use a different email.";
    } else if (e.code == 'weak-password') {
      errorMessage = "Password is too weak. Please use a stronger password.";
    } else if (e.code == 'invalid-email') {
      errorMessage = "Invalid email format.";
    } else {
      errorMessage = "Registration failed: ${e.message ?? "Unknown error"}";
    }

    displayMessagetoUser(errorMessage, context);
  }
}

// Function to check internet connection
Future<bool> _isConnected() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

// Function to check if email is already registered in Firebase
Future<bool> checkIfEmailExists(String email, BuildContext context) async {
  try {
    List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    return signInMethods.isEmpty; // Returns true if email is NOT in use
  } on FirebaseAuthException catch (e) {
    if (e.code == 'invalid-email') {
      displayMessagetoUser("Invalid email format.", context);
    }
    return false;
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
  void initState() {
    super.initState();
    // Clear fields when navigating to Create Account
    emailController.clear();
    fnameController.clear();
    lnameController.clear();
    passwordController.clear();
    confirmpassController.clear();
  }
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
          Opacity(
            opacity: isChecked! ? 1.0 : 0.5, // Reduce opacity when disabled
            child: LoginButton(
              text: 'Register',
              onTap: isChecked! ? () => registerUser(context) : null, // Disable button if unchecked
            ),
          )
          ,
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
        onPressed: () {
          setState(() {
            // Clear fields when navigating to Create Account
            emailController.clear();
            fnameController.clear();
            lnameController.clear();
            passwordController.clear();
            confirmpassController.clear();
          });
          navigateWithSlideTransition(context, LoginOrRegister(), slideRight: false);
          }, // Slide left to go back
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
                        _showPrivacyPolicyDialog();
                        print("to privacy policy and term of use");
                      },
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(color: Colors.white), // Default text color
                          children: [
                            TextSpan(
                              text: "By continuing you accept our ",
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                            TextSpan(
                              text: "Privacy Policy",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            TextSpan(
                              text: " and ",
                              style: TextStyle(fontWeight: FontWeight.normal),
                            ),
                            TextSpan(
                              text: "Terms of Use",
                              style: TextStyle(
                                decoration: TextDecoration.underline,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
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

  // Function to Show Privacy Policy & Terms Dialog
  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Privacy Policy & Terms of Use"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Welcome to our Exercise App!",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 10),
                Text(
                  "We collect basic information like your name, email, and fitness data to provide a personalized experience.",
                ),
                SizedBox(height: 10),
                Text(
                  "🔹 What We Collect:\n"
                      "- Name, Email, Bday, Height, Weight, Gender\n"
                      "- Weight & Fitness Goals\n"
                      "- Activity Tracking data\n",
                ),
                Text(
                  "🔹 How We Use Your Data:\n"
                      "- To help track your fitness progress\n"
                      "- To improve our app experience\n"
                      "- To send motivational notifications\n",
                ),
                Text(
                  "🔹 Your Rights:\n"
                      "- You can update your account anytime.\n"
                      //"- You can update or delete your account anytime.\n"
                      "- Your data is securely stored and not shared with third parties.",
                ),
                SizedBox(height: 15),
                Text(
                  "By continuing, you Agree to these Terms.",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

}




