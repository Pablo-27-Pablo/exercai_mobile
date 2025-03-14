import 'dart:io';
import 'package:exercai_mobile/components/my_button.dart';
import 'package:exercai_mobile/homepage/mainlandingpage.dart';
import 'package:exercai_mobile/reset_password/forgot_pw_page.dart';
import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'createaccount.dart';
import 'package:exercai_mobile/helper/helper_functions.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ----------------------------------
// The same top-level login function
// ----------------------------------
Future<bool> _isConnected() async {
  try {
    final result = await InternetAddress.lookup('google.com');
    return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
  } on SocketException catch (_) {
    return false;
  }
}

Future<void> saveUserSession(String token) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  await prefs.setString('user_token', token);
}

void login(BuildContext context, TextEditingController emailController, TextEditingController passwordController) async {
  String email = emailController.text.trim();
  String password = passwordController.text.trim();

  if (email.isEmpty || password.isEmpty) {
    displayMessagetoUser("Please enter both email and password.", context);
    return;
  }

  bool emailValid = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$").hasMatch(email);
  if (!emailValid) {
    displayMessagetoUser("Please enter a valid email address.", context);
    return;
  }

  bool hasInternet = await _isConnected();
  if (!hasInternet) {
    displayMessagetoUser("No Internet Connection", context);
    return;
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => const Center(child: CircularProgressIndicator()),
  );

  try {
    UserCredential userCredential =
    await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);

    await saveUserSession(userCredential.user!.uid);

    emailController.clear();
    passwordController.clear();

    if (context.mounted) {
      Navigator.pop(context);
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainLandingPage()));
    }
  } on FirebaseAuthException catch (e) {
    Navigator.pop(context);
    if (e.code == 'user-not-found' || e.code == 'wrong-password') {
      displayMessagetoUser("Login Failed: Incorrect email or password.", context);
    } else if (e.code == 'invalid-email') {
      displayMessagetoUser("Invalid email format. Please check your email.", context);
    } else if (e.code == 'network-request-failed') {
      displayMessagetoUser("Network error. Please check your connection.", context);
    } else {
      displayMessagetoUser("Login Failed: Your email or password is incorrect", context);
    }
  }
}

// ----------------------------------
// The redesigned LoginPage
// ----------------------------------
class LoginPage extends StatefulWidget {
  LoginPage({super.key});

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  bool _obsecurepass = true;
  bool _rememberMe = false; // For the "Remember me" toggle

  @override
  void dispose() {
    widget.emailController.clear();
    widget.passwordController.clear();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // White background
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 1) Top Wave + Logo
              _buildTopWave(context),

              // 2) "Welcome back!" text
              const SizedBox(height: 20),
              Text(
                "Welcome Back !",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 20),

              // 3) Username/Email text field
              _buildTextField(
                controller: widget.emailController,
                hintText: "Email",
                icon: Icons.person_outline,
                obscure: false,
              ),

              const SizedBox(height: 20),

              // 4) Password text field
              _buildTextField(
                controller: widget.passwordController,
                hintText: "Password",
                icon: Icons.lock_outline,
                obscure: _obsecurepass,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obsecurepass ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    setState(() {
                      _obsecurepass = !_obsecurepass;
                    });
                  },
                ),
              ),

              const SizedBox(height: 10),

              // 5) Remember me & Forgot password row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Row(
                  children: [
                    // Remember me
                    Expanded(
                      child: Row(
                        children: [
                          Checkbox(
                            value: _rememberMe,
                            onChanged: (val) {
                              setState(() {
                                _rememberMe = val ?? false;
                              });
                            },
                            activeColor: AppColor.solidPrimary,
                          ),
                          const Text("Remember me"),
                        ],
                      ),
                    ),

                    // Forgot password?
                    GestureDetector(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage()));
                      },
                      child: const Text(
                        "Forgot password?",
                        style: TextStyle(fontWeight: FontWeight.w500, color: Colors.grey),
                      ),
                    ),
                  ],
                ),
              ),

              // 6) Login button
              const SizedBox(height: 20),
              _buildLoginButton(context),

              const SizedBox(height: 20),

              // 8) Divider with "OR"
              Row(
                children: const [
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                      indent: 40,
                      endIndent: 10,
                    ),
                  ),
                  Text("OR"),
                  Expanded(
                    child: Divider(
                      thickness: 1,
                      color: Colors.grey,
                      indent: 10,
                      endIndent: 40,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 15),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text("Don't have an account? "),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => Createaccount()));
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        color: AppColor.solidPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------
  // UI BUILDING BLOCKS
  // ----------------------------------

  // Wave shaped container with gradient + logo at the top
  Widget _buildTopWave(BuildContext context) {
    return ClipPath(
      clipper: _WaveClipper(),
      child: Container(
        height: 200,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColor.supersolidPrimary, AppColor.lightPrimary],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // LOGO
            Positioned(
              top: 50,
              child: Image.asset(
                'assets/exercai-front.png',
                height: 90,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Single text field with a prefix icon
  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: TextField(
        controller: controller,
        obscureText: obscure,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.grey),
          suffixIcon: suffixIcon,
          hintText: hintText,
          hintStyle: const TextStyle(color: Colors.grey),
          fillColor: Colors.grey[100],
          filled: true,
          enabledBorder: OutlineInputBorder(
            borderSide: const BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.circular(25),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: AppColor.solidPrimary),
            borderRadius: BorderRadius.circular(25),
          ),
        ),
      ),
    );
  }

  // Login button with style matching the reference
  Widget _buildLoginButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: GestureDetector(
        onTap: () => login(context, widget.emailController, widget.passwordController),
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            color: AppColor.supersolidPrimary,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: AppColor.supersolidPrimary, width: 1),
          ),
          child: Center(
            child: Text(
              "Login",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.backgroundWhite,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Circle button for each social icon
  Widget _socialCircleButton(IconData icon, Color color) {
    return Container(
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Icon(icon, color: color),
    );
  }
}

// ----------------------------------
// A custom clipper to create a wave
// ----------------------------------
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
