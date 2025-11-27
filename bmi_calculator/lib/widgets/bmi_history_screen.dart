// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'package:bmi_calculator/widgets/constants/color_constants.dart';
import 'package:bmi_calculator/widgets/constants/text_style_constants.dart';
import 'package:bmi_calculator/widgets/constants/spacing_constants.dart';
import 'package:bmi_calculator/widgets/bmi_category.dart';

/// BMI History Item
/// Represents a single BMI calculation record
class BMIHistoryItem {
  final DateTime date;
  final double height;
  final double weight;
  final double bmi;
  final BMICategory category;

  BMIHistoryItem({
    required this.date,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.category,
  });

  /// Get color associated with BMI category
  Color get categoryColor {
    switch (category) {
      case BMICategory.underweight:
        return ColorConstants.underweightColor;
      case BMICategory.normal:
        return ColorConstants.normalWeightColor;
      case BMICategory.overweight:
        return ColorConstants.overweightColor;
      case BMICategory.obese:
        return ColorConstants.obeseColor;
    }
  }

  /// Get category name
  String get categoryName {
    switch (category) {
      case BMICategory.underweight:
        return 'Underweight';
      case BMICategory.normal:
        return 'Normal';
      case BMICategory.overweight:
        return 'Overweight';
      case BMICategory.obese:
        return 'Obese';
    }
  }
}

/// BMI History Screen
/// Displays a history of BMI calculations
class BMIHistoryScreen extends StatefulWidget {
  final List<BMIHistoryItem> history;

  const BMIHistoryScreen({Key? key, required this.history}) : super(key: key);

  @override
  State<BMIHistoryScreen> createState() => _BMIHistoryScreenState();
}

class _BMIHistoryScreenState extends State<BMIHistoryScreen> {
  late List<BMIHistoryItem> _history;

  @override
  void initState() {
    super.initState();
    // Sort history by date (newest first)
    _history = List.from(widget.history)..sort((a, b) => b.date.compareTo(a.date));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI History'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: _clearHistory,
          ),
        ],
      ),
      body: _history.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
              padding: SpacingConstants.defaultPadding,
              itemCount: _history.length,
              itemBuilder: (context, index) {
                return _buildHistoryItem(_history[index]);
              },
            ),
    );
  }

  /// Builds the empty state when there's no history
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: SpacingConstants.large),
          const Text(
            'No BMI history yet',
            style: TextStyleConstants.mediumTitle,
          ),
          const SizedBox(height: SpacingConstants.small),
          const Text(
            'Calculate your BMI to see history here',
            style: TextStyleConstants.mediumBody,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  /// Builds a single history item
  Widget _buildHistoryItem(BMIHistoryItem item) {
    return Container(
      margin: const EdgeInsets.only(bottom: SpacingConstants.small),
      padding: SpacingConstants.defaultPadding,
      decoration: BoxDecoration(
        color: ColorConstants.lightBackground,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: item.categoryColor.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${item.date.day}/${item.date.month}/${item.date.year}',
                style: TextStyleConstants.smallTitle,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: SpacingConstants.small,
                  vertical: SpacingConstants.small,
                ),
                decoration: BoxDecoration(
                  color: item.categoryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  item.categoryName,
                  style: TextStyleConstants.smallBody.copyWith(
                    color: item.categoryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: SpacingConstants.small),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMeasurementItem('Height', '${item.height.toStringAsFixed(1)} cm'),
              _buildMeasurementItem('Weight', '${item.weight.toStringAsFixed(1)} kg'),
              _buildMeasurementItem('BMI', item.bmi.toStringAsFixed(1)),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a measurement item (height, weight, or BMI)
  Widget _buildMeasurementItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyleConstants.smallBody.copyWith(
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyleConstants.mediumBody,
        ),
      ],
    );
  }

  /// Clears all history items
  void _clearHistory() {
    setState(() {
      _history.clear();
    });
    
    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('History cleared'),
        backgroundColor: ColorConstants.primaryGreen,
      ),
    );
  }
}