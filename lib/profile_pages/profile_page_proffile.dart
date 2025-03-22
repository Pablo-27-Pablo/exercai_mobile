import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:exercai_mobile/main.dart';
import 'profile_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting

class ProfilePageProfile extends StatefulWidget {
  @override
  _ProfilePageProfileState createState() => _ProfilePageProfileState();
}

class _ProfilePageProfileState extends State<ProfilePageProfile> {
  TextEditingController firstNameController = TextEditingController();
  TextEditingController lastNameController = TextEditingController();
  //TextEditingController emailController = TextEditingController();
  TextEditingController dobController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  bool _isDataLoaded = false;

  final User? currentUser = FirebaseAuth.instance.currentUser;

  @override
  void dispose() {
    firstNameController.dispose();
    lastNameController.dispose();
    //emailController.dispose();
    dobController.dispose();
    ageController.dispose();
    super.dispose();
  }

  Future<DocumentSnapshot<Map<String, dynamic>>> getUserDetails() async {
    return await FirebaseFirestore.instance
        .collection("Users")
        .doc(currentUser!.email)
        .get();
  }

  // Function to compute age as an integer
  String computeAge(Timestamp? dob) {
    if (dob == null) return "0";
    DateTime birthDate = dob.toDate();
    DateTime today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age.toString();
  }

  // New sliding date picker using a bottom sheet and CupertinoDatePicker
  Future<void> _showSlidingDatePicker(BuildContext context) async {
    DateTime tempPickedDate = DateTime.now().subtract(Duration(days: 5 * 365));
    await showModalBottomSheet(
      context: context,
      builder: (BuildContext builder) {
        return Container(
          height: 250,
          padding: EdgeInsets.only(top: 10),
          child: Column(
            children: [
              Expanded(
                child: CupertinoDatePicker(
                  mode: CupertinoDatePickerMode.date,
                  // Set the initial date to 5 years ago
                  initialDateTime: DateTime.now().subtract(Duration(days: 5 * 365)),
                  // Allow selection from 1900 up to 5 years ago (i.e. disable dates in the last 5 years)
                  minimumDate: DateTime(1900),
                  maximumDate: DateTime.now().subtract(Duration(days: 5 * 365)),
                  onDateTimeChanged: (DateTime newDate) {
                    tempPickedDate = newDate;
                  },
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Done",
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
    int calculatedAge = int.parse(computeAge(Timestamp.fromDate(tempPickedDate)));
    setState(() {
      dobController.text = DateFormat('MM-dd-yyyy').format(tempPickedDate);
      ageController.text = calculatedAge.toString();
    });
  }


  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Pure white background
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        iconTheme: IconThemeData(color: Colors.black87),
        title: Text(
          'My Profile',
          style:
          TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(onPressed: (){
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>ProfilePage()));
        }, icon: Icon(Icons.arrow_back_ios)),
      ),
      body: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
        future: getUserDetails(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (snapshot.hasData) {
            Map<String, dynamic>? user = snapshot.data!.data();
            if (!_isDataLoaded) {
              firstNameController.text = user?['firstname'] ?? '';
              lastNameController.text = user?['lastname'] ?? '';
              //emailController.text = user?['email'] ?? '';
              if (user?['dateOfBirth'] != null) {
                DateTime dob = (user!['dateOfBirth'] as Timestamp).toDate();
                dobController.text = DateFormat('MM-dd-yyyy').format(dob);
                ageController.text = computeAge(Timestamp.fromDate(dob));
              }
              _isDataLoaded = true;
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  // Minimalist header with centered avatar and text
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Column(
                      children: [
                        SizedBox(height: 12),
                        Text(
                          "${_capitalize(user?['firstname'] ?? 'Unknown')} ${_capitalize(user?['lastname'] ?? 'User')}",
                          style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87),
                        ),
                        SizedBox(height: 6),
                        Text(
                          user?['email'] ?? 'No Email Provided',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Metrics card for Weight, Age, and Height
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            _infoCard(
                                user?['weight']?.toString() ?? 'N/A',
                                'Weight (kg)'),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            _infoCard(
                                computeAge(user?['dateOfBirth']),
                                'Years Old'),
                            Container(
                              width: 1,
                              height: 40,
                              color: Colors.grey[300],
                            ),
                            _infoCard(
                                user?['height']?.toString() ?? 'N/A',
                                'Height (cm)'),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Minimalist profile editing form
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Card(
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildTextField(
                                'First Name', firstNameController),
                            _buildTextField(
                                'Last Name', lastNameController),
                            //_buildTextField('Email', emailController),
                            _buildDateOfBirthField(context),
                            SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: () async {
                                User? user =
                                    FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  DateTime? dob;
                                  try {
                                    dob = DateFormat('MM-dd-yyyy')
                                        .parse(dobController.text);
                                  } catch (e) {
                                    print("Invalid date format: $e");
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Invalid date format. Please use MM-dd-yyyy.")),
                                    );
                                    return;
                                  }
                                  int calculatedAge = int.parse(
                                      computeAge(Timestamp.fromDate(dob)));
                                  await FirebaseFirestore.instance
                                      .collection("Users")
                                      .doc(user.email)
                                      .update({
                                    'firstname': firstNameController.text,
                                    'lastname': lastNameController.text,
                                    //'email': emailController.text,
                                    'dateOfBirth': Timestamp.fromDate(dob),
                                    'age': calculatedAge,
                                  }).then((_) {
                                    print("User profile data saved.");
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Profile updated successfully!")),
                                    );
                                    setState(() {
                                      ageController.text =
                                          calculatedAge.toString();
                                    });
                                  }).catchError((error) {
                                    print("Failed to save data: $error");
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(
                                      SnackBar(
                                          content: Text(
                                              "Failed to update profile. Please try again.")),
                                    );
                                  });
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.moresolidPrimary,
                                padding: EdgeInsets.symmetric(
                                    vertical: 14, horizontal: 40),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                              ),
                              child: Text(
                                'Update Profile',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                ],
              ),
            );
          }
          return Center(child: Text("No user data found."));
        },
      ),
    );
  }

  Widget _infoCard(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87),
        ),
        SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.w600)),
          SizedBox(height: 5),
          TextField(
            controller: controller,
            style: TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: label,
              filled: true,
              fillColor: Colors.white,
              contentPadding:
              EdgeInsets.symmetric(vertical: 14, horizontal: 16),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(12),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.black),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateOfBirthField(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date of Birth (MM-dd-yyyy)',
              style: TextStyle(
                  color: Colors.black87, fontWeight: FontWeight.w600)),
          SizedBox(height: 5),
          GestureDetector(
            onTap: () => _showSlidingDatePicker(context),
            child: AbsorbPointer(
              child: TextField(
                controller: dobController,
                style: TextStyle(color: Colors.black87),
                decoration: InputDecoration(
                  hintText: 'MM-dd-yyyy',
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding:
                  EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey[300]!),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.black),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
