import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    // Use Material 3
    useMaterial3: true,

    // Define the default brightness and colors.
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF000000), // Dark theme primary color
      brightness: Brightness.light,
    ),

    // Define the default font family (optional).
    // fontFamily: 'Georgia',

    // Define the default `TextTheme`.
    textTheme: const TextTheme(
      displayLarge: TextStyle(
          fontSize: 60.0, fontWeight: FontWeight.bold, color: Colors.black),
      titleLarge: TextStyle(
          fontSize: 28.0, fontWeight: FontWeight.w700, color: Colors.black),
      bodyMedium: TextStyle(fontSize: 16.0, color: Colors.black54),
      // Define other text styles if needed
    ),

    // Define AppBar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF000000), // Dark theme app bar
      foregroundColor: Colors.white, // Title/icon color
      elevation: 2,
      centerTitle: true,
    ),

    // Define ElevatedButton theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF000000), // Button background
        foregroundColor: Colors.white, // Button text/icon color
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),

    // Define Card theme
    cardTheme: CardTheme(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
    ),

    // Define Input theme
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: const BorderSide(color: Color(0xFFFFC107), width: 2.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      // Define label style, hint style etc. if needed
    ),

    // Add other component themes (TextButton, BottomNavigationBar, etc.) as needed
  );

  // Optional: Define a dark theme
  // static final ThemeData darkTheme = ThemeData(...);
}
