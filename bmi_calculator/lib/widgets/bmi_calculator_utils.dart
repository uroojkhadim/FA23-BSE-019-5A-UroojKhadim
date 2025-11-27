// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'bmi_category.dart';

/// Utility class for BMI calculation logic
class BMICalculatorUtils {
  /// Calculate BMI based on height (in meters) and weight (in kg)
  static double calculateBMI(double heightInMeters, double weight) {
    // Use ternary operator to prevent division by zero
    return heightInMeters > 0 ? weight / (heightInMeters * heightInMeters) : 0.0;
  }

  /// Determine BMI category based on calculated value
  static BMICategory getBMICategory(double bmi) {
    // Use ternary operators to determine category
    return bmi < 18.5 
        ? BMICategory.underweight 
        : bmi < 25 
            ? BMICategory.normal 
            : bmi < 30 
                ? BMICategory.overweight 
                : BMICategory.obese;
  }

  /// Get color associated with BMI category
  static Color getBMIColor(BMICategory category) {
    return category.color;
  }
}