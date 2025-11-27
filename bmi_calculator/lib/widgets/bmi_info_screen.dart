// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'package:bmi_calculator/widgets/app_theme.dart';
import 'package:bmi_calculator/widgets/constants/color_constants.dart';
import 'package:bmi_calculator/widgets/constants/text_style_constants.dart';
import 'package:bmi_calculator/widgets/constants/spacing_constants.dart';

/// BMI Information Screen
/// Displays detailed information about BMI categories and health tips
class BMIInfoScreen extends StatelessWidget {
  /// Constructor for BMIInfoScreen
  const BMIInfoScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Information'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: SpacingConstants.defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Understanding BMI',
                style: TextStyleConstants.largeTitle,
              ),
              const SizedBox(height: SpacingConstants.medium),
              const Text(
                'Body Mass Index (BMI) is a person\'s weight in kilograms divided by the square of height in meters. BMI is an inexpensive and easy screening method for weight category—underweight, healthy weight, overweight, and obesity.',
                style: TextStyleConstants.mediumBody,
              ),
              const SizedBox(height: SpacingConstants.large),
              
              const Text(
                'BMI Categories',
                style: TextStyleConstants.mediumTitle,
              ),
              const SizedBox(height: SpacingConstants.medium),
              
              _buildBMICategoryCard(
                'Underweight',
                'BMI less than 18.5',
                ColorConstants.underweightColor,
              ),
              const SizedBox(height: SpacingConstants.small),
              
              _buildBMICategoryCard(
                'Normal weight',
                'BMI 18.5–24.9',
                ColorConstants.normalWeightColor,
              ),
              const SizedBox(height: SpacingConstants.small),
              
              _buildBMICategoryCard(
                'Overweight',
                'BMI 25–29.9',
                ColorConstants.overweightColor,
              ),
              const SizedBox(height: SpacingConstants.small),
              
              _buildBMICategoryCard(
                'Obesity',
                'BMI 30 or greater',
                ColorConstants.obeseColor,
              ),
              const SizedBox(height: SpacingConstants.large),
              
              const Text(
                'BMI Formula',
                style: TextStyleConstants.mediumTitle,
              ),
              const SizedBox(height: SpacingConstants.medium),
              
              Container(
                padding: SpacingConstants.defaultPadding,
                decoration: BoxDecoration(
                  color: ColorConstants.lightBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ColorConstants.primaryGreen.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'BMI = weight (kg) / [height (m)]²',
                      style: TextStyleConstants.mediumBody,
                    ),
                    const SizedBox(height: SpacingConstants.small),
                    const Text(
                      'Example: If you weigh 70 kg and are 1.75 m tall, your BMI is:',
                      style: TextStyleConstants.smallBody,
                    ),
                    const SizedBox(height: SpacingConstants.small),
                    const Text(
                      'BMI = 70 / (1.75)² = 22.9',
                      style: TextStyleConstants.mediumBody,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingConstants.large),
              
              const Text(
                'Health Tips',
                style: TextStyleConstants.mediumTitle,
              ),
              const SizedBox(height: SpacingConstants.medium),
              
              _buildHealthTip(
                'Maintain a Balanced Diet',
                'Eat a variety of foods from all food groups to ensure you get the nutrients you need.',
              ),
              const SizedBox(height: SpacingConstants.small),
              
              _buildHealthTip(
                'Stay Active',
                'Regular physical activity helps maintain a healthy weight and reduces health risks.',
              ),
              const SizedBox(height: SpacingConstants.small),
              
              _buildHealthTip(
                'Monitor Your Progress',
                'Regularly check your BMI to stay aware of changes in your weight status.',
              ),
              const SizedBox(height: SpacingConstants.small),
              
              _buildHealthTip(
                'Consult a Healthcare Professional',
                'If you have concerns about your BMI or weight, consult with a doctor or nutritionist.',
              ),
              const SizedBox(height: SpacingConstants.large),
              
              const Text(
                'Limitations of BMI',
                style: TextStyleConstants.mediumTitle,
              ),
              const SizedBox(height: SpacingConstants.medium),
              
              Container(
                padding: SpacingConstants.defaultPadding,
                decoration: BoxDecoration(
                  color: ColorConstants.lightBackground,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• BMI may not accurately reflect body fatness for all individuals',
                      style: TextStyleConstants.smallBody,
                    ),
                    SizedBox(height: SpacingConstants.small),
                    Text(
                      '• Athletes may have high BMI due to muscle mass rather than fat',
                      style: TextStyleConstants.smallBody,
                    ),
                    SizedBox(height: SpacingConstants.small),
                    Text(
                      '• BMI may not be accurate for elderly people or pregnant women',
                      style: TextStyleConstants.smallBody,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: SpacingConstants.large),
              
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Back to Calculator'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a card displaying BMI category information
  Widget _buildBMICategoryCard(String category, String range, Color color) {
    return Container(
      padding: SpacingConstants.defaultPadding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            category,
            style: TextStyleConstants.smallTitle.copyWith(color: color),
          ),
          const SizedBox(height: SpacingConstants.small),
          Text(
            range,
            style: TextStyleConstants.mediumBody,
          ),
        ],
      ),
    );
  }

  /// Builds a card displaying health tips
  Widget _buildHealthTip(String title, String description) {
    return Container(
      padding: SpacingConstants.defaultPadding,
      decoration: BoxDecoration(
        color: ColorConstants.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: ColorConstants.primaryGreen.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyleConstants.smallTitle.copyWith(color: ColorConstants.primaryGreen),
          ),
          const SizedBox(height: SpacingConstants.small),
          Text(
            description,
            style: TextStyleConstants.mediumBody,
          ),
        ],
      ),
    );
  }
}