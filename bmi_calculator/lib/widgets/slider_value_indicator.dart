// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'constants/color_constants.dart';

/// Slider Value Indicator Widget
/// Displays the current value of a slider with enhanced styling
class SliderValueIndicator extends StatelessWidget {
  /// Label for the slider (e.g., 'Height:')
  final String label;
  
  /// Current value to display
  final String value;
  
  /// Unit of measurement (e.g., 'cm', 'kg')
  final String unit;

  /// Constructor for SliderValueIndicator
  const SliderValueIndicator({
    Key? key,
    required this.label,
    required this.value,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorConstants.darkText,
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.green[100],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            '$value $unit',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: ColorConstants.darkText,
            ),
          ),
        ),
      ],
    );
  }
}