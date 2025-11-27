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
  
  /// Flag indicating if metric units are used
  final bool isMetric;

  /// Constructor for SliderInputCard
  const SliderInputCard({
    Key? key,
    required this.heightValue,
    required this.weightValue,
    required this.onHeightChanged,
    required this.onWeightChanged,
    this.isMetric = true,
  }) : super(key: key);

  @override
  State<SliderInputCard> createState() => _SliderInputCardState();
}

class _SliderInputCardState extends State<SliderInputCard> {
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
    if (oldWidget.heightValue != widget.heightValue) {
      setState(() {
        _currentHeight = widget.heightValue;
      });
    }
    if (oldWidget.weightValue != widget.weightValue) {
      setState(() {
        _currentWeight = widget.weightValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepeatContainer(
      child: Column(
        children: [
          // Height slider with value indicator
          SliderValueIndicator(
            label: 'Height',
            value: _currentHeight.toStringAsFixed(1),
            unit: widget.isMetric ? 'cm' : 'ft',
          ),
          const SizedBox(height: SpacingConstants.small),
          CustomSlider(
            value: _currentHeight,
            min: widget.isMetric ? 100.0 : 3.0,
            max: widget.isMetric ? 250.0 : 8.0,
            divisions: widget.isMetric ? 150 : 60,
            label: _currentHeight.toStringAsFixed(1),
            onChanged: (value) {
              setState(() {
                _currentHeight = value;
              });
              widget.onHeightChanged(value);
            },
          ),
          const SizedBox(height: SpacingConstants.extraLarge),
          
          // Weight stepper with value indicator
          SliderValueIndicator(
            label: 'Weight',
            value: _currentWeight.toString(),
            unit: widget.isMetric ? 'kg' : 'lbs',
          ),
          const SizedBox(height: SpacingConstants.small),
          CustomStepper(
            value: _currentWeight,
            minValue: widget.isMetric ? 20 : 44,
            maxValue: widget.isMetric ? 200 : 440,
            onDecrement: () {
              if (_currentWeight > (widget.isMetric ? 20 : 44)) {
                setState(() {
                  _currentWeight--;
                });
                widget.onWeightChanged(_currentWeight);
              }
            },
            onIncrement: () {
              if (_currentWeight < (widget.isMetric ? 200 : 440)) {
                setState(() {
                  _currentWeight++;
                });
                widget.onWeightChanged(_currentWeight);
              }
            },
          ),
        ],
      ),
    );
  }
}