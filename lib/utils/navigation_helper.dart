import 'package:flutter/material.dart';
import '../pages/auth_screen.dart';

void navigateToAuthScreen(BuildContext context) {
  Navigator.of(context).pushAndRemoveUntil(
    MaterialPageRoute(builder: (context) => AuthScreen()), // ✅ เอา const ออก
    (Route<dynamic> route) => false,
  );
}