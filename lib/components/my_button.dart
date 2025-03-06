import 'package:flutter/material.dart';
import 'package:exercai_mobile/main.dart';

class LoginButton extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  const LoginButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        child: Column(
          children: [
            Container(
              height: 55,
              width: 150,
              decoration: BoxDecoration(
                  color: AppColor.buttonPrimary.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(50),
                  border: Border.all(width: 2, color: AppColor.buttonSecondary),
                  boxShadow: [
                    BoxShadow(
                        color: AppColor.buttonSecondary.withOpacity(0.7),
                        blurRadius: 90,
                        spreadRadius: 0.1)
                  ]),
              child: Center(
                  child: Text(
                    text,
                    style: TextStyle(
                        color: AppColor.textwhite,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}