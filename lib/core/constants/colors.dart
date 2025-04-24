import 'package:flutter/material.dart';

class AppColors {
  // Solid Colors
  static const Color white = Color(0xFFFCF5FD);

  // Linear Gradients
  static const LinearGradient purpleGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF21014B), Color(0xFF4D0060)],
  );

  static const LinearGradient orangeGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [Color(0xFFFF6B00), Color(0xFFFF007A)],
  );

  static const Color purple = Color(0xFF4D0060);
  static const Color middlePurple = Color(0xFF6b3279);
  static const Color lightPurple = Color(0xFFca84d7);
  static const Color darkPurple = Color(0xFF4a2951);
  static const Color deepPinkPurple = Color.fromRGBO(175, 56, 125, 0.3);
  static const Color lightLavender = Color(0xFFE5CFEE);
  static const Color softLavender = Color(0xFFF3DDFC);
  static const Color delicatePink = Color(0xFFFFECFF);
  static const Color orange = Color(0xFFFF6B00);
  static const Color softOrange = Color(0xFFFF9437);
  static const Color pink = Color(0xFFFF007A);
  static const Color blue = Color(0xFF1DD3D8);
  static const Color darkBlue = Color(0xFF363D7B);
}