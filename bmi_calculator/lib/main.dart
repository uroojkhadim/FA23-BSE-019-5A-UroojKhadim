import 'package:flutter/material.dart';

// Custom theme data class for the BMI calculator
class BMICalculatorTheme {
  static final ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    visualDensity: VisualDensity.adaptivePlatformDensity,
    scaffoldBackgroundColor: const Color(0xFFE8F5E9),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.green,
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
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
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
      fillColor: Colors.white,
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

  // Color scheme for BMI categories
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

// RepeatContainer class for consistent styled containers
class RepeatContainer extends StatelessWidget {
  final Widget child;
  final Color? color;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry padding;
  final BorderRadiusGeometry borderRadius;
  final List<BoxShadow>? boxShadow;

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
        color: color ?? Colors.white,
        borderRadius: borderRadius,
        boxShadow: boxShadow ?? [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

// Input Method Toggle Widget
class InputMethodToggle extends StatelessWidget {
  final bool useSliders;
  final VoidCallback onToggle;

  const InputMethodToggle({
    Key? key,
    required this.useSliders,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(useSliders ? Icons.text_fields : Icons.slideshow),
      onPressed: onToggle,
      tooltip: useSliders ? 'Switch to Text Fields' : 'Switch to Sliders',
    );
  }
}

// Text Input Card Widget
class TextInputCard extends StatelessWidget {
  final TextEditingController heightController;
  final TextEditingController weightController;

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
          TextField(
            controller: heightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Height (cm)',
              prefixIcon: Icon(Icons.height),
            ),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: weightController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Weight (kg)',
              prefixIcon: Icon(Icons.monitor_weight),
            ),
          ),
        ],
      ),
    );
  }
}

// Slider Input Card Widget
class SliderInputCard extends StatefulWidget {
  final double heightValue;
  final int weightValue;
  final Function(double) onHeightChanged;
  final Function(int) onWeightChanged;

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
          Text(
            'Height: ${widget.heightValue.round()} cm',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Slider(
            value: widget.heightValue,
            min: 100,
            max: 250,
            divisions: 150,
            label: widget.heightValue.round().toString(),
            onChanged: widget.onHeightChanged,
          ),
          const SizedBox(height: 20),
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
                  IconButton(
                    icon: const Icon(Icons.remove_circle),
                    onPressed: () {
                      if (widget.weightValue > 30) {
                        widget.onWeightChanged(widget.weightValue - 1);
                      }
                    },
                  ),
                  Text(
                    '${widget.weightValue} kg',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: () {
                      if (widget.weightValue < 200) {
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

// BMI Result Card Widget
class BMIResultCard extends StatelessWidget {
  final double bmi;
  final String category;
  final Color color;

  const BMIResultCard({
    Key? key,
    required this.bmi,
    required this.category,
    required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RepeatContainer(
      color: color,
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.15),
          blurRadius: 15,
          offset: const Offset(0, 5),
        ),
      ],
      child: Column(
        children: [
          const Text(
            'Your BMI Result',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            bmi.toStringAsFixed(1),
            style: const TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            category,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 15),
          // BMI scale visualization
          Container(
            height: 20,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
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
                Expanded(
                  flex: 650,
                  child: Container(
                    color: Colors.green,
                  ),
                ),
                Expanded(
                  flex: 500,
                  child: Container(
                    color: Colors.orange,
                  ),
                ),
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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Under', style: TextStyle(color: Colors.white)),
              Text('Normal', style: TextStyle(color: Colors.white)),
              Text('Over', style: TextStyle(color: Colors.white)),
              Text('Obese', style: TextStyle(color: Colors.white)),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            _getBMIDescription(category),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
  
  String _getBMIDescription(String category) {
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

void main() {
  runApp(const BMICalculatorApp());
}

class BMICalculatorApp extends StatelessWidget {
  const BMICalculatorApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BMI Calculator',
      theme: BMICalculatorTheme.lightTheme,
      home: const BMICalculator(),
    );
  }
}

class BMICalculator extends StatefulWidget {
  const BMICalculator({Key? key}) : super(key: key);

  @override
  State<BMICalculator> createState() => _BMICalculatorState();
}

class _BMICalculatorState extends State<BMICalculator> {
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  double _heightSliderValue = 170.0;
  int _weightStepperValue = 70;
  bool _useSliders = false;
  double _bmi = 0.0;
  String _bmiCategory = '';

  void _calculateBMI() {
    double heightInMeters;
    double weight;

    if (_useSliders) {
      heightInMeters = _heightSliderValue / 100;
      weight = _weightStepperValue.toDouble();
    } else {
      final heightText = _heightController.text;
      final weightText = _weightController.text;

      if (heightText.isEmpty || weightText.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter both height and weight')),
        );
        return;
      }

      heightInMeters = double.parse(heightText) / 100;
      weight = double.parse(weightText);
    }

    setState(() {
      _bmi = weight / (heightInMeters * heightInMeters);
      _bmiCategory = _getBMICategory(_bmi);
    });
  }

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

  void _toggleInputMethod() {
    setState(() {
      _useSliders = !_useSliders;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        actions: [
          InputMethodToggle(
            useSliders: _useSliders,
            onToggle: _toggleInputMethod,
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Calculate Your Body Mass Index',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Enter your height and weight to calculate BMI',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              
              // Input cards based on selected method
              if (!_useSliders)
                TextInputCard(
                  heightController: _heightController,
                  weightController: _weightController,
                )
              else
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
              
              // Enhanced button with improved styling
              Center(
                child: ElevatedButton(
                  onPressed: _calculateBMI,
                  child: const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    child: Text('Calculate BMI'),
                  ),
                ),
              ),
              
              const SizedBox(height: 30),
              
              // Improved result display with better layout
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

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }
}