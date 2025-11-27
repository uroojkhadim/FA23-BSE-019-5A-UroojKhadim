// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'bmi_category.dart';

/// Utility class for BMI calculation logic
class BMICalculatorUtils {
  /// Calculate BMI based on height (in meters) and weight (in kg)
  static double calculateBMI(double heightInMeters, double weight) {
    return weight / (heightInMeters * heightInMeters);
  }

  /// Determine BMI category based on calculated value
  static BMICategory getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return BMICategory.underweight;
    } else if (bmi >= 18.5 && bmi < 25) {
      return BMICategory.normal;
    } else if (bmi >= 25 && bmi < 30) {
      return BMICategory.overweight;
    } else {
      return BMICategory.obese;
    }
  }

  /// Get color associated with BMI category
  static Color getBMIColor(BMICategory category) {
    return category.color;
  }
}