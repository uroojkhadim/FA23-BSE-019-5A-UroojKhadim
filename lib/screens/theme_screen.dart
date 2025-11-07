import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeScreen extends StatefulWidget {
  @override
  _ThemeScreenState createState() => _ThemeScreenState();
}

class _ThemeScreenState extends State<ThemeScreen> {
  bool _isDarkMode = false;
  String _selectedColor = 'purple';
  String _selectedNotificationSound = 'default';

  @override
  void initState() {
    super.initState();
    _loadPreferences();
  }

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isDarkMode = prefs.getBool('isDarkMode') ?? false;
      _selectedColor = prefs.getString('selectedColor') ?? 'purple';
      _selectedNotificationSound = prefs.getString('notificationSound') ?? 'default';
    });
  }

  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    await prefs.setString('selectedColor', _selectedColor);
    await prefs.setString('notificationSound', _selectedNotificationSound);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Theme & Customization'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dark Mode Toggle
            Card(
              child: ListTile(
                title: Text('Dark Mode'),
                trailing: Switch(
                  value: _isDarkMode,
                  onChanged: (value) {
                    setState(() {
                      _isDarkMode = value;
                    });
                    _savePreferences();
                  },
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Color Theme Selection
            Text(
              'Color Theme',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildColorOption('Purple', 'purple', Colors.purple),
                    _buildColorOption('Blue', 'blue', Colors.blue),
                    _buildColorOption('Green', 'green', Colors.green),
                    _buildColorOption('Orange', 'orange', Colors.orange),
                    _buildColorOption('Red', 'red', Colors.red),
                  ],
                ),
              ),
            ),
            
            SizedBox(height: 16),
            
            // Notification Sound Selection
            Text(
              'Notification Sound',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildSoundOption('Default', 'default'),
                    _buildSoundOption('Bell', 'bell'),
                    _buildSoundOption('Chime', 'chime'),
                    _buildSoundOption('Ping', 'ping'),
                    _buildSoundOption('Vibrate Only', 'vibrate'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorOption(String name, String value, Color color) {
    return RadioListTile<String>(
      title: Text(name),
      value: value,
      groupValue: _selectedColor,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedColor = value;
          });
          _savePreferences();
        }
      },
      secondary: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  Widget _buildSoundOption(String name, String value) {
    return RadioListTile<String>(
      title: Text(name),
      value: value,
      groupValue: _selectedNotificationSound,
      onChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedNotificationSound = value;
          });
          _savePreferences();
        }
      },
    );
  }
}