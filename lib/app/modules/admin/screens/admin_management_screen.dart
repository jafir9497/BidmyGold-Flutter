import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/admin_management_controller.dart';
import '../models/admin_user.dart';
import '../widgets/admin_drawer.dart'; // Assuming AdminDrawer exists

class AdminManagementScreen extends GetView<AdminManagementController> {
  const AdminManagementScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('admin_management_title'.tr),
        actions: [
          // Only allow adding admins if current user is super_admin?
          // if (controller.currentUserIsSuperAdmin) // Check role from AuthService
          IconButton(
            icon: const Icon(Icons.add_circle_outline),
            tooltip: 'add_new_admin_tooltip'.tr,
            onPressed: () =>
                controller.openAddEditDialog(), // Open dialog to add
          ),
        ],
      ),
      drawer: const AdminDrawer(), // Use the common admin drawer
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.adminUsers.isEmpty) {
          return Center(
            child: Text('no_admin_users_found'.tr,
                style: TextStyle(fontSize: 16, color: Colors.grey)),
          );
        }
        return ListView.separated(
          itemCount: controller.adminUsers.length,
          itemBuilder: (context, index) {
            final admin = controller.adminUsers[index];
            return _buildAdminListItem(context, admin);
          },
          separatorBuilder: (context, index) => const Divider(height: 0),
        );
      }),
    );
  }

  Widget _buildAdminListItem(BuildContext context, AdminUser admin) {
    final lastLoginDate = admin.lastLogin != null
        ? DateFormat('dd MMM yyyy, hh:mm a').format(admin.lastLogin)
        : 'never'.tr;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: admin.isActive ? Colors.green[100] : Colors.grey[300],
        child: Icon(
          admin.role == 'super_admin'
              ? Icons.shield_outlined
              : Icons.person_outline,
          color: admin.isActive ? Colors.green[700] : Colors.grey[600],
        ),
      ),
      title: Text(admin.name ?? 'unknown_name'.tr,
          style: TextStyle(
              fontWeight: FontWeight.w500,
              color: admin.isActive ? null : Colors.grey)),
      subtitle: Text(
          '${admin.email ?? 'no_email'.tr} • ${'role_label'.tr}: ${admin.role.capitalizeFirst ?? admin.role}\n${'last_login_label'.tr}: $lastLoginDate',
          style: TextStyle(color: admin.isActive ? null : Colors.grey)),
      isThreeLine: true,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Edit Button
          IconButton(
            icon: Icon(Icons.edit_outlined,
                color: Theme.of(context).primaryColor),
            tooltip: 'edit_admin_tooltip'.tr,
            onPressed: () => controller.openAddEditDialog(adminToEdit: admin),
          ),
          // Delete Button (consider disabling for oneself)
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
            tooltip: 'delete_admin_tooltip'.tr,
            // Disable delete for current user? (Requires checking ID)
            // onPressed: controller.authService.adminUser.value?.id == admin.id ? null :
            onPressed: () => controller.deleteAdmin(admin.id, admin.name),
          ),
        ],
      ),
    );
  }
}
