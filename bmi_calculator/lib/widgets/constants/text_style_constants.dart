// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'color_constants.dart';

/// Constants for text styles used throughout the BMI calculator app
class TextStyleConstants {
  /// Large title style
  static const TextStyle largeTitle = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: ColorConstants.darkText,
  );
  
  /// Medium title style
  static const TextStyle mediumTitle = TextStyle(
    fontSize: 22.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  /// Small title style
  static const TextStyle smallTitle = TextStyle(
    fontSize: 20.0,
    fontWeight: FontWeight.bold,
    color: ColorConstants.darkText,
  );
  
  /// Large body style
  static const TextStyle largeBody = TextStyle(
    fontSize: 18.0,
    color: ColorConstants.mediumText,
  );
  
  /// Medium body style
  static const TextStyle mediumBody = TextStyle(
    fontSize: 16.0,
    color: ColorConstants.mediumText,
  );
  
  /// Small body style
  static const TextStyle smallBody = TextStyle(
    fontSize: 14.0,
    color: ColorConstants.lightText,
  );
  
  /// BMI value style
  static const TextStyle bmiValue = TextStyle(
    fontSize: 56.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  /// BMI category style
  static const TextStyle bmiCategory = TextStyle(
    fontSize: 24.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  /// BMI description style
  static const TextStyle bmiDescription = TextStyle(
    fontSize: 16.0,
    color: Colors.white,
  );
  
  /// Scale label style
  static const TextStyle scaleLabel = TextStyle(
    fontSize: 12.0,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  /// Input label style
  static const TextStyle inputLabel = TextStyle(
    fontSize: 16.0,
    color: Colors.grey,
  );
  
  /// Button text style
  static const TextStyle buttonText = TextStyle(
    fontSize: 18.0,
    fontWeight: FontWeight.bold,
  );
}