// Import the Flutter material design library
import 'package:flutter/material.dart';

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