// Import the Flutter material design library
import 'package:flutter/material.dart';

/// Custom Slider Widget
/// A reusable slider with enhanced styling and functionality
class CustomSlider extends StatelessWidget {
  /// Current value of the slider
  final double value;
  
  /// Minimum value of the slider
  final double min;
  
  /// Maximum value of the slider
  final double max;
  
  /// Number of divisions (discrete steps)
  final int? divisions;
  
  /// Label to display when sliding
  final String label;
  
  /// Callback function when slider value changes
  final Function(double) onChanged;
  
  /// Active track color
  final Color activeTrackColor;
  
  /// Inactive track color
  final Color inactiveTrackColor;
  
  /// Thumb color
  final Color thumbColor;

  /// Constructor for CustomSlider
  const CustomSlider({
    Key? key,
    required this.value,
    required this.min,
    required this.max,
    this.divisions,
    required this.label,
    required this.onChanged,
    this.activeTrackColor = Colors.green,
    this.inactiveTrackColor = const Color(0xFFE0E0E0),
    this.thumbColor = Colors.green,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        activeTrackColor: activeTrackColor,
        inactiveTrackColor: inactiveTrackColor,
        thumbColor: thumbColor,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12.0),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 20.0),
        tickMarkShape: const RoundSliderTickMarkShape(),
        activeTickMarkColor: activeTrackColor,
        inactiveTickMarkColor: inactiveTrackColor,
      ),
      child: Slider(
        value: value,
        min: min,
        max: max,
        divisions: divisions,
        label: label,
        onChanged: onChanged,
      ),
    );
  }
}