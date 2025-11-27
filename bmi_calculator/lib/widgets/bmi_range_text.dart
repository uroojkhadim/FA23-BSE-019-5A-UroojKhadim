// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'constants/color_constants.dart';
import 'constants/spacing_constants.dart';

/// BMI Range Text Widget
/// Displays BMI ranges with color coding
class BMIRangeText extends StatelessWidget {
  /// BMI range label
  final String label;
  
  /// Minimum BMI value
  final double minValue;
  
  /// Maximum BMI value
  final double maxValue;
  
  /// Color associated with this range
  final Color color;

  /// Constructor for BMIRangeText
  const BMIRangeText({
    Key? key,
    required this.label,
    required this.minValue,
    required this.maxValue,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14.0,
            ),
          ),
          const SizedBox(height: SpacingConstants.small),
          Text(
            '${minValue.toStringAsFixed(1)} - ${maxValue.toStringAsFixed(1)}',
            style: const TextStyle(
              color: ColorConstants.darkText,
              fontSize: 12.0,
            ),
          ),
        ],
      ),
    );
  }
}