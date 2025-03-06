import 'package:flutter/material.dart';
import 'profile_page_personal_setting.dart';
import 'profile_page_proffile.dart';
import 'package:exercai_mobile/main.dart';

class ProfilePageSetting extends StatefulWidget {
  const ProfilePageSetting({super.key});

  @override
  State<ProfilePageSetting> createState() => _ProfilePageSettingState();
}


class _ProfilePageSettingState extends State<ProfilePageSetting> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.backgroundgrey,
      appBar: AppBar(

        title: Text('Settings',
            style: TextStyle(
                color: AppColor.primary, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 30),
        child: Column(
          
          children: [
            ListTile(
              leading: ClipOval(
                child: Container(
                    height: 50,
                    width: 50,
                    color: AppColor.primary,
                    child: Icon(Icons.key, color: AppColor.textwhite)),
              ),
              title: Text(
                "Password Setting",
                style: TextStyle(color: AppColor.textwhite, fontSize: 16),
              ),
              trailing: Icon(Icons.arrow_forward_ios,
                  color: AppColor.yellowtext.withOpacity(0.7), size: 16),
              onTap: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => HomePagePersonalSetting()));
              },
            ),
            Container(
              margin: EdgeInsets.only(top: 10,bottom: 10),
              child: ListTile(
                leading: ClipOval(
                  child: Container(
                      height: 50,
                      width: 50,
                      color: AppColor.primary,
                      child: Icon(Icons.delete, color: AppColor.textwhite)),
                ),
                title: Text(
                  "Delete Account",
                  style: TextStyle(color: AppColor.textwhite, fontSize: 16),
                ),
                trailing: Icon(Icons.arrow_forward_ios,
                    color: AppColor.yellowtext.withOpacity(0.7), size: 16),
                onTap: () {},
              ),
            ),
          ],
        ),
      ),

    );
  }
}
