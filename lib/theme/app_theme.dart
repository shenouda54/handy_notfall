import 'package:flutter/material.dart';

class AppTheme {
  // Brand Colors
  static const Color primaryColor = Color(0xFFB71C1C); // Darker Red (Burgundy) - Classy & Easy on eyes
  static const Color secondaryColor = Color(0xFFD32F2F); // Slightly lighter red for accents
  
  // Dark Theme Colors
  static const Color darkBackground = Color(0xFF000000);
  static const Color darkSurface = Color(0xFF1E1E1E);
  static const Color darkText = Colors.white;
  
  // Light Theme Colors
  static const Color lightBackground = Color(0xFFF5F5F5);
  static const Color lightSurface = Colors.white;
  static const Color lightText = Color(0xFF212121);

  // ================= DARK THEME =================
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: darkBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.dark,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: darkSurface,
        error: const Color(0xFFCF6679),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: darkText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor, // Red AppBar
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.redAccent,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade800)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 2)),
        labelStyle: TextStyle(color: Colors.grey.shade400),
        prefixIconColor: Colors.grey.shade400,
      ),
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 8,
        shadowColor: Colors.black.withOpacity(0.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }

  // ================= LIGHT THEME =================
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryColor,
      scaffoldBackgroundColor: lightBackground,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primaryColor,
        brightness: Brightness.light,
        primary: primaryColor,
        secondary: secondaryColor,
        surface: lightSurface,
        error: const Color(0xFFD32F2F),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: lightText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryColor, // Red AppBar
        foregroundColor: Colors.white,
        elevation: 4,
        shadowColor: Colors.black26,
        centerTitle: true,
        titleTextStyle: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 1.0, color: Colors.white),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: lightSurface,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primaryColor, width: 2)),
        labelStyle: TextStyle(color: Colors.grey.shade700),
        prefixIconColor: Colors.grey.shade600,
      ),
      cardTheme: CardThemeData(
        color: lightSurface,
        elevation: 4,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: const EdgeInsets.all(12),
      ),
    );
  }
}
