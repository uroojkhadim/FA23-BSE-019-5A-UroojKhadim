import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'product_management_screen.dart';
import 'pos_screen.dart';
import 'customer_management_screen.dart';
import 'reports_screen.dart';
import 'backup_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(AppConstants.appName),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
          PopupMenuButton(
            onSelected: (value) {
              if (value == 'logout') {
                _logout(context);
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          if (authProvider.currentUser == null) {
            return const Center(
              child: Text('User not authenticated'),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(AppConstants.paddingMedium),
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: AppConstants.paddingMedium,
              mainAxisSpacing: AppConstants.paddingMedium,
              children: [
                _buildHomeCard(
                  context,
                  title: 'POS System',
                  icon: Icons.point_of_sale,
                  color: Colors.blue,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PosScreen(),
                    ),
                  ),
                ),
                _buildHomeCard(
                  context,
                  title: 'Products',
                  icon: Icons.inventory,
                  color: Colors.green,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProductManagementScreen(),
                    ),
                  ),
                ),
                _buildHomeCard(
                  context,
                  title: 'Customers',
                  icon: Icons.people,
                  color: Colors.orange,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CustomerManagementScreen(),
                    ),
                  ),
                ),
                _buildHomeCard(
                  context,
                  title: 'Reports',
                  icon: Icons.bar_chart,
                  color: Colors.purple,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportsScreen(),
                    ),
                  ),
                ),
                _buildHomeCard(
                  context,
                  title: 'Backup',
                  icon: Icons.backup,
                  color: Colors.teal,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BackupScreen(),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHomeCard(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      ),
      child: InkWell(
        onTap: onTap,
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

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }
}