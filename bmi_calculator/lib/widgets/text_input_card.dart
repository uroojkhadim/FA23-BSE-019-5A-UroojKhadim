// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'repeat_container.dart';
import 'icon_widgets.dart';
import 'bmi_calculator_callbacks.dart';

/// Text Input Card Widget
/// Displays input fields for height and weight using text fields
class TextInputCard extends StatelessWidget {
  /// Controller for the height text field
  final TextEditingController heightController;
  
  /// Controller for the weight text field
  final TextEditingController weightController;

  /// Constructor for TextInputCard
  const TextInputCard({
    Key? key,
    required this.heightController,
    required this.weightController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepeatContainer(
      child: Column(
        children: [
          // Height input field with icon
          TextField(
            controller: heightController,
            keyboardType: TextInputType.number, // Only accept numbers
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              prefixIcon: HeightIcon(), // Custom height icon
            ),
            // Add function object for validation on change
            onChanged: (value) {
              _validateInput(value, 'height', context);
            },
          ),
          const SizedBox(height: 20), // Spacing between fields
          // Weight input field with icon
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number, // Only accept numbers
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              prefixIcon: WeightIcon(), // Custom weight icon
            ),
            // Add function object for validation on change
            onChanged: (value) {
              _validateInput(value, 'weight', context);
            },
          ),
        ],
      ),
    );
  }
  
  /// Function object for input validation
  void _validateInput(String value, String fieldName, BuildContext context) {
    // Create function object for input validation
    final validator = BMICalculatorCallbacks.createInputValidator(
      fieldName == 'height' ? value : '',
      fieldName == 'weight' ? value : '',
      (isValid, message) {
        // For individual field validation, we just log the result
        // The main validation happens during calculation
      },
    );
    
    // Execute validation if value is not empty
    if (value.isNotEmpty) {
      validator();
    }
  }
}