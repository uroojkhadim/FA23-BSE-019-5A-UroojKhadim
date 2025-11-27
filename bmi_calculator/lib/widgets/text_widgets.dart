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

/// New text widgets for enhanced BMI calculator

/// Input label text widget
class InputLabelText extends StatelessWidget {
  final String text;

  const InputLabelText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyleConstants.inputLabel,
    );
  }
}

/// Button text widget
class ButtonText extends StatelessWidget {
  final String text;

  const ButtonText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyleConstants.buttonText,
    );
  }
}

/// Error message text widget
class ErrorMessageText extends StatelessWidget {
  final String text;

  const ErrorMessageText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.red,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Success message text widget
class SuccessMessageText extends StatelessWidget {
  final String text;

  const SuccessMessageText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.green,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Information text widget
class InfoText extends StatelessWidget {
  final String text;

  const InfoText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.blue,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Warning text widget
class WarningText extends StatelessWidget {
  final String text;

  const WarningText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.orange,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

/// Large value display text widget
class LargeValueText extends StatelessWidget {
  final String label;
  final String value;
  final String unit;

  const LargeValueText({
    Key? key,
    required this.label,
    required this.value,
    required this.unit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: SpacingConstants.small),
        Text(
          '$value $unit',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

/// Section header text widget
class SectionHeaderText extends StatelessWidget {
  final String text;

  const SectionHeaderText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }
}

/// Subsection header text widget
class SubSectionHeaderText extends StatelessWidget {
  final String text;

  const SubSectionHeaderText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    );
  }
}

/// Caption text widget
class CaptionText extends StatelessWidget {
  final String text;

  const CaptionText({Key? key, required this.text}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        color: Colors.grey,
      ),
    );
  }
}