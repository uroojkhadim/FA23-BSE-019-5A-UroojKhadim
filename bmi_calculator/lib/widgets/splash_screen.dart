// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'package:bmi_calculator/widgets/constants/color_constants.dart';
import 'package:bmi_calculator/widgets/constants/text_style_constants.dart';

/// Splash Screen
/// Displays a loading screen while the app initializes
class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({Key? key, required this.onInitializationComplete}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate app initialization
    _initializeApp();
  }

  /// Simulates app initialization
  Future<void> _initializeApp() async {
    // Simulate some initialization work
    await Future.delayed(const Duration(seconds: 2));
    
    // Notify that initialization is complete
    widget.onInitializationComplete();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.primaryGreen,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // App icon or logo
            Icon(
              Icons.monitor_weight,
              size: 100,
              color: Colors.white,
            ),
            const SizedBox(height: 30),
            // App title
            Text(
              'BMI Calculator',
              style: TextStyleConstants.largeTitle.copyWith(
                color: Colors.white,
                fontSize: 32,
              ),
            ),
            const SizedBox(height: 20),
            // Loading indicator
            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
            const SizedBox(height: 20),
            Text(
              'Calculating your health...',
              style: TextStyleConstants.mediumBody.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}