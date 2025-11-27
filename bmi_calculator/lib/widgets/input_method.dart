// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'icon_widgets.dart';

/// Enum representing different input methods for the BMI calculator
enum InputMethod {
  text,
  slider;

  /// Get the icon for the input method
  Widget get icon {
    switch (this) {
      case InputMethod.text:
        return const TextInputIcon();
      case InputMethod.slider:
        return const SliderInputIcon();
    }
  }

  /// Get the tooltip for the input method
  String get tooltip {
    switch (this) {
      case InputMethod.text:
        return 'Switch to Text Fields';
      case InputMethod.slider:
        return 'Switch to Sliders';
    }
  }

  /// Get the opposite input method
  InputMethod get toggle {
    switch (this) {
      case InputMethod.text:
        return InputMethod.slider;
      case InputMethod.slider:
        return InputMethod.text;
    }
  }
}