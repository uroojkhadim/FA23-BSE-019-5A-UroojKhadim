import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({Key? key}) : super(key: key);

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.paddingMedium),
        child: Column(
          children: [
            // Report type selection
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(AppConstants.paddingMedium),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(AppConstants.borderRadius),
              ),
              child: const Text(
                'Select Report Type',
                style: TextStyle(
                  fontSize: AppConstants.fontSizeLarge,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: AppConstants.paddingMedium),
            
            // Report options
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: AppConstants.paddingMedium,
                mainAxisSpacing: AppConstants.paddingMedium,
                children: [
                  _buildReportCard(
                    title: 'Daily Sales',
                    icon: Icons.trending_up,
                    color: Colors.blue,
                  ),
                  _buildReportCard(
                    title: 'Monthly Sales',
                    icon: Icons.bar_chart,
                    color: Colors.green,
                  ),
                  _buildReportCard(
                    title: 'Inventory',
                    icon: Icons.inventory,
                    color: Colors.orange,
                  ),
                  _buildReportCard(
                    title: 'Customer',
                    icon: Icons.people,
                    color: Colors.purple,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReportCard({
    required String title,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: () {
          // Handle report selection
          _showReportDialog(title);
        },
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 48,
              color: color,
            ),
            const SizedBox(height: AppConstants.paddingSmall),
            Text(
              title,
              style: const TextStyle(
                fontSize: AppConstants.fontSizeMedium,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showReportDialog(String reportType) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('$reportType Report'),
          content: const Text('This report will be generated based on your data.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
}