// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'icon_widgets.dart';
import 'input_method.dart';

/// Input Method Toggle Widget
/// Provides a button to switch between text input and slider input methods
class InputMethodToggle extends StatelessWidget {
  /// Flag indicating whether sliders are currently being used
  final bool useSliders;
  
  /// Callback function to execute when the toggle is pressed
  final VoidCallback onToggle;

  /// Constructor for InputMethodToggle
  const InputMethodToggle({
    Key? key,
    required this.useSliders,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use ternary operators to determine current and next methods
    final InputMethod currentMethod = useSliders ? InputMethod.slider : InputMethod.text;
    final InputMethod nextMethod = currentMethod == InputMethod.text ? InputMethod.slider : InputMethod.text;
    
    return IconButton(
      icon: nextMethod.icon, // Toggle icon from enum
      onPressed: onToggle, // Execute callback when pressed
      tooltip: nextMethod.tooltip, // Tooltip from enum
    );
  }
}