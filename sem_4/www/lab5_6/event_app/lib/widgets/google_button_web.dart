import 'package:flutter/material.dart';
import 'package:google_sign_in_platform_interface/google_sign_in_platform_interface.dart';
import 'package:google_sign_in_web/google_sign_in_web.dart';

Widget buildGoogleSignInButton(VoidCallback onTap) {
  final GoogleSignInPlugin plugin =
  GoogleSignInPlatform.instance as GoogleSignInPlugin;

  plugin.init();

  return plugin.renderButton(
    configuration: GSIButtonConfiguration(
      theme: GSIButtonTheme.filledBlue,
      text: GSIButtonText.signinWith,
      shape: GSIButtonShape.pill,
    ),
  );
}