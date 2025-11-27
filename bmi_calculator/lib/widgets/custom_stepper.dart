// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'constants/color_constants.dart';
import 'constants/spacing_constants.dart';

/// Custom Stepper Widget
/// A reusable stepper with enhanced styling and functionality
class CustomStepper extends StatelessWidget {
  /// Current value of the stepper
  final int value;
  
  /// Minimum value of the stepper
  final int minValue;
  
  /// Maximum value of the stepper
  final int maxValue;
  
  /// Callback function when decrement button is pressed
  final Function() onDecrement;
  
  /// Callback function when increment button is pressed
  final Function() onIncrement;
  
  /// Decrement button color
  final Color decrementButtonColor;
  
  /// Increment button color
  final Color incrementButtonColor;
  
  /// Value display color
  final Color valueDisplayColor;

  /// Constructor for CustomStepper
  const CustomStepper({
    Key? key,
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.onDecrement,
    required this.onIncrement,
    this.decrementButtonColor = Colors.red,
    this.incrementButtonColor = Colors.green,
    this.valueDisplayColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Decrease button with enhanced styling
        Container(
          decoration: BoxDecoration(
            color: decrementButtonColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.remove, color: decrementButtonColor),
            onPressed: onDecrement,
          ),
        ),
        
        const SizedBox(width: SpacingConstants.large),
        
        // Display current value with enhanced styling
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          decoration: BoxDecoration(
            color: valueDisplayColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$value',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: ColorConstants.darkText,
            ),
          ),
        ),
        
        const SizedBox(width: SpacingConstants.large),
        
        // Increase button with enhanced styling
        Container(
          decoration: BoxDecoration(
            color: incrementButtonColor.withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(Icons.add, color: incrementButtonColor),
            onPressed: onIncrement,
          ),
        ),
      ],
    );
  }
}