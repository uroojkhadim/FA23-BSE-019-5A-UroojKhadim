// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'repeat_container.dart';
import 'icon_widgets.dart';

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
          ),
        ],
      ),
    );
  }
}