import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return ListView(
            children: [
              // User profile section
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      ListTile(
                        leading: const Icon(Icons.person),
                        title: Text(authProvider.currentUser?.name ?? 'Guest'),
                        subtitle: Text(authProvider.currentUser?.email ?? ''),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showProfileDialog(context),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingSmall),
              
              // Business settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Business Settings',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      ListTile(
                        leading: const Icon(Icons.store),
                        title: const Text('Business Name'),
                        subtitle: const Text('Set your business name'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showBusinessNameDialog(context),
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.receipt),
                        title: const Text('Tax Rate'),
                        subtitle: const Text('Set default tax rate'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showTaxRateDialog(context),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingSmall),
              
              // Sync settings
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sync Settings',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      SwitchListTile(
                        title: const Text('Auto Sync'),
                        subtitle: const Text('Automatically sync when online'),
                        value: true, // This would be controlled by the sync provider
                        onChanged: (value) {
                          // Handle auto sync toggle
                        },
                      ),
                      const Divider(),
                      ListTile(
                        leading: const Icon(Icons.sync),
                        title: const Text('Sync Now'),
                        subtitle: const Text('Manually sync data'),
                        onTap: () => _syncNow(context),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: AppConstants.paddingSmall),
              
              // Security
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.paddingMedium),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Security',
                        style: TextStyle(
                          fontSize: AppConstants.fontSizeLarge,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppConstants.paddingMedium),
                      ListTile(
                        leading: const Icon(Icons.lock),
                        title: const Text('Change Password'),
                        subtitle: const Text('Update your account password'),
                        trailing: const Icon(Icons.arrow_forward_ios),
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showProfileDialog(BuildContext context) {
    // Show profile editing dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Profile Information'),
          content: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              final user = authProvider.currentUser;
              return Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Name: ${user?.name ?? ''}'),
                  Text('Email: ${user?.email ?? ''}'),
                  Text('Username: ${user?.username ?? ''}'),
                  Text('Role: ${user?.role ?? ''}'),
                ],
              );
            },
          ),
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

  void _showBusinessNameDialog(BuildContext context) {
    // Show business name dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Business Name'),
          content: const Text('This feature will be implemented in the next phase.'),
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

  void _showTaxRateDialog(BuildContext context) {
    // Show tax rate dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Tax Rate'),
          content: const Text('This feature will be implemented in the next phase.'),
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

  void _syncNow(BuildContext context) {
    // Trigger sync
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Syncing data...'),
        backgroundColor: Color(AppConstants.primaryColorValue),
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    // Show change password dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change Password'),
          content: const Text('This feature will be implemented in the next phase.'),
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