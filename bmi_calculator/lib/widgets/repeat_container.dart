// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'constants/container_constants.dart';

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
    this.padding = ContainerConstants.defaultPadding,
    this.borderRadius = ContainerConstants.defaultBorderRadius,
    this.boxShadow,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? ContainerConstants.defaultColor, // Use provided color or default to white
        borderRadius: borderRadius,
        boxShadow: boxShadow ?? ContainerConstants.defaultBoxShadow,
      ),
      child: child, // Display the child widget
    );
  }
}