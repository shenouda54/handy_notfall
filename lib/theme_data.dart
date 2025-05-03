import 'package:flutter/material.dart';

final ThemeData handyNotfallTheme = ThemeData(
  primaryColor: const Color(0xFFE53935),
  // اللون الأحمر الأساسي
  scaffoldBackgroundColor: const Color(0xFF000000),
  // تعيين الخلفية السوداء
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF000000), // لون شريط التطبيق
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontSize: 20.0,
      fontWeight: FontWeight.bold,
    ),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.white), // النصوص العامة الحديثة
    bodyMedium: TextStyle(color: Colors.white70), // النصوص الثانوية الحديثة
    displayLarge: TextStyle(
      color: Color(0xFFE53935), // الأحمر للعناوين الكبيرة
      fontSize: 28.0,
      fontWeight: FontWeight.bold,
    ),
    displayMedium: TextStyle(
      color: Colors.white, // الأبيض للعناوين المتوسطة
      fontSize: 24.0,
      fontWeight: FontWeight.bold,
    ),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFE53935), // لون زر بالأحمر
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 16.0),
      textStyle: const TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),
  ),
);
