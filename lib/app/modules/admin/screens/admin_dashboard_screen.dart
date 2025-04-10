import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardScreen extends GetView<AdminDashboardController> {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Use OrientationBuilder for responsive layout
    return OrientationBuilder(
      builder: (context, orientation) {
        final bool isLargeScreen = Get.width >= 600; // Example breakpoint

        return Scaffold(
          appBar: _buildAppBar(isLargeScreen),
          // Drawer for smaller screens
          drawer: isLargeScreen ? null : _buildDrawer(),
          body: Row(
            children: [
              // Navigation Rail for larger screens
              if (isLargeScreen) _buildNavigationRail(),

              // Main content area
              Expanded(
                // The actual content is decided by the controller based on selectedIndex
                // No need for _buildPageContent here, as navigation is handled elsewhere
                child: controller.currentPage,
              ),
            ],
          ),
        );
      },
    );
  }

  // Builds the AppBar
  AppBar _buildAppBar(bool isLargeScreen) {
    return AppBar(
      title: Text('admin_dashboard_title'.tr), // Localized
      centerTitle: false,
      actions: [
        // Refresh Button
        IconButton(
          icon: const Icon(Icons.refresh),
          tooltip: 'refresh_data_tooltip'.tr, // Localized
          onPressed: controller.fetchDashboardMetrics,
        ),
        const SizedBox(width: 10),
        // User Info and Logout
        Obx(() => Padding(
              padding: const EdgeInsets.only(right: 8.0),
              child: Row(
                children: [
                  CircleAvatar(
                    child: Text(controller.adminName.value.isNotEmpty
                        ? controller.adminName.value[0].toUpperCase()
                        : 'A'), // No localization needed for initial
                  ),
                  const SizedBox(width: 8),
                  Text(
                    controller.adminName.value.isNotEmpty
                        ? controller.adminName.value
                        : 'admin_default_name'.tr, // Localized
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            )),
        IconButton(
          icon: const Icon(Icons.logout),
          tooltip: 'sign_out_tooltip'.tr, // Localized
          onPressed: controller.signOut,
        ),
        const SizedBox(width: 10),
      ],
      // Don't show drawer icon on large screens if using NavigationRail
      leading: isLargeScreen
          ? null
          : Builder(
              builder: (context) => IconButton(
                icon: const Icon(Icons.menu),
                tooltip: 'open_menu_tooltip'.tr, // Localized
                onPressed: () => Scaffold.of(context).openDrawer(),
              ),
            ),
    );
  }

  // Builds the Drawer for small screens
  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Drawer Header
          DrawerHeader(
            decoration: BoxDecoration(color: Get.theme.primaryColor),
            child: Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white70,
                      child: Text(
                        controller.adminName.value.isNotEmpty
                            ? controller.adminName.value[0].toUpperCase()
                            : 'A', // No localization needed for initial
                        style: TextStyle(
                            fontSize: 24, color: Get.theme.primaryColor),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      controller.adminName.value.isNotEmpty
                          ? controller.adminName.value
                          : 'admin_default_name'.tr, // Localized
                      style: const TextStyle(color: Colors.white, fontSize: 18),
                    ),
                    Text(
                      controller.adminRole
                          .value, // Role might not need localization if system value
                      style:
                          const TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                  ],
                )),
          ),
          // Navigation Items
          _buildDrawerItem(
              Icons.dashboard, 'drawer_dashboard'.tr, 0), // Localized
          _buildDrawerItem(Icons.verified_user, 'drawer_kyc_verification'.tr,
              1), // Localized
          _buildDrawerItem(
              Icons.store, 'drawer_pawnbroker_verification'.tr, 2), // Localized
          _buildDrawerItem(
              Icons.people, 'drawer_user_management'.tr, 3), // Localized
          _buildDrawerItem(
              Icons.assessment, 'drawer_loan_monitoring'.tr, 4), // Localized
          _buildDrawerItem(Icons.manage_accounts, 'drawer_admin_management'.tr,
              7), // Localized
          _buildDrawerItem(
              Icons.settings, 'drawer_settings'.tr, 5), // Localized
          _buildDrawerItem(Icons.history, 'drawer_logs'.tr, 6), // Localized
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout),
            title: Text('drawer_sign_out'.tr), // Localized
            onTap: controller.signOut,
          ),
        ],
      ),
    );
  }

  // Helper to build Drawer list items
  Widget _buildDrawerItem(IconData icon, String title, int index) {
    return Obx(() => ListTile(
          leading: Icon(icon,
              color: controller.selectedIndex.value == index
                  ? Get.theme.primaryColor
                  : null),
          title: Text(title, // Title is already localized from call site
              style: TextStyle(
                  color: controller.selectedIndex.value == index
                      ? Get.theme.primaryColor
                      : null)),
          selected: controller.selectedIndex.value == index,
          onTap: () {
            controller.changePage(index);
            Get.back(); // Close the drawer
          },
        ));
  }

  // Builds the NavigationRail for large screens
  Widget _buildNavigationRail() {
    return Obx(() => NavigationRail(
          selectedIndex: controller.selectedIndex.value,
          onDestinationSelected: controller.changePage,
          labelType: NavigationRailLabelType.selected, // Or .all / .none
          leading: Column(
            children: [
              const SizedBox(height: 20),
              CircleAvatar(
                radius: 30,
                backgroundColor: Get.theme.primaryColorLight,
                child: Icon(Icons.admin_panel_settings,
                    size: 30, color: Get.theme.primaryColorDark),
              ),
              const SizedBox(height: 8),
              Text(
                controller.adminName.value.isNotEmpty
                    ? controller.adminName.value
                    : 'admin_default_name'.tr, // Localized
                style: Get.textTheme.titleSmall,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                controller.adminRole.value, // Role might not need localization
                style: Get.textTheme.bodySmall,
              ),
              const SizedBox(height: 20),
              const Divider(),
            ],
          ),
          destinations: <NavigationRailDestination>[
            NavigationRailDestination(
              icon: const Icon(Icons.dashboard_outlined),
              selectedIcon: const Icon(Icons.dashboard),
              label: Text('nav_rail_dashboard'.tr), // Localized
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.verified_user_outlined),
              selectedIcon: const Icon(Icons.verified_user),
              label: Text('nav_rail_kyc_verify'.tr), // Localized
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.store_outlined),
              selectedIcon: const Icon(Icons.store),
              label: Text('nav_rail_pawn_verify'.tr), // Localized
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.people_outlined),
              selectedIcon: const Icon(Icons.people),
              label: Text('nav_rail_users'.tr), // Localized
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.assessment_outlined),
              selectedIcon: const Icon(Icons.assessment),
              label: Text('nav_rail_loans'.tr), // Localized
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.manage_accounts_outlined),
              selectedIcon: const Icon(Icons.manage_accounts),
              label: Text('nav_rail_admins'.tr), // Localized
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: const Icon(Icons.settings),
              label: Text('nav_rail_settings'.tr), // Localized
            ),
            NavigationRailDestination(
              icon: const Icon(Icons.history_outlined),
              selectedIcon: const Icon(Icons.history),
              label: Text('nav_rail_logs'.tr), // Localized
            ),
          ],
          trailing: Expanded(
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: IconButton(
                  icon: const Icon(Icons.logout),
                  tooltip: 'sign_out_tooltip'.tr, // Localized
                  onPressed: controller.signOut,
                ),
              ),
            ),
          ),
        ));
  }

  // Builds the main content based on the selected index
  // REMOVED _buildPageContent - Handled by controller

  // Builds the main dashboard content (Placeholder)
  // REMOVED _buildDashboardContent - This is now a separate widget/view

  // Helper to build dashboard metric cards
  // REMOVED _buildMetricCard - This is now part of the separate dashboard widget/view
}
