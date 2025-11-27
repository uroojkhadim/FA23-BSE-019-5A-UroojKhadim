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
import 'widgets/bmi_calculator_callbacks.dart';
import 'widgets/constants/spacing_constants.dart';

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

  /// Calculate BMI based on input values using function objects
  void _calculateBMI() {
    // Create function object for BMI calculation
    final bmiCalculator = BMICalculatorCallbacks.createBMICalculator(
      _inputMethod == InputMethod.slider ? _heightSliderValue : 
          (_heightController.text.isEmpty ? 0 : double.parse(_heightController.text)),
      _inputMethod == InputMethod.slider ? _weightStepperValue.toDouble() : 
          (_weightController.text.isEmpty ? 0 : double.parse(_weightController.text)),
      (bmi, category) {
        // Success callback
        setState(() {
          _bmi = bmi;
          _bmiCategory = category;
        });
      },
      (errorMessage) {
        // Error callback using message shower function object
        final messageShower = BMICalculatorCallbacks.createMessageShower(
          context,
          errorMessage,
          Colors.red,
        );
        messageShower();
      },
    );
    
    // Validate input before calculation
    if (_inputMethod == InputMethod.text) {
      final inputValidator = BMICalculatorCallbacks.createInputValidator(
        _heightController.text,
        _weightController.text,
        (isValid, message) {
          if (isValid) {
            // Valid input - proceed with calculation
            bmiCalculator();
          } else {
            // Invalid input - show error using message shower function object
            final messageShower = BMICalculatorCallbacks.createMessageShower(
              context,
              message,
              Colors.red,
            );
            messageShower();
          }
        },
      );
      
      // Execute validation
      inputValidator();
    } else {
      // For slider input, directly calculate BMI
      bmiCalculator();
    }
  }

  /// Get color associated with BMI category
  Color _getBMIColor(BMICategory category) {
    return BMICalculatorUtils.getBMIColor(category);
  }

  /// Toggle between text input and slider input methods using function objects
  void _toggleInputMethod() {
    // Create function object for toggling input method
    final toggleFunction = BMICalculatorCallbacks.createInputMethodToggle(
      () {
        // Toggle callback
        setState(() {
          _inputMethod = _inputMethod.toggle;
        });
      },
    );
    
    // Execute toggle
    toggleFunction();
  }

  /// Reset all values using function objects
  void _resetValues() {
    // Create function object for resetting values
    final resetFunction = BMICalculatorCallbacks.createResetFunction(
      () {
        // Reset callback
        setState(() {
          _heightController.clear();
          _weightController.clear();
          _heightSliderValue = 170.0;
          _weightStepperValue = 70;
          _bmi = 0.0;
          _bmiCategory = BMICategory.normal;
        });
      },
      (message) {
        // Message callback using message shower function object
        final messageShower = BMICalculatorCallbacks.createMessageShower(
          context,
          message,
          Colors.green,
        );
        messageShower();
      },
    );
    
    // Execute reset
    resetFunction();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // App bar with title and input method toggle
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _resetValues,
            tooltip: 'Reset Values',
          ),
          InputMethodToggle(
            useSliders: _inputMethod == InputMethod.slider,
            onToggle: _toggleInputMethod,
          ),
        ],
      ),
      // Main content area with scrollable layout
      body: SingleChildScrollView(
        child: Padding(
          padding: SpacingConstants.defaultPadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App title
              const AppTitleText(),
              const SizedBox(height: SpacingConstants.medium),
              // App description
              const AppDescriptionText(),
              const SizedBox(height: SpacingConstants.huge),
              
              // Section header for input
              const SectionHeaderText(text: 'Enter Your Details'),
              const SizedBox(height: SpacingConstants.large),
              
              // Input cards based on selected method using conditional renderer
              BMICalculatorCallbacks.createConditionalRenderer(
                _inputMethod == InputMethod.text,
                TextInputCard(
                  heightController: _heightController,
                  weightController: _weightController,
                ),
                SliderInputCard(
                  heightValue: _heightSliderValue,
                  weightValue: _weightStepperValue,
                  onHeightChanged: (value) {
                    // Create function object for height change
                    final heightChanger = BMICalculatorCallbacks.createHeightChanger(
                      _heightSliderValue,
                      100.0,
                      250.0,
                      (newHeight) {
                        // Change callback
                        setState(() {
                          _heightSliderValue = newHeight;
                        });
                      },
                    );
                    
                    // Execute height change
                    heightChanger(value);
                  },
                  onWeightChanged: (value) {
                    // Create function object for weight change
                    final weightChanger = BMICalculatorCallbacks.createWeightChanger(
                      _weightStepperValue,
                      30,
                      200,
                      (newWeight) {
                        // Change callback
                        setState(() {
                          _weightStepperValue = newWeight;
                        });
                      },
                    );
                    
                    // Execute weight change
                    weightChanger(value);
                  },
                ),
              )(),
              
              const SizedBox(height: SpacingConstants.huge),
              
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
              
              const SizedBox(height: SpacingConstants.huge),
              
              // Display BMI result if calculated using conditional renderer
              BMICalculatorCallbacks.createConditionalRenderer(
                _bmi > 0,
                Column(
                  children: [
                    const SectionHeaderText(text: 'Your Results'),
                    const SizedBox(height: SpacingConstants.large),
                    BMIResultCard(
                      bmi: _bmi,
                      category: _bmiCategory,
                      color: _getBMIColor(_bmiCategory),
                    ),
                  ],
                ),
                const SizedBox.shrink(),
              )(),
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