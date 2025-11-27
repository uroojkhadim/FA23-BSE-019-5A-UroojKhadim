// Import the Flutter material design library
import 'package:flutter/material.dart';

/// Constants for container styling throughout the BMI calculator app
class ContainerConstants {
  /// Default padding for containers
  static const EdgeInsets defaultPadding = EdgeInsets.all(20.0);
  
  /// Default margin for containers
  static const EdgeInsets defaultMargin = EdgeInsets.all(0.0);
  
  /// Default border radius for containers
  static const BorderRadius defaultBorderRadius = BorderRadius.all(Radius.circular(15.0));
  
  /// Large border radius for containers
  static const BorderRadius largeBorderRadius = BorderRadius.all(Radius.circular(20.0));
  
  /// Small border radius for containers
  static const BorderRadius smallBorderRadius = BorderRadius.all(Radius.circular(10.0));
  
  /// Default box shadow for containers
  static const List<BoxShadow> defaultBoxShadow = [
    BoxShadow(
      color: Color(0x33000000), // Grey with opacity
      spreadRadius: 2,
      blurRadius: 5,
      offset: Offset(0, 3),
    ),
  ];
  
  /// Emphasized box shadow for containers
  static const List<BoxShadow> emphasizedBoxShadow = [
    BoxShadow(
      color: Color(0x26000000), // Black with opacity
      blurRadius: 15,
      offset: Offset(0, 5),
    ),
  ];
  
  /// No box shadow
  static const List<BoxShadow> noBoxShadow = [];
  
  /// Default container color
  static const Color defaultColor = Colors.white;
  
  /// Container height for BMI scale
  static const double bmiScaleHeight = 20.0;
  
  /// Container width for BMI category indicators
  static const double categoryIndicatorWidth = 10.0;
}