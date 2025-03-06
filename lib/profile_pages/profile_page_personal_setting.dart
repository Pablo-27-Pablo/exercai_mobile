import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';
import 'package:exercai_mobile/utils/constant.dart';

class HomePagePersonalSetting extends StatefulWidget {
  const HomePagePersonalSetting({super.key});

  @override
  State<HomePagePersonalSetting> createState() =>
      _HomePagePersonalSettingState();
}



class _HomePagePersonalSettingState extends State<HomePagePersonalSetting> {
  var _obsecure_current_password = true;
  var _obsecure_new_password = true;
  var _obsecure_confirm_password = true;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundgrey,
      appBar: AppBar(

        title: Text('Password Settings',
            style: TextStyle(
                color: AppColor.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        children: [
          //Current password text field
          Padding(
            padding: const EdgeInsets.only(left: 30, right: 30,top: 50),
            child: Container(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  largeGap,
                  Row(
                    children: [
                      Text(
                        "Current  Password",
                        style: TextStyle(
                            color: AppColor.primary,
                            fontSize: 20,
                            fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  smallGap,
                  Container(
                    height: 50,
                    decoration: BoxDecoration(boxShadow: [
                      BoxShadow(
                          color: AppColor.shadow.withOpacity(0.5),
                          blurRadius: 40,
                          spreadRadius: 0.0)
                    ]),
                    child: TextField(
                      obscureText: _obsecure_current_password,
                      decoration: InputDecoration(
                        suffix: IconButton(
                          padding: const EdgeInsetsDirectional.only(end: 20),
                          onPressed: () {
                            setState(() {
                              _obsecure_current_password =
                                  !_obsecure_current_password;
                            });
                          },
                          icon: _obsecure_current_password
                              ? const Icon(Icons.visibility_off_outlined)
                              : const Icon(Icons.visibility_outlined),
                        ),
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
                    ),
                  ),
                  smallGap,
                  GestureDetector(
                      onTap: () {},
                      child: Text("Forgot Password?",
                          style: TextStyle(
                              color: AppColor.textwhite,
                              fontSize: 15,
                              fontWeight: FontWeight.w700)))
                ],
              ),
            ),
          ),
          Container(
            //New Password Textfield
            padding: EdgeInsets.only(left: 30, right: 30, top: 15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "New Password",
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                smallGap,
                Container(
                  height: 50,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: AppColor.shadow.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 0.0)
                  ]),
                  child: TextField(
                    obscureText: _obsecure_new_password,
                    decoration: InputDecoration(
                      suffix: IconButton(
                        padding: const EdgeInsetsDirectional.only(end: 20),
                        onPressed: () {
                          setState(() {
                            _obsecure_new_password = !_obsecure_new_password;
                          });
                        },
                        icon: _obsecure_new_password
                            ? const Icon(Icons.visibility_off_outlined)
                            : const Icon(Icons.visibility_outlined),
                      ),
                      hintText: 'Enter New Password',
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
                  ),
                ),
                largeGap,

                //Confirm new password
                Text(
                  "Confirm New Password",
                  style: TextStyle(
                      color: AppColor.primary,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                ),
                smallGap,
                Container(
                  height: 50,
                  decoration: BoxDecoration(boxShadow: [
                    BoxShadow(
                        color: AppColor.shadow.withOpacity(0.5),
                        blurRadius: 40,
                        spreadRadius: 0.0)
                  ]),
                  child: TextField(
                    obscureText: _obsecure_confirm_password,
                    decoration: InputDecoration(
                      suffix: IconButton(
                        padding: const EdgeInsetsDirectional.only(end: 20),
                        onPressed: () {
                          setState(() {
                            _obsecure_confirm_password = !_obsecure_confirm_password;
                          });
                        },
                        icon: _obsecure_confirm_password
                            ? const Icon(Icons.visibility_off_outlined)
                            : const Icon(Icons.visibility_outlined),
                      ),
                      hintText: 'Confirm New Password',
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
                  ),
                ),
                largeGap,
                largeGap,
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // Handle profile update logic
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => ProgressTrackingScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColor.yellowtext,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Change Password',
                      style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
