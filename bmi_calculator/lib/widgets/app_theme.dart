// Import the Flutter material design library
import 'package:flutter/material.dart';

/// Custom theme data class for the BMI calculator
/// Contains all styling information for consistent UI across the app
class BMICalculatorTheme {
  /// Light theme configuration with custom colors and styling
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: const Color(0xFFE8F5E9), // Light green background
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.green, // Green app bar
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // Green buttons
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Rounded buttons
        ),
        elevation: 8,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      filled: true,
      fillColor: Colors.white, // White input fields
      contentPadding: const EdgeInsets.all(20),
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black54,
      ),
    ),
  );

  // Color scheme for different BMI categories
  static const Map<String, Color> bmiCategoryColors = {
    'Underweight': Colors.blue,
    'Normal weight': Colors.green,
    'Overweight': Colors.orange,
    'Obese': Colors.red,
  };

  // Get color for BMI category
  static Color getBMIColor(String category) {
    return bmiCategoryColors[category] ?? Colors.grey;
  }
}