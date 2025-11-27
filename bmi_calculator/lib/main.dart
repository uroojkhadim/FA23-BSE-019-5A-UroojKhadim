// Import the Flutter material design library
import 'package:flutter/material.dart';

// =============================================================================
// THEME CONFIGURATION
// =============================================================================

/// Custom theme data class for the BMI calculator
/// Contains all styling information for consistent UI across the app
class BMICalculatorTheme {
  /// Light theme configuration with custom colors and styling
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: const Color(0xFFE8F5E9), // Light green background
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.green, // Green app bar
      foregroundColor: Colors.white,
      elevation: 4,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 22,
        fontWeight: FontWeight.bold,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.green, // Green buttons
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30), // Rounded buttons
        ),
        elevation: 8,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.green, width: 2),
      ),
      filled: true,
      fillColor: Colors.white, // White input fields
      contentPadding: const EdgeInsets.all(20),
      labelStyle: const TextStyle(
        color: Colors.grey,
        fontSize: 16,
      ),
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        color: Colors.black54,
      ),
    ),
  );

  // Color scheme for different BMI categories
  static const Map<String, Color> bmiCategoryColors = {
    'Underweight': Colors.blue,
    'Normal weight': Colors.green,
    'Overweight': Colors.orange,
    'Obese': Colors.red,
  };

  // Get color for BMI category
  static Color getBMIColor(String category) {
    return bmiCategoryColors[category] ?? Colors.grey;
  }
}

// =============================================================================
// CUSTOM ICON WIDGETS
// =============================================================================

/// Custom icon widget for height input
class HeightIcon extends StatelessWidget {
  const HeightIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.height,
      color: Colors.green,
      size: 24,
    );
  }
}

/// Custom icon widget for weight input
class WeightIcon extends StatelessWidget {
  const WeightIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.monitor_weight,
      color: Colors.green,
      size: 24,
    );
  }
}

/// Custom icon widget for decrease button
class DecreaseIcon extends StatelessWidget {
  const DecreaseIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.remove_circle,
      color: Colors.red,
      size: 30,
    );
  }
}

/// Custom icon widget for increase button
class IncreaseIcon extends StatelessWidget {
  const IncreaseIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.add_circle,
      color: Colors.green,
      size: 30,
    );
  }
}

/// Custom icon widget for text input toggle
class TextInputIcon extends StatelessWidget {
  const TextInputIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.text_fields,
      color: Colors.white,
    );
  }
}

/// Custom icon widget for slider input toggle
class SliderInputIcon extends StatelessWidget {
  const SliderInputIcon({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Icon(
      Icons.slideshow,
      color: Colors.white,
    );
  }
}

// =============================================================================
// CUSTOM TEXT WIDGETS
// =============================================================================

/// Title text widget for the app
class AppTitleText extends StatelessWidget {
  const AppTitleText({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Calculate Your Body Mass Index',
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.green,
      ),
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
      style: TextStyle(fontSize: 16, color: Colors.grey),
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
      style: TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
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
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
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
      style: const TextStyle(
        color: Colors.white,
        fontSize: 12,
        fontWeight: FontWeight.bold,
      ),
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
      style: const TextStyle(
        fontSize: 16,
        color: Colors.white,
      ),
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
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
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
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
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
      style: const TextStyle(
        fontSize: 56,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }
}

// =============================================================================
// REUSABLE WIDGETS
// =============================================================================

/// RepeatContainer class for consistent styled containers
/// This widget provides a reusable container with consistent styling
/// throughout the application to reduce code duplication
class RepeatContainer extends StatelessWidget {
  /// The child widget to be displayed inside the container
  final Widget child;
  
  /// Background color of the container (defaults to white)
  final Color? color;
  
  /// Margin around the container
  final EdgeInsetsGeometry? margin;
  
  /// Padding inside the container (defaults to 20 pixels on all sides)
  final EdgeInsetsGeometry padding;
  
  /// Border radius for rounded corners (defaults to 15 pixels)
  final BorderRadiusGeometry borderRadius;
  
  /// Box shadow for depth effect (defaults to subtle grey shadow)
  final List<BoxShadow>? boxShadow;

  /// Constructor for RepeatContainer
  const RepeatContainer({
    Key? key,
    required this.child,
    this.color,
    this.margin,
    this.padding = const EdgeInsets.all(20),
    this.borderRadius = const BorderRadius.all(Radius.circular(15)),
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white, // Use provided color or default to white
        borderRadius: borderRadius,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2), // Subtle shadow
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3), // Shadow offset
          ),
        ],
      ),
      child: child, // Display the child widget
    );
  }
}

/// Input Method Toggle Widget
/// Provides a button to switch between text input and slider input methods
class InputMethodToggle extends StatelessWidget {
  /// Flag indicating whether sliders are currently being used
  final bool useSliders;
  
  /// Callback function to execute when the toggle is pressed
  final VoidCallback onToggle;

  /// Constructor for InputMethodToggle
  const InputMethodToggle({
    Key? key,
    required this.useSliders,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: useSliders ? const TextInputIcon() : const SliderInputIcon(), // Toggle icon
      onPressed: onToggle, // Execute callback when pressed
      tooltip: useSliders ? 'Switch to Text Fields' : 'Switch to Sliders',
    );
  }
}

/// Text Input Card Widget
/// Displays input fields for height and weight using text fields
class TextInputCard extends StatelessWidget {
  /// Controller for the height text field
  final TextEditingController heightController;
  
  /// Controller for the weight text field
  final TextEditingController weightController;

  /// Constructor for TextInputCard
  const TextInputCard({
    Key? key,
    required this.heightController,
    required this.weightController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepeatContainer(
      child: Column(
        children: [
          // Height input field with icon
          TextField(
            controller: heightController,
            keyboardType: TextInputType.number, // Only accept numbers
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              prefixIcon: HeightIcon(), // Custom height icon
            ),
          ),
          const SizedBox(height: 20), // Spacing between fields
          // Weight input field with icon
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number, // Only accept numbers
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              prefixIcon: WeightIcon(), // Custom weight icon
            ),
          ),
        ],
      ),
    );
  }
}

/// Slider Input Card Widget
/// Displays input controls for height and weight using sliders and steppers
class SliderInputCard extends StatefulWidget {
  /// Current height value for the slider
  final double heightValue;
  
  /// Current weight value for the stepper
  final int weightValue;
  
  /// Callback function when height slider value changes
  final Function(double) onHeightChanged;
  
  /// Callback function when weight stepper value changes
  final Function(int) onWeightChanged;

  /// Constructor for SliderInputCard
  const SliderInputCard({
    Key? key,
    required this.heightValue,
    required this.weightValue,
    required this.onHeightChanged,
    required this.onWeightChanged,
  }) : super(key: key);

  @override
  State<SliderInputCard> createState() => _SliderInputCardState();
}

class _SliderInputCardState extends State<SliderInputCard> {
  @override
  Widget build(BuildContext context) {
    return RepeatContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display current height value
          HeightValueText(height: widget.heightValue),
          // Height slider control
          Slider(
            value: widget.heightValue,
            min: 100, // Minimum height (100 cm)
            max: 250, // Maximum height (250 cm)
            divisions: 150, // Number of discrete steps
            label: widget.heightValue.round().toString(), // Display value when sliding
            onChanged: widget.onHeightChanged, // Callback when value changes
          ),
          const SizedBox(height: 20), // Spacing
          // Weight stepper controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Weight: ',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Row(
                children: [
                  // Decrease weight button
                  IconButton(
                    icon: const DecreaseIcon(),
                    onPressed: () {
                      if (widget.weightValue > 30) { // Minimum weight limit
                        widget.onWeightChanged(widget.weightValue - 1);
                      }
                    },
                  ),
                  // Display current weight value
                  WeightValueText(weight: widget.weightValue),
                  // Increase weight button
                  IconButton(
                    icon: const IncreaseIcon(),
                    onPressed: () {
                      if (widget.weightValue < 200) { // Maximum weight limit
                        widget.onWeightChanged(widget.weightValue + 1);
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

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
  
  // Flag to toggle between input methods
  bool _useSliders = false;
  
  // Results from BMI calculation
  double _bmi = 0.0;
  String _bmiCategory = '';

  /// Calculate BMI based on input values
  void _calculateBMI() {
    double heightInMeters;
    double weight;

    // Use different input methods based on toggle state
    if (_useSliders) {
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
      _bmi = weight / (heightInMeters * heightInMeters); // BMI formula
      _bmiCategory = _getBMICategory(_bmi); // Determine category
    });
  }

  /// Determine BMI category based on calculated value
  String _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return 'Underweight';
    } else if (bmi >= 18.5 && bmi < 25) {
      return 'Normal weight';
    } else if (bmi >= 25 && bmi < 30) {
      return 'Overweight';
    } else {
      return 'Obese';
    }
  }

  /// Get color associated with BMI category
  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) {
      return BMICalculatorTheme.getBMIColor('Underweight');
    } else if (bmi >= 18.5 && bmi < 25) {
      return BMICalculatorTheme.getBMIColor('Normal weight');
    } else if (bmi >= 25 && bmi < 30) {
      return BMICalculatorTheme.getBMIColor('Overweight');
    } else {
      return BMICalculatorTheme.getBMIColor('Obese');
    }
  }

  /// Toggle between text input and slider input methods
  void _toggleInputMethod() {
    setState(() {
      _useSliders = !_useSliders; // Flip the boolean flag
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
            useSliders: _useSliders,
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
              if (!_useSliders)
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
                  color: _getBMIColor(_bmi),
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