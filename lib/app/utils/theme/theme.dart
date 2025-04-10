import 'package:flutter/material.dart';

class AppTheme {
  static final ThemeData lightTheme = ThemeData(
    // Use Material 3
    useMaterial3: true,

    // Define the default brightness and colors.
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFFFC107), // Amber/Gold - Primary Seed Color
      // You can optionally define other colors like secondary, error, etc.
      // secondary: Colors.blue,
      brightness: Brightness.light,
    ),

    // Define the default font family (optional).
    // fontFamily: 'Georgia',

    // Define the default `TextTheme`.
    textTheme: const TextTheme(
      displayLarge: TextStyle(fontSize: 72.0, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.w600),
      bodyMedium: TextStyle(fontSize: 14.0),
      // Define other text styles if needed
    ),

    // Define AppBar theme
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFC107), // Match primary seed
      foregroundColor: Colors.black, // Title/icon color
      elevation: 2,
      centerTitle: true,
    ),

    // Define ElevatedButton theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFFFC107), // Button background
        foregroundColor: Colors.black, // Button text/icon color
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
