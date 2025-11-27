// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'constants/text_style_constants.dart';
import 'constants/spacing_constants.dart';

/// Title text widget for the app
class AppTitleText extends StatelessWidget {
  const AppTitleText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Calculate Your Body Mass Index',
      textAlign: TextAlign.center,
      style: TextStyleConstants.largeTitle,
    );
  }
}

/// Description text widget for the app
class AppDescriptionText extends StatelessWidget {
  const AppDescriptionText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Enter your height and weight to calculate BMI',
      textAlign: TextAlign.center,
      style: TextStyleConstants.largeBody,
    );
  }
}

/// Header text widget for BMI result section
class BMIResultHeaderText extends StatelessWidget {
  const BMIResultHeaderText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Your BMI Result',
      style: TextStyleConstants.mediumTitle,
    );
  }
}

/// Category label text widget
class CategoryLabelText extends StatelessWidget {
  final String category;

  const CategoryLabelText({Key? key, required this.category}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      category,
      style: TextStyleConstants.bmiCategory,
    );
  }
}

/// Scale label text widget
class ScaleLabelText extends StatelessWidget {
  final String text;

  const ScaleLabelText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyleConstants.scaleLabel,
    );
  }
}

/// Description text widget for BMI categories
class CategoryDescriptionText extends StatelessWidget {
  final String description;

  const CategoryDescriptionText({Key? key, required this.description}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      description,
      textAlign: TextAlign.center,
      style: TextStyleConstants.bmiDescription,
    );
  }
}

/// Height value text widget
class HeightValueText extends StatelessWidget {
  final double height;

  const HeightValueText({Key? key, required this.height}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      'Height: ${height.round()} cm',
      style: TextStyleConstants.smallTitle,
    );
  }
}

/// Weight value text widget
class WeightValueText extends StatelessWidget {
  final int weight;

  const WeightValueText({Key? key, required this.weight}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      '$weight kg',
      style: TextStyleConstants.smallTitle,
    );
  }
}

/// BMI value text widget
class BMIValueText extends StatelessWidget {
  final double bmi;

  const BMIValueText({Key? key, required this.bmi}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      bmi.toStringAsFixed(1),
      style: TextStyleConstants.bmiValue,
    );
  }
}