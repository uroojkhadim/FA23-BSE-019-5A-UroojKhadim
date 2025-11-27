// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'constants/color_constants.dart';
import 'constants/text_style_constants.dart';

/// Extended Floating Action Button Widget
/// A reusable extended FAB with icon and label
class ExtendedFAB extends StatelessWidget {
  /// Icon to display in the FAB
  final IconData icon;
  
  /// Label text to display in the FAB
  final String label;
  
  /// Callback function when FAB is pressed
  final VoidCallback onPressed;
  
  /// Background color of the FAB
  final Color backgroundColor;
  
  /// Icon and text color of the FAB
  final Color foregroundColor;
  
  /// Tooltip text for the FAB
  final String? tooltip;

  /// Constructor for ExtendedFAB
  const ExtendedFAB({
    Key? key,
    required this.icon,
    required this.label,
    required this.onPressed,
    this.backgroundColor = ColorConstants.primaryGreen,
    this.foregroundColor = Colors.white,
    this.tooltip,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, color: foregroundColor),
      label: Text(
        label,
        style: TextStyleConstants.buttonText.copyWith(color: foregroundColor),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        elevation: 5,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
    );
  }
}