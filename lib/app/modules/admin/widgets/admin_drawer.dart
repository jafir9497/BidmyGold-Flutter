import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../routes/app_pages.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const CircleAvatar(
                  radius: 32,
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.admin_panel_settings,
                    size: 40,
                    color: Colors.indigo,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Admin Dashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Manage BidMyGold Platform',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.dashboard,
            title: 'Dashboard',
            onTap: () => _navigateTo(Routes.ADMIN_DASHBOARD),
            selected: Get.currentRoute == Routes.ADMIN_DASHBOARD,
          ),
          _buildDrawerItem(
            icon: Icons.admin_panel_settings,
            title: 'Admin Management',
            onTap: () => _navigateTo(Routes.ADMIN_MANAGEMENT),
            selected: Get.currentRoute == Routes.ADMIN_MANAGEMENT,
          ),
          _buildDrawerItem(
            icon: Icons.people_alt,
            title: 'User Management',
            onTap: () => _navigateTo(Routes.USER_MANAGEMENT),
            selected: Get.currentRoute == Routes.USER_MANAGEMENT,
          ),
          _buildDrawerItem(
            icon: Icons.verified_user,
            title: 'KYC Verification',
            onTap: () => _navigateTo(Routes.KYC_VERIFICATION),
            selected: Get.currentRoute == Routes.KYC_VERIFICATION,
          ),
          _buildDrawerItem(
            icon: Icons.store,
            title: 'Pawnbroker Verification',
            onTap: () => _navigateTo(Routes.PAWNBROKER_VERIFICATION),
            selected: Get.currentRoute == Routes.PAWNBROKER_VERIFICATION,
          ),
          _buildDrawerItem(
            icon: Icons.assignment,
            title: 'Loan Monitoring',
            onTap: () => _navigateTo(Routes.LOAN_MONITORING),
            selected: Get.currentRoute == Routes.LOAN_MONITORING,
          ),
          _buildDrawerItem(
            icon: Icons.settings,
            title: 'System Settings',
            onTap: () => _navigateTo(Routes.SYSTEM_SETTINGS),
            selected: Get.currentRoute == Routes.SYSTEM_SETTINGS,
          ),
          const Divider(),
          _buildDrawerItem(
            icon: Icons.logout,
            title: 'Logout',
            onTap: () {
              // Implement logout functionality
              Get.offAllNamed(Routes.LOGIN);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    bool selected = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: selected ? Colors.indigo : Colors.grey[700],
      ),
      title: Text(
        title,
        style: TextStyle(
          color: selected ? Colors.indigo : Colors.grey[900],
          fontWeight: selected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      onTap: onTap,
      selected: selected,
      selectedTileColor: Colors.indigo.withOpacity(0.1),
    );
  }

  void _navigateTo(String route) {
    // Close drawer
    Get.back();

    // Navigate only if we're not already on that route
    if (Get.currentRoute != route) {
      Get.toNamed(route);
    }
  }
}
