// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'repeat_container.dart';
import 'icon_widgets.dart';
import 'text_widgets.dart';
import 'bmi_calculator_callbacks.dart';
import 'constants/spacing_constants.dart';

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
          const SizedBox(height: SpacingConstants.extraLarge), // Spacing
          // Weight stepper controls with gesture detection
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
                  // Decrease weight button with gesture detector
                  GestureDetector(
                    onTap: () {
                      // Create function object for weight change
                      final weightChanger = BMICalculatorCallbacks.createWeightChanger(
                        widget.weightValue,
                        30,
                        200,
                        (newWeight) {
                          // Change callback
                          widget.onWeightChanged(newWeight);
                        },
                      );
                      
                      // Execute weight change with decrement
                      weightChanger(widget.weightValue - 1);
                    },
                    child: const DecreaseIcon(),
                  ),
                  // Display current weight value
                  WeightValueText(weight: widget.weightValue),
                  // Increase weight button with gesture detector
                  GestureDetector(
                    onTap: () {
                      // Create function object for weight change
                      final weightChanger = BMICalculatorCallbacks.createWeightChanger(
                        widget.weightValue,
                        30,
                        200,
                        (newWeight) {
                          // Change callback
                          widget.onWeightChanged(newWeight);
                        },
                      );
                      
                      // Execute weight change with increment
                      weightChanger(widget.weightValue + 1);
                    },
                    child: const IncreaseIcon(),
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