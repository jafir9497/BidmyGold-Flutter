import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/admin_dashboard_controller.dart'; // Access controller

class AdminDashboardContent extends StatelessWidget {
  const AdminDashboardContent({super.key});

  @override
  Widget build(BuildContext context) {
    // Find the controller to access its observables
    final AdminDashboardController controller =
        Get.find<AdminDashboardController>();

    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      return SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'welcome_admin'
                  .trParams({'name': controller.adminName.value}), // Localized
              style: Get.textTheme.headlineSmall,
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 20,
              runSpacing: 20,
              children: [
                _buildMetricCard(
                    'metric_total_users'.tr, // Localized
                    controller.totalUsers.value.toString(),
                    Icons.people,
                    Colors.blue),
                _buildMetricCard(
                    'metric_total_pawnbrokers'.tr, // Localized
                    controller.totalPawnbrokers.value.toString(),
                    Icons.store,
                    Colors.green),
                _buildMetricCard(
                    'metric_pending_kyc'.tr, // Localized
                    controller.pendingKycVerifications.value.toString(),
                    Icons.verified_user,
                    Colors.orange),
                _buildMetricCard(
                    'metric_pending_pawnbrokers'.tr, // Localized
                    controller.pendingPawnbrokerVerifications.value.toString(),
                    Icons.business,
                    Colors.purple),
                _buildMetricCard(
                    'metric_active_loans'.tr, // Localized
                    controller.activeLoanRequests.value.toString(),
                    Icons.monetization_on,
                    Colors.red),
              ],
            ),
            // TODO: Add charts and recent activity sections later
            const SizedBox(height: 30),
            Text('recent_activity_title'.tr,
                style: Get.textTheme.titleLarge), // Localized
            const SizedBox(height: 10),
            Card(
              // Keep const here
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.amber),
                title: Text('placeholder_recent_activity'.tr), // Localized
                subtitle: Text('placeholder_implement_later'.tr), // Localized
              ),
            )
          ],
        ),
      );
    });
  }

  // Helper to build dashboard metric cards (extracted from original screen)
  Widget _buildMetricCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: const EdgeInsets.all(20),
        width: 200, // Adjust width as needed
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, // Title is already localized
                    style: TextStyle(color: Colors.grey[600])),
                Icon(icon, color: color, size: 28)
              ],
            ),
            const SizedBox(height: 10),
            Text(value,
                style: TextStyle(
                    fontSize: 28, fontWeight: FontWeight.bold, color: color)),
          ],
        ),
      ),
    );
  }
}
