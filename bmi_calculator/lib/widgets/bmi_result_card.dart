// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'repeat_container.dart';
import 'text_widgets.dart';
import '../widgets/app_theme.dart';
import 'bmi_category.dart';
import 'constants/container_constants.dart';
import 'constants/color_constants.dart';
import 'constants/spacing_constants.dart';

/// BMI Result Card Widget
/// Displays the calculated BMI result with category and visualization
class BMIResultCard extends StatelessWidget {
  /// Calculated BMI value
  final double bmi;
  
  /// BMI category (Underweight, Normal, etc.)
  final BMICategory category;
  
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
      borderRadius: ContainerConstants.largeBorderRadius, // More rounded corners
      boxShadow: ContainerConstants.emphasizedBoxShadow,
      child: Column(
        children: [
          // Result title
          const BMIResultHeaderText(),
          const SizedBox(height: SpacingConstants.large),
          // Large BMI value display
          BMIValueText(bmi: bmi),
          const SizedBox(height: SpacingConstants.medium),
          // BMI category display
          CategoryLabelText(category: category.displayName),
          const SizedBox(height: SpacingConstants.large),
          // Visual BMI scale representation
          Container(
            height: ContainerConstants.bmiScaleHeight,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3), // Semi-transparent background
              borderRadius: ContainerConstants.smallBorderRadius,
            ),
            child: Row(
              children: [
                // Underweight section (blue)
                Expanded(
                  flex: 185,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: ColorConstants.underweightColor,
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
                    color: ColorConstants.normalWeightColor,
                  ),
                ),
                // Overweight section (orange)
                Expanded(
                  flex: 500,
                  child: Container(
                    color: ColorConstants.overweightColor,
                  ),
                ),
                // Obese section (red)
                Expanded(
                  flex: 700,
                  child: Container(
                    decoration: const BoxDecoration(
                      color: ColorConstants.obeseColor,
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
          const SizedBox(height: SpacingConstants.medium),
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
          const SizedBox(height: SpacingConstants.large),
          // Description based on BMI category
          CategoryDescriptionText(description: category.description),
        ],
      ),
    );
  }
}