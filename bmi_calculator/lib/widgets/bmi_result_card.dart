// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'repeat_container.dart';
import 'text_widgets.dart';
import '../widgets/app_theme.dart';

/// BMI Result Card Widget
/// Displays the calculated BMI result with category and visualization
class BMIResultCard extends StatelessWidget {
  /// Calculated BMI value
  final double bmi;
  
  /// BMI category (Underweight, Normal, etc.)
  final String category;
  
  /// Color associated with the BMI category
  final Color color;

  /// Constructor for BMIResultCard
  const BMIResultCard({
    Key? key,
    required this.bmi,
    required this.category,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepeatContainer(
      color: color, // Use category color as background
      borderRadius: BorderRadius.circular(20), // More rounded corners
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15), // Darker shadow for emphasis
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
      child: Column(
        children: [
          // Result title
          const BMIResultHeaderText(),
          const SizedBox(height: 15),
          // Large BMI value display
          BMIValueText(bmi: bmi),
          const SizedBox(height: 10),
          // BMI category display
          CategoryLabelText(category: category),
          const SizedBox(height: 15),
          // Visual BMI scale representation
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3), // Semi-transparent background
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                // Underweight section (blue)
                Expanded(
                  flex: 185,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        bottomLeft: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
                // Normal weight section (green)
                Expanded(
                  flex: 650,
                  child: Container(
                    color: Colors.green,
                  ),
                ),
                // Overweight section (orange)
                Expanded(
                  flex: 500,
                  child: Container(
                    color: Colors.orange,
                  ),
                ),
                // Obese section (red)
                Expanded(
                  flex: 700,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          // Labels for the BMI scale
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ScaleLabelText(text: 'Under'),
              ScaleLabelText(text: 'Normal'),
              ScaleLabelText(text: 'Over'),
              ScaleLabelText(text: 'Obese'),
            ],
          ),
          const SizedBox(height: 15),
          // Description based on BMI category
          CategoryDescriptionText(description: _getBMIDescription(category)),
        ],
      ),
    );
  }
  
  /// Get descriptive text for each BMI category
  static String _getBMIDescription(String category) {
    switch (category) {
      case 'Underweight':
        return 'You may need to gain weight. Consult with a healthcare provider.';
      case 'Normal weight':
        return 'Congratulations! You have a healthy weight.';
      case 'Overweight':
        return 'Consider adopting healthier eating habits and increasing physical activity.';
      case 'Obese':
        return 'It\'s recommended to consult with a healthcare provider for a weight loss plan.';
      default:
        return '';
    }
  }
}