// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'constants/color_constants.dart';
import 'constants/text_style_constants.dart';
import 'constants/spacing_constants.dart';
import 'constants/container_constants.dart';

/// Custom theme data class for the BMI calculator
/// Contains all styling information for consistent UI across the app
class BMICalculatorTheme {
  /// Light theme configuration with custom colors and styling
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: ColorConstants.lightBackground,
    appBarTheme: const AppBarTheme(
      backgroundColor: ColorConstants.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: TextStyleConstants.mediumTitle,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorConstants.buttonColor,
        foregroundColor: ColorConstants.buttonTextColor,
        padding: SpacingConstants.buttonPadding,
        textStyle: TextStyleConstants.buttonText,
        shape: RoundedRectangleBorder(
          borderRadius: ContainerConstants.defaultBorderRadius,
        ),
        elevation: 8,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: ContainerConstants.smallBorderRadius,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: ContainerConstants.smallBorderRadius,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: ContainerConstants.smallBorderRadius,
        borderSide: const BorderSide(color: ColorConstants.inputFieldBorder, width: 2),
      ),
      filled: true,
      fillColor: ColorConstants.inputFieldBackground,
      contentPadding: SpacingConstants.inputPadding,
      labelStyle: TextStyleConstants.inputLabel,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyleConstants.smallTitle,
      bodyLarge: TextStyleConstants.mediumBody,
    ),
  );

  // Color scheme for different BMI categories
  static const Map<String, Color> bmiCategoryColors = {
    'Underweight': ColorConstants.underweightColor,
    'Normal weight': ColorConstants.normalWeightColor,
    'Overweight': ColorConstants.overweightColor,
    'Obese': ColorConstants.obeseColor,
  };

  // Get color for BMI category
  static Color getBMIColor(String category) {
    return bmiCategoryColors[category] ?? Colors.grey;
  }
}