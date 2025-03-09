import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exercai_mobile/login_register_pages/login.dart';
import 'package:exercai_mobile/main.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout(BuildContext context) async {
    FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Confirm Logout"),
          content: Text("Are you sure you want to log out?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                logout(context); // Call the logout function
              },
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColor.primary,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              //drawer header
              DrawerHeader(
                child: Icon(Icons.circle_outlined,color: AppColor.primary,)
              ),

              const SizedBox(
                height: 25,
              ),
              //home tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Colors.white, // Change the color of the icon
                  ),
                  title: Text(
                    "H O M E",
                    style: TextStyle(color: Colors.white), // Change text color if needed
                  ),
                  onTap: () {
                    //this is already home screen so just pop the drawer
                    Navigator.pop(context);
                  },
                ),
              ),

              //profile tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Colors.white, // Change the color of the icon
                  ),
                  title: Text(
                    "P R O F I L E",
                    style: TextStyle(color: Colors.white), // Change text color if needed
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    //navigate to profile page
                    Navigator.pushNamed(context, '/profile_page');
                  },
                ),
              ),

              //user tile

              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.insert_chart,
                    color: Colors.white, // Change the color of the icon
                  ),
                  title: Text(
                    "P R O G R E S S   T R A C K I N G",
                    style: TextStyle(color: Colors.white), // Change text color if needed
                  ),
                  onTap: () {
                    //this is already home screen so just pop the drawer
                    Navigator.pop(context);

                    //navigate to users page
                    Navigator.pushNamed(context, '/progress_tracking');
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.settings_accessibility,
                    color: Colors.white, // Change the color of the icon
                  ),
                  title: Text(
                "B M I  S E T T I N G S",
                    style: TextStyle(color: Colors.white), // Change text color if needed
                  ),
                  onTap: () {
                    //this is already home screen so just pop the drawer
                    Navigator.pop(context);

                    //navigate to users page
                    Navigator.pushNamed(context, '/bmi_settings');
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.food_bank,
                    color: Colors.white, // Change the color of the icon
                  ),
                  title: Text(
                    "N U T R I T I O N  A N D\nC A L O R I E S",
                    style: TextStyle(color: Colors.white), // Change text color if needed
                  ),
                  onTap: () {
                    //this is already home screen so just pop the drawer
                    Navigator.pop(context);

                    //navigate to users page
                    Navigator.pushNamed(context, '/nutrition');
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.alarm ,
                    color: Colors.white, // Change the color of the icon
                  ),
                  title: Text(
                    "S E T  R E M I N D E R S",
                    style: TextStyle(color: Colors.white), // Change text color if needed
                  ),
                  onTap: () {
                    //this is already home screen so just pop the drawer
                    Navigator.pop(context);

                    //navigate to users page
                    Navigator.pushNamed(context, '/reminder');
                  },
                ),
              ),

            ],
          ),

          //logout
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Colors.white, // Change the color of the icon
              ),
              title: Text(
                "L O G O U T",
                style: TextStyle(color: Colors.white), // Change text color if needed
              ),
              onTap: () {
                _showLogoutConfirmationDialog(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}