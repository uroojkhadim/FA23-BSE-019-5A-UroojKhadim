// Import the Flutter material design library
import 'package:flutter/material.dart';
import 'package:bmi_calculator/widgets/constants/color_constants.dart';
import 'package:bmi_calculator/widgets/constants/text_style_constants.dart';
import 'package:bmi_calculator/widgets/constants/spacing_constants.dart';

/// Settings Screen
/// Allows users to customize app preferences
class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  // Settings state
  bool _darkMode = false;
  bool _notifications = true;
  String _unitSystem = 'metric'; // metric or imperial
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: SpacingConstants.defaultPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Preferences',
                style: TextStyleConstants.mediumTitle,
              ),
              const SizedBox(height: SpacingConstants.large),
              
              // Dark Mode Toggle
              _buildSettingTile(
                icon: _darkMode ? Icons.dark_mode : Icons.light_mode,
                title: 'Dark Mode',
                subtitle: 'Enable dark theme for the app',
                trailing: Switch(
                  value: _darkMode,
                  onChanged: (value) {
                    setState(() {
                      _darkMode = value;
                    });
                  },
                  activeColor: ColorConstants.primaryGreen,
                ),
              ),
              
              const Divider(),
              
              // Notifications Toggle
              _buildSettingTile(
                icon: Icons.notifications,
                title: 'Notifications',
                subtitle: 'Receive reminders and updates',
                trailing: Switch(
                  value: _notifications,
                  onChanged: (value) {
                    setState(() {
                      _notifications = value;
                    });
                  },
                  activeColor: ColorConstants.primaryGreen,
                ),
              ),
              
              const Divider(),
              
              // Unit System Selector
              _buildSettingTile(
                icon: Icons.straighten,
                title: 'Unit System',
                subtitle: 'Select measurement units',
                trailing: DropdownButton<String>(
                  value: _unitSystem,
                  items: const [
                    DropdownMenuItem(
                      value: 'metric',
                      child: Text('Metric (kg/cm)'),
                    ),
                    DropdownMenuItem(
                      value: 'imperial',
                      child: Text('Imperial (lbs/ft)'),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _unitSystem = value;
                      });
                    }
                  },
                ),
              ),
              
              const SizedBox(height: SpacingConstants.large),
              
              const Text(
                'About',
                style: TextStyleConstants.mediumTitle,
              ),
              const SizedBox(height: SpacingConstants.large),
              
              // App Version
              _buildSettingTile(
                icon: Icons.info,
                title: 'App Version',
                subtitle: '1.0.0',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              
              const Divider(),
              
              // Privacy Policy
              _buildSettingTile(
                icon: Icons.privacy_tip,
                title: 'Privacy Policy',
                subtitle: 'Read our privacy policy',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              
              const Divider(),
              
              // Terms of Service
              _buildSettingTile(
                icon: Icons.description,
                title: 'Terms of Service',
                subtitle: 'Read our terms of service',
                trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              ),
              
              const SizedBox(height: SpacingConstants.huge),
              
              // Reset Settings Button
              Center(
                child: OutlinedButton(
                  onPressed: _resetSettings,
                  style: OutlinedButton.styleFrom(
                    padding: SpacingConstants.buttonPadding,
                    side: const BorderSide(color: ColorConstants.primaryGreen),
                  ),
                  child: const Text(
                    'Reset to Defaults',
                    style: TextStyleConstants.buttonText,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a setting tile with consistent styling
  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: ColorConstants.primaryGreen),
      title: Text(title, style: TextStyleConstants.smallTitle),
      subtitle: Text(subtitle, style: TextStyleConstants.smallBody),
      trailing: trailing,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// Resets all settings to default values
  void _resetSettings() {
    setState(() {
      _darkMode = false;
      _notifications = true;
      _unitSystem = 'metric';
    });
    
    // Show confirmation message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Settings reset to defaults'),
        backgroundColor: ColorConstants.primaryGreen,
      ),
    );
  }
}