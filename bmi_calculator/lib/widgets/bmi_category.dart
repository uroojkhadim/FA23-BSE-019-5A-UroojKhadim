// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'app_theme.dart';

/// Enum representing different BMI categories
enum BMICategory {
  underweight,
  normal,
  overweight,
  obese;

  /// Get the display name for the BMI category
  String get displayName {
    switch (this) {
      case BMICategory.underweight:
        return 'Underweight';
      case BMICategory.normal:
        return 'Normal weight';
      case BMICategory.overweight:
        return 'Overweight';
      case BMICategory.obese:
        return 'Obese';
    }
  }

  /// Get the color associated with the BMI category
  Color get color {
    switch (this) {
      case BMICategory.underweight:
        return BMICalculatorTheme.getBMIColor('Underweight');
      case BMICategory.normal:
        return BMICalculatorTheme.getBMIColor('Normal weight');
      case BMICategory.overweight:
        return BMICalculatorTheme.getBMIColor('Overweight');
      case BMICategory.obese:
        return BMICalculatorTheme.getBMIColor('Obese');
    }
  }

  /// Get the description for the BMI category
  String get description {
    switch (this) {
      case BMICategory.underweight:
        return 'You may need to gain weight. Consult with a healthcare provider.';
      case BMICategory.normal:
        return 'Congratulations! You have a healthy weight.';
      case BMICategory.overweight:
        return 'Consider adopting healthier eating habits and increasing physical activity.';
      case BMICategory.obese:
        return 'It\'s recommended to consult with a healthcare provider for a weight loss plan.';
    }
  }

  /// Get detailed information about the BMI category
  String get detailedInfo {
    switch (this) {
      case BMICategory.underweight:
        return 'BMI below 18.5. Consider consulting a nutritionist for a healthy weight gain plan.';
      case BMICategory.normal:
        return 'BMI between 18.5 and 24.9. Maintain your healthy lifestyle!';
      case BMICategory.overweight:
        return 'BMI between 25 and 29.9. Small dietary and exercise changes can make a big difference.';
      case BMICategory.obese:
        return 'BMI of 30 or higher. Professional medical guidance is recommended for safe weight loss.';
    }
  }
}