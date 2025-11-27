// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'widgets/app_theme.dart';
import 'widgets/input_method_toggle.dart';
import 'widgets/text_input_card.dart';
import 'widgets/slider_input_card.dart';
import 'widgets/bmi_result_card.dart';
import 'widgets/bmi_calculator_utils.dart';
import 'widgets/text_widgets.dart';
import 'widgets/input_method.dart';
import 'widgets/bmi_category.dart';

// =============================================================================
// MAIN APPLICATION
// =============================================================================

/// Entry point of the application
void main() {
  runApp(const BMICalculatorApp());
}

/// Main application widget
/// This is the root widget of the BMI calculator app
class BMICalculatorApp extends StatelessWidget {
  /// Constructor with key parameter
  const BMICalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // MaterialApp provides app-wide configuration
    return MaterialApp(
      title: 'BMI Calculator', // App title
      theme: BMICalculatorTheme.lightTheme, // Apply custom theme
      home: const BMICalculator(), // Set home screen
    );
  }
}

/// Main BMI calculator screen
/// This stateful widget manages the UI and calculation logic
class BMICalculator extends StatefulWidget {
  /// Constructor with key parameter
  const BMICalculator({Key? key}) : super(key: key);

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

/// State class for BMICalculator
/// Manages the state and business logic for the BMI calculator
class _BMICalculatorState extends State<BMICalculator> {
  // Controllers for text input fields
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  // Values for slider and stepper inputs
  double _heightSliderValue = 170.0; // Default height (170 cm)
  int _weightStepperValue = 70; // Default weight (70 kg)
  
  // Input method state using enum
  InputMethod _inputMethod = InputMethod.text;
  
  // Results from BMI calculation
  double _bmi = 0.0;
  BMICategory _bmiCategory = BMICategory.normal;

  /// Calculate BMI based on input values
  void _calculateBMI() {
    double heightInMeters;
    double weight;

    // Use different input methods based on toggle state
    if (_inputMethod == InputMethod.slider) {
      // Use slider/stepper values
      heightInMeters = _heightSliderValue / 100; // Convert cm to meters
      weight = _weightStepperValue.toDouble();
    } else {
      // Use text field values
      final heightText = _heightController.text;
      final weightText = _weightController.text;

      // Validate input
      if (heightText.isEmpty || weightText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter both height and weight')),
        );
        return;
      }

      // Parse input values
      heightInMeters = double.parse(heightText) / 100; // Convert cm to meters
      weight = double.parse(weightText);
    }

    // Update state with calculated BMI
    setState(() {
      _bmi = BMICalculatorUtils.calculateBMI(heightInMeters, weight); // BMI formula
      _bmiCategory = BMICalculatorUtils.getBMICategory(_bmi); // Determine category
    });
  }

  /// Get color associated with BMI category
  Color _getBMIColor(BMICategory category) {
    return BMICalculatorUtils.getBMIColor(category);
  }

  /// Toggle between text input and slider input methods
  void _toggleInputMethod() {
    setState(() {
      _inputMethod = _inputMethod.toggle; // Toggle input method using enum
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title and input method toggle
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        actions: [
          InputMethodToggle(
            useSliders: _inputMethod == InputMethod.slider,
            onToggle: _toggleInputMethod,
          ),
        ],
      ),
      // Main content area with scrollable layout
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App title
              const AppTitleText(),
              const SizedBox(height: 10),
              // App description
              const AppDescriptionText(),
              const SizedBox(height: 30),
              
              // Input cards based on selected method
              if (_inputMethod == InputMethod.text)
                // Text input method
                TextInputCard(
                  heightController: _heightController,
                  weightController: _weightController,
                )
              else
                // Slider input method
                SliderInputCard(
                  heightValue: _heightSliderValue,
                  weightValue: _weightStepperValue,
                  onHeightChanged: (value) {
                    setState(() {
                      _heightSliderValue = value;
                    });
                  },
                  onWeightChanged: (value) {
                    setState(() {
                      _weightStepperValue = value.toInt();
                    });
                  },
                ),
              
              const SizedBox(height: 30),
              
              // Calculate button
              Center(
                child: ElevatedButton(
                  onPressed: _calculateBMI, // Trigger BMI calculation
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    child: Text('Calculate BMI'),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Display BMI result if calculated
              if (_bmi > 0)
                BMIResultCard(
                  bmi: _bmi,
                  category: _bmiCategory,
                  color: _getBMIColor(_bmiCategory),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// Clean up resources when widget is disposed
  @override
  void dispose() {
    _heightController.dispose(); // Dispose height controller
    _weightController.dispose(); // Dispose weight controller
    super.dispose();
  }
}