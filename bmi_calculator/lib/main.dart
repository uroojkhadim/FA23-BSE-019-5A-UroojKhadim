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
import 'widgets/custom_fab.dart';
import 'widgets/bmi_info_screen.dart';

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
    return MaterialApp(
      title: 'BMI Calculator',
      theme: BMICalculatorTheme.lightTheme,
      home: const BMICalculatorScreen(),
      routes: {
        '/bmi-info': (context) => const BMIInfoScreen(),
      },
    );
  }
}

// =============================================================================
// MAIN SCREEN
// =============================================================================

/// Main screen of the BMI calculator app
/// Contains all the UI elements and logic for calculating BMI
class BMICalculatorScreen extends StatefulWidget {
  /// Constructor with key parameter
  const BMICalculatorScreen({Key? key}) : super(key: key);

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  // Controllers for text input fields
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  
  // Values for slider and stepper inputs
  double _height = 170.0; // Default height (170 cm)
  double _weight = 70.0; // Default weight (70 kg)
  
  // Input method state using enum
  InputMethod _inputMethod = InputMethod.text;
  
  // Results from BMI calculation
  double _bmi = 0.0;
  BMICategory _category = BMICategory.normal;

  /// Calculates BMI and updates the result
  void _calculateBMI() {
    // Create function object for BMI calculation
    final bmiCalculator = BMICalculatorCallbacks.createBMICalculator(
      _inputMethod == InputMethod.slider ? _height : 
          (_heightController.text.isEmpty ? 0 : double.parse(_heightController.text)),
      _inputMethod == InputMethod.slider ? _weight : 
          (_weightController.text.isEmpty ? 0 : double.parse(_weightController.text)),
      (bmi, category) {
        // Success callback
        setState(() {
          _bmi = bmi;
          _category = category;
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
  Color _getColorForCategory(BMICategory category) {
    return BMICalculatorUtils.getBMIColor(category);
  }

  /// Resets all input values to defaults
  void _resetValues() {
    // Create function object for resetting values
    final resetFunction = BMICalculatorCallbacks.createResetFunction(
      () {
        // Reset callback
        setState(() {
          _heightController.clear();
          _weightController.clear();
          _height = 170.0;
          _weight = 70.0;
          _bmi = 0.0;
          _category = BMICategory.normal;
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
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        centerTitle: true,
      ),
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
              
              // Input method toggle
              InputMethodToggle(
                useSliders: _inputMethod == InputMethod.slider,
                onToggle: () {
                  setState(() {
                    _inputMethod = _inputMethod.toggle;
                  });
                },
              ),
              const SizedBox(height: SpacingConstants.large),
              
              // Input cards based on selected method
              if (_inputMethod == InputMethod.text)
                TextInputCard(
                  heightController: _heightController,
                  weightController: _weightController,
                )
              else
                SliderInputCard(
                  heightValue: _height,
                  weightValue: _weight.toInt(),
                  onHeightChanged: (value) {
                    setState(() {
                      _height = value;
                    });
                  },
                  onWeightChanged: (value) {
                    setState(() {
                      _weight = value.toDouble();
                    });
                  },
                ),
              const SizedBox(height: SpacingConstants.extraLarge),
              
              // Calculate button
              Center(
                child: ElevatedButton(
                  onPressed: _calculateBMI,
                  style: ElevatedButton.styleFrom(
                    padding: SpacingConstants.buttonPadding,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Calculate BMI',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: SpacingConstants.large),
              
              // BMI result card
              if (_bmi > 0)
                BMIResultCard(
                  bmi: _bmi,
                  category: _category,
                  color: _getColorForCategory(_category),
                ),
              
              const SizedBox(height: SpacingConstants.extraLarge),
              
              // Button to navigate to BMI information screen
              Center(
                child: TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/bmi-info');
                  },
                  child: const Text('Learn more about BMI'),
                ),
              ),
              
              const SizedBox(height: SpacingConstants.extraLarge),
            ],
          ),
        ),
      ),
      // Custom Floating Action Button for resetting values
      floatingActionButton: CustomFAB(
        icon: Icons.refresh,
        onPressed: _resetValues,
        tooltip: 'Reset Values',
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}