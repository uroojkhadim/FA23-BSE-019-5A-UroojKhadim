// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'bmi_category.dart';

/// Callback function type for BMI calculation
typedef BMICallback = void Function(double bmi, BMICategory category);

/// Callback function type for input method toggle
typedef InputMethodCallback = void Function();

/// Callback function type for height changes
typedef HeightChangeCallback = void Function(double height);

/// Callback function type for weight changes
typedef WeightChangeCallback = void Function(int weight);

/// Callback function type for showing messages
typedef MessageCallback = void Function(String message);

/// Callback function type for resetting values
typedef ResetCallback = void Function();

/// Callback function type for input validation
typedef ValidationCallback = void Function(bool isValid, String message);

/// Utility class for BMI calculator callbacks
class BMICalculatorCallbacks {
  /// Function object for calculating BMI
  static Function createBMICalculator(
    double height, 
    double weight, 
    BMICallback onResult,
    MessageCallback onError,
  ) {
    return () {
      // Validate inputs
      if (height <= 0 || weight <= 0) {
        onError('Please enter valid height and weight values');
        return;
      }
      
      // Calculate BMI
      final heightInMeters = height / 100; // Convert cm to meters
      final bmi = weight / (heightInMeters * heightInMeters);
      
      // Determine category
      final category = _getBMICategory(bmi);
      
      // Return result through callback
      onResult(bmi, category);
    };
  }
  
  /// Function object for validating inputs
  static Function createInputValidator(
    String heightText, 
    String weightText, 
    ValidationCallback onValidation,
  ) {
    return () {
      if (heightText.isEmpty || weightText.isEmpty) {
        onValidation(false, 'Please enter both height and weight');
      } else {
        try {
          final height = double.parse(heightText);
          final weight = double.parse(weightText);
          
          if (height <= 0 || weight <= 0) {
            onValidation(false, 'Please enter positive values');
          } else {
            onValidation(true, 'Inputs are valid');
          }
        } catch (e) {
          onValidation(false, 'Please enter valid numbers');
        }
      }
    };
  }
  
  /// Function object for toggling input method
  static Function createInputMethodToggle(
    InputMethodCallback onToggle,
  ) {
    return () {
      onToggle();
    };
  }
  
  /// Function object for handling height changes
  static Function createHeightChanger(
    double currentValue,
    double minValue,
    double maxValue,
    HeightChangeCallback onChange,
  ) {
    return (double newValue) {
      if (newValue >= minValue && newValue <= maxValue) {
        onChange(newValue);
      }
    };
  }
  
  /// Function object for handling weight changes
  static Function createWeightChanger(
    int currentValue,
    int minValue,
    int maxValue,
    WeightChangeCallback onChange,
  ) {
    return (int newValue) {
      if (newValue >= minValue && newValue <= maxValue) {
        onChange(newValue);
      }
    };
  }
  
  /// Function object for resetting all values
  static Function createResetFunction(
    ResetCallback onReset,
    MessageCallback onMessage,
  ) {
    return () {
      onReset();
      onMessage('All values have been reset');
    };
  }
  
  /// Function object for showing snack bar messages
  static Function createMessageShower(
    BuildContext context,
    String message,
    Color backgroundColor,
  ) {
    return () {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: backgroundColor,
        ),
      );
    };
  }
  
  /// Function object for conditional rendering
  static Function createConditionalRenderer(
    bool condition,
    Widget trueWidget,
    Widget falseWidget,
  ) {
    return () {
      return condition ? trueWidget : falseWidget;
    };
  }
  
  /// Helper function to determine BMI category
  static BMICategory _getBMICategory(double bmi) {
    return bmi < 18.5 
        ? BMICategory.underweight 
        : bmi < 25 
            ? BMICategory.normal 
            : bmi < 30 
                ? BMICategory.overweight 
                : BMICategory.obese;
  }
}