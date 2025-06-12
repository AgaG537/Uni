import 'package:flutter/material.dart';

Widget buildGoogleSignInButton(VoidCallback onTap) {
  return InkWell(
    onTap: onTap,
    child: Image.asset(
      'assets/google_logo.png',
      height: 60.0, // Adjust size as needed
      width: 240.0,
    ),
  );
}