// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'repeat_container.dart';
import 'icon_widgets.dart';
import 'text_widgets.dart';
import 'bmi_calculator_callbacks.dart';
import 'constants/spacing_constants.dart';
import 'custom_slider.dart';
import 'custom_stepper.dart';
import 'slider_value_indicator.dart';

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
  // Local variables to track slider values
  late double _currentHeight;
  late int _currentWeight;

  @override
  void initState() {
    super.initState();
    _currentHeight = widget.heightValue;
    _currentWeight = widget.weightValue;
  }

  @override
  void didUpdateWidget(covariant SliderInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update local values when widget is updated
    if (oldWidget.heightValue != widget.heightValue) {
      _currentHeight = widget.heightValue;
    }
    if (oldWidget.weightValue != widget.weightValue) {
      _currentWeight = widget.weightValue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepeatContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Display current height value with enhanced styling
          SliderValueIndicator(
            label: 'Height:',
            value: _currentHeight.round().toString(),
            unit: 'cm',
          ),
          // Enhanced height slider control using custom slider
          CustomSlider(
            value: _currentHeight,
            min: 100, // Minimum height (100 cm)
            max: 250, // Maximum height (250 cm)
            divisions: 150, // Number of discrete steps
            label: '${_currentHeight.round()} cm', // Display value when sliding
            onChanged: (double value) {
              setState(() {
                _currentHeight = value;
              });
              // Call the callback to update the parent widget
              widget.onHeightChanged(value);
            },
          ),
          const SizedBox(height: SpacingConstants.extraLarge), // Spacing
          
          // Weight section with enhanced controls
          SliderValueIndicator(
            label: 'Weight:',
            value: _currentWeight.toString(),
            unit: 'kg',
          ),
          const SizedBox(height: SpacingConstants.medium),
          
          // Enhanced weight stepper controls using custom stepper
          CustomStepper(
            value: _currentWeight,
            minValue: 30,
            maxValue: 200,
            onDecrement: () {
              // Create function object for weight change
              final weightChanger = BMICalculatorCallbacks.createWeightChanger(
                _currentWeight,
                30,
                200,
                (newWeight) {
                  // Change callback
                  setState(() {
                    _currentWeight = newWeight;
                  });
                  widget.onWeightChanged(newWeight);
                },
              );
              
              // Execute weight change with decrement
              weightChanger(_currentWeight - 1);
            },
            onIncrement: () {
              // Create function object for weight change
              final weightChanger = BMICalculatorCallbacks.createWeightChanger(
                _currentWeight,
                30,
                200,
                (newWeight) {
                  // Change callback
                  setState(() {
                    _currentWeight = newWeight;
                  });
                  widget.onWeightChanged(newWeight);
                },
              );
              
              // Execute weight change with increment
              weightChanger(_currentWeight + 1);
            },
          ),
        ],
      ),
    );
  }
}