// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Utility class for BMI calculation logic
class BMICalculatorUtils {
  /// Calculate BMI based on height (in meters) and weight (in kg)
  static double calculateBMI(double heightInMeters, double weight) {
    return weight / (heightInMeters * heightInMeters);
  }

  /// Determine BMI category based on calculated value
  static String getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Normal weight';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  /// Get color associated with BMI category
  static Color getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return BMICalculatorTheme.getBMIColor('Underweight');
    } else if (bmi >= 18.5 && bmi < 25) {
      return BMICalculatorTheme.getBMIColor('Normal weight');
    } else if (bmi >= 25 && bmi < 30) {
      return BMICalculatorTheme.getBMIColor('Overweight');
    } else {
      return BMICalculatorTheme.getBMIColor('Obese');
    }
  }
}