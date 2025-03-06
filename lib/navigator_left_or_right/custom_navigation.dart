import 'package:flutter/material.dart';

// Function to navigate with slide transition
void navigateWithSlideTransition(BuildContext context, Widget page, {bool slideRight = true}) {
  Navigator.push(
    context,
    PageRouteBuilder(
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        // Determine slide direction
        final Offset begin = slideRight ? Offset(1.0, 0.0) : Offset(-1.0, 0.0);
        final Offset end = Offset.zero;
        final curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
        var offsetAnimation = animation.drive(tween);

        return SlideTransition(position: offsetAnimation, child: child);
      },
    ),
  );
}
