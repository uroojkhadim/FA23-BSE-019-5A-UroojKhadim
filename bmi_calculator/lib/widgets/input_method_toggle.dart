// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'icon_widgets.dart';

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
    return IconButton(
      icon: useSliders ? const TextInputIcon() : const SliderInputIcon(), // Toggle icon
      onPressed: onToggle, // Execute callback when pressed
      tooltip: useSliders ? 'Switch to Text Fields' : 'Switch to Sliders',
    );
  }
}