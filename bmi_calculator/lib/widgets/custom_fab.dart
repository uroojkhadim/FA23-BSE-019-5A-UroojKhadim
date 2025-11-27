// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'constants/color_constants.dart';
import 'constants/spacing_constants.dart';

/// Custom Floating Action Button Widget
/// A reusable custom FAB with enhanced styling and functionality
class CustomFAB extends StatelessWidget {
  /// Icon to display in the FAB
  final IconData icon;
  
  /// Callback function when FAB is pressed
  final VoidCallback onPressed;
  
  /// Background color of the FAB
  final Color backgroundColor;
  
  /// Icon color of the FAB
  final Color iconColor;
  
  /// Tooltip text for the FAB
  final String? tooltip;
  
  /// Size of the FAB
  final double size;

  /// Constructor for CustomFAB
  const CustomFAB({
    Key? key,
    required this.icon,
    required this.onPressed,
    this.backgroundColor = ColorConstants.primaryGreen,
    this.iconColor = Colors.white,
    this.tooltip,
    this.size = 56.0,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            spreadRadius: 2,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Icon(
          icon,
          color: iconColor,
          size: size * 0.5,
        ),
      ),
    );
  }
}