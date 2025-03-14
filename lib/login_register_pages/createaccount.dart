import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exercai_mobile/auth/login_or_register.dart';
import 'package:exercai_mobile/login_register_pages/date_of_birth.dart';
import 'package:exercai_mobile/login_register_pages/welcome.dart';
import 'package:exercai_mobile/reset_password/forgot_pw_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercai_mobile/helper/helper_functions.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/login_register_pages/login.dart';
import 'package:exercai_mobile/components/my_button.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/navigator_left_or_right/custom_navigation.dart';
import 'package:hive/hive.dart';

/// -------------------------
/// Existing logic & variables
/// -------------------------
class Createaccount extends StatefulWidget {
  Createaccount({super.key});

  @override
  State<Createaccount> createState() => _CreateaccountState();
}

final TextEditingController fnameController = TextEditingController();
final TextEditingController lnameController = TextEditingController();
final TextEditingController emailController = TextEditingController();
final TextEditingController passwordController = TextEditingController();
final TextEditingController confirmpassController = TextEditingController();

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
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    // Create user in Firebase Authentication
    UserCredential userCredential =
    await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);

    // Create user document in Firestore
    await createUserDocument(userCredential);

    // Pop loading circle
    if (context.mounted) Navigator.pop(context);

    // Navigate to DateOfBirth page
    if (context.mounted) {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => DateOfBirth()));
    }
  } on FirebaseAuthException catch (e) {
    if (context.mounted) Navigator.pop(context); // Pop loading circle

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

Future<bool> _isConnected() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

Future<bool> checkIfEmailExists(String email, BuildContext context) async {
  try {
    List<String> signInMethods = await FirebaseAuth.instance.fetchSignInMethodsForEmail(email);
    return signInMethods.isEmpty; // true if email NOT in use
  } on FirebaseAuthException catch (e) {
    if (e.code == 'invalid-email') {
      displayMessagetoUser("Invalid email format.", context);
    }
    return false;
  }
}

Future<void> createUserDocument(UserCredential? userCredential) async {
  if (userCredential != null && userCredential.user != null) {
    await FirebaseFirestore.instance.collection("Users").doc(userCredential.user!.email).set({
      'email': userCredential.user!.email,
      'firstname': fnameController.text.trim(),
      'lastname': lnameController.text.trim(),
    });
  }
}

/// -------------------------
/// Redesigned Create Account
/// -------------------------
class _CreateaccountState extends State<Createaccount> {
  bool isChecked = false;
  bool _obsecurefirst = true;
  bool _obsecuresec = true;

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
      backgroundColor: Colors.white, // White background for modern UI
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1) Top wave gradient with "Create Account" label
              _buildTopWave(),


              // 2) "Let's Start!" title
              Text(
                "Let's Start!",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColor.moresolidPrimary,
                  fontSize: 32,
                ),
              ),

              const SizedBox(height: 20),

              // 3) Form fields card
              _buildTextFieldCard(),

              const SizedBox(height: 20),

              // 4) Register button (disabled if isChecked == false)
              _buildRegisterButton(),

              const SizedBox(height: 10),

              // 5) Divider + "Or"
              _buildDividerSection(),

              const SizedBox(height: 10),

              // 6) Already have an account? => Log In
              _buildToLogInSection(),
              SizedBox(height: 15,)
            ],
          ),
        ),
      ),
    );
  }

  /// -------------------------
  /// WAVE HEADER
  /// -------------------------
  Widget _buildTopWave() {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: 150,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.supersolidPrimary, AppColor.lightPrimary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Text(
            "Create Account",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 22,
            ),
          ),
        ),
      ),
    );
  }

  /// -------------------------
  /// TEXT FIELDS CARD
  /// -------------------------
  Widget _buildTextFieldCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: [
            // First Name
            _modernTextField(
              controller: fnameController,
              hintText: 'First Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            // Last Name
            _modernTextField(
              controller: lnameController,
              hintText: 'Last Name',
              prefixIcon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            // Email
            _modernTextField(
              controller: emailController,
              hintText: 'Email',
              prefixIcon: Icons.email_outlined,
            ),
            const SizedBox(height: 16),
            // Password
            _modernTextField(
              controller: passwordController,
              hintText: 'Enter Password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obsecurefirst,
              suffixIcon: IconButton(
                icon: _obsecurefirst
                    ? const Icon(Icons.visibility_off_outlined, color: Colors.grey)
                    : const Icon(Icons.visibility_outlined, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _obsecurefirst = !_obsecurefirst;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),
            // Confirm Password
            _modernTextField(
              controller: confirmpassController,
              hintText: 'Confirm Password',
              prefixIcon: Icons.lock_outline,
              obscureText: _obsecuresec,
              suffixIcon: IconButton(
                icon: _obsecuresec
                    ? const Icon(Icons.visibility_off_outlined, color: Colors.grey)
                    : const Icon(Icons.visibility_outlined, color: Colors.grey),
                onPressed: () {
                  setState(() {
                    _obsecuresec = !_obsecuresec;
                  });
                },
              ),
            ),
            const SizedBox(height: 16),

            // Checkbox + Privacy
            Row(
              children: [
                Checkbox(
                  value: isChecked,
                  activeColor: AppColor.moresolidPrimary,
                  onChanged: (newBool) {
                    setState(() {
                      isChecked = newBool ?? false;
                    });
                  },
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: _showPrivacyPolicyDialog,
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87, fontSize: 14),
                        children: [
                          const TextSpan(text: "By continuing you accept our "),
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              color: AppColor.supersolidPrimary,
                            ),
                          ),
                          const TextSpan(text: " and "),
                          TextSpan(
                            text: "Terms of Use",
                            style: TextStyle(
                              decoration: TextDecoration.underline,
                              fontWeight: FontWeight.bold,
                              color: AppColor.supersolidPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// -------------------------
  /// REGISTER BUTTON
  /// -------------------------
  Widget _buildRegisterButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Opacity(
        opacity: isChecked ? 1.0 : 0.6,
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.solidPrimary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(25),
              ),
            ),
            onPressed: isChecked ? () => registerUser(context) : null,
            child: const Text(
              'Register',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }

  /// -------------------------
  /// DIVIDER SECTION
  /// -------------------------
  Widget _buildDividerSection() {
    return Row(
      children: [
        Expanded(
          child: Divider(
            color: Colors.grey[400],
            thickness: 1,
            indent: 40,
            endIndent: 8,
          ),
        ),
        Text("Or", style: TextStyle(color: Colors.grey[600], fontSize: 16)),
        Expanded(
          child: Divider(
            color: Colors.grey[400],
            thickness: 1,
            indent: 8,
            endIndent: 40,
          ),
        ),
      ],
    );
  }

  /// -------------------------
  /// ALREADY HAVE AN ACCOUNT?
  /// -------------------------
  Widget _buildToLogInSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.black87, fontSize: 16),
        ),
        GestureDetector(
          onTap: () {
            // Clear fields when navigating to Log In
            emailController.clear();
            fnameController.clear();
            lnameController.clear();
            passwordController.clear();
            confirmpassController.clear();
            navigateWithSlideTransition(context, LoginPage(), slideRight: false);
          },
          child: Text(
            "Log In",
            style: TextStyle(
              color: AppColor.supersolidPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 16,
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  /// -------------------------
  /// MODERN TEXT FIELD
  /// -------------------------
  Widget _modernTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: hintText,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        prefixIcon: Icon(prefixIcon, color: AppColor.supersolidPrimary),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  /// -------------------------
  /// PRIVACY POLICY DIALOG
  /// -------------------------
  void _showPrivacyPolicyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          backgroundColor: Colors.white,
          title: Row(
            children: const [
              Icon(Icons.privacy_tip, color: Colors.blueAccent),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  "Privacy Policy & Terms of Use",
                  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Welcome to our Exercise App!",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                const Text(
                  "We collect basic information like your name, email, and fitness data to provide a personalized experience.",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                const Text(
                  "What We Collect:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                ),
                const SizedBox(height: 6),
                const Text(
                  "- Name, Email, Birthday, Height, Weight, Gender",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const Text(
                  "- Weight & Fitness Goals",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const Text(
                  "- Activity Tracking data",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                const Text(
                  "How We Use Your Data:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                ),
                const SizedBox(height: 6),
                const Text(
                  "- To help track your fitness progress",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const Text(
                  "- To improve our app experience",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const Text(
                  "- To send motivational notifications",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 12),
                const Text(
                  "Your Rights:",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                ),
                const SizedBox(height: 6),
                const Text(
                  "- You can update your account anytime.",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const Text(
                  "- Your data is securely stored and not shared with third parties.",
                  style: TextStyle(fontSize: 14, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 10),
                const Center(
                  child: Text(
                    "By continuing, you agree to these Terms.",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.black),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(foregroundColor: Colors.blueAccent),
              child: const Text(
                "Close",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// -------------------------
/// WaveClipper for top header
/// -------------------------
class _WaveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    // Creates a wave shape from top-left to bottom-right
    Path path = Path();
    path.lineTo(0, size.height - 50);

    // Quadratic bezier wave
    var firstControlPoint = Offset(size.width / 4, size.height);
    var firstEndPoint = Offset(size.width / 2, size.height - 30);

    var secondControlPoint = Offset(3 * size.width / 4, size.height - 60);
    var secondEndPoint = Offset(size.width, size.height - 20);

    path.quadraticBezierTo(
      firstControlPoint.dx,
      firstControlPoint.dy,
      firstEndPoint.dx,
      firstEndPoint.dy,
    );

    path.quadraticBezierTo(
      secondControlPoint.dx,
      secondControlPoint.dy,
      secondEndPoint.dx,
      secondEndPoint.dy,
    );

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(_WaveClipper oldClipper) => false;
}
