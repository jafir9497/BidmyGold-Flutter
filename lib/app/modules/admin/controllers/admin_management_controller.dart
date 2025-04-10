import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/admin_user.dart';
import '../utils/admin_auth_service.dart';
// TODO: Potentially need Firebase Auth import if creating users with email/password
// import 'package:firebase_auth/firebase_auth.dart';

class AdminManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminAuthService _authService = Get.find<AdminAuthService>();
  // final FirebaseAuth _firebaseAuth = FirebaseAuth.instance; // If needed
  final String _adminCollectionPath =
      'admins'; // Firestore collection for admins

  // Observables
  final RxBool isLoading = true.obs;
  final RxList<AdminUser> adminUsers = <AdminUser>[].obs;
  final Rxn<AdminUser> currentEditingAdmin = Rxn<AdminUser>();
  final RxBool isSaving = false.obs;

  // Form Controllers for Add/Edit Dialog
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController =
      TextEditingController(); // For new users
  final RxString selectedRole = 'admin'.obs;
  final RxBool isAdminActive = true.obs;

  // Getter to check if the current logged-in admin is a super_admin
  bool get isCurrentUserSuperAdmin {
    return _authService.adminUser.value?.role == 'super_admin';
  }

  @override
  void onInit() {
    super.onInit();
    fetchAdminUsers();
  }

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  Future<void> fetchAdminUsers() async {
    isLoading.value = true;
    try {
      final snapshot = await _firestore
          .collection(_adminCollectionPath)
          .orderBy('name') // Order by name
          .get();

      adminUsers.value =
          snapshot.docs.map((doc) => AdminUser.fromFirestore(doc)).toList();
    } catch (e) {
      print("Error fetching admin users: $e");
      Get.snackbar('Error', 'Failed to load admin users: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void openAddEditDialog({AdminUser? adminToEdit}) {
    currentEditingAdmin.value = adminToEdit;

    if (adminToEdit != null) {
      // Populate dialog for editing
      nameController.text = adminToEdit.name;
      emailController.text = adminToEdit.email; // Email usually not editable
      passwordController.clear(); // Don't show existing password
      selectedRole.value = adminToEdit.role;
      isAdminActive.value = adminToEdit.isActive;
    } else {
      // Clear dialog for adding
      nameController.clear();
      emailController.clear();
      passwordController.clear();
      selectedRole.value = 'admin';
      isAdminActive.value = true;
    }

    Get.dialog(
      AlertDialog(
        title: Text(adminToEdit == null ? 'Add New Admin' : 'Edit Admin'),
        content: SingleChildScrollView(
          child: _buildAddEditForm(isEditing: adminToEdit != null),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          Obx(() => ElevatedButton(
                onPressed: isSaving.value ? null : _saveAdmin,
                child: Text(isSaving.value ? 'Saving...' : 'Save'),
              )),
        ],
      ),
      barrierDismissible: false, // Prevent closing by tapping outside
    );
  }

  Widget _buildAddEditForm({required bool isEditing}) {
    // Consider using a Form with GlobalKey for validation
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          enabled: !isSaving.value,
        ),
        const SizedBox(height: 10),
        TextField(
          controller: emailController,
          decoration: const InputDecoration(labelText: 'Email'),
          keyboardType: TextInputType.emailAddress,
          // Disable email editing if needed
          enabled: !isEditing && !isSaving.value,
        ),
        const SizedBox(height: 10),
        // Only show password for new users
        if (!isEditing)
          TextField(
            controller: passwordController,
            decoration:
                const InputDecoration(labelText: 'Password (min 6 chars)'),
            obscureText: true,
            enabled: !isSaving.value,
          ),
        const SizedBox(height: 10),
        // Role Dropdown
        Obx(() => DropdownButtonFormField<String>(
              value: selectedRole.value,
              decoration: const InputDecoration(labelText: 'Role'),
              items: ['admin', 'super_admin'] // Define roles
                  .map((role) => DropdownMenuItem(
                        value: role,
                        child: Text(role.capitalizeFirst ?? role),
                      ))
                  .toList(),
              onChanged: isSaving.value
                  ? null
                  : (value) {
                      if (value != null) selectedRole.value = value;
                    },
            )),
        const SizedBox(height: 10),
        // Active Switch
        Obx(() => SwitchListTile(
              title: const Text('Active Account'),
              value: isAdminActive.value,
              onChanged: isSaving.value
                  ? null
                  : (value) {
                      isAdminActive.value = value;
                    },
              dense: true,
            )),
      ],
    );
  }

  Future<void> _saveAdmin() async {
    // Add check before allowing save
    if (!isCurrentUserSuperAdmin) {
      Get.snackbar('Permission Denied',
          'You do not have permission to save admin users.');
      return;
    }
    isSaving.value = true;
    try {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text;
      final role = selectedRole.value;
      final isActive = isAdminActive.value;

      if (name.isEmpty || email.isEmpty) {
        throw Exception('Name and Email cannot be empty.');
      }

      AdminUser? adminToSave;

      if (currentEditingAdmin.value == null) {
        // --- Adding New Admin ---
        if (password.length < 6) {
          throw Exception('Password must be at least 6 characters long.');
        }

        // 1. Create Firebase Auth user (Requires enabling Email/Password sign-in)
        // UserCredential userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        //   email: email,
        //   password: password,
        // );
        // String newAdminAuthId = userCredential.user!.uid;

        // *** Placeholder ID if not using FirebaseAuth for admins ***
        String newAdminAuthId =
            'TEMP_' + DateTime.now().millisecondsSinceEpoch.toString();

        // 2. Create Admin document in Firestore
        adminToSave = AdminUser(
          id: newAdminAuthId, // Use actual Auth ID or generated ID
          email: email,
          name: name,
          role: role,
          isActive: isActive,
          lastLogin: DateTime.now(), // Set initial lastLogin
        );
        await _firestore
            .collection(_adminCollectionPath)
            .doc(newAdminAuthId)
            .set(adminToSave.toMap());
        await _logAdminAction('Added new admin: $name ($email)');
      } else {
        // --- Updating Existing Admin ---
        final existingAdmin = currentEditingAdmin.value!;
        adminToSave = existingAdmin.copyWith(
          name: name,
          role: role,
          isActive: isActive,
          // Email not editable usually
          // lastLogin updates separately
        );
        await _firestore
            .collection(_adminCollectionPath)
            .doc(existingAdmin.id)
            .update(adminToSave.toMap());
        await _logAdminAction('Updated admin: $name ($email)');
        // TODO: Handle password reset separately if needed
      }

      await fetchAdminUsers(); // Refresh the list
      Get.back(); // Close the dialog
      Get.snackbar('Success', 'Admin user saved successfully!');
    } catch (e) {
      print("Error saving admin user: $e");
      Get.snackbar('Error', 'Failed to save admin: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  Future<void> deleteAdmin(String adminId, String adminName) async {
    // Add check before allowing delete
    if (!isCurrentUserSuperAdmin) {
      Get.snackbar('Permission Denied',
          'You do not have permission to delete admin users.');
      return;
    }
    // Prevent deleting oneself
    if (adminId == _authService.adminUser.value?.id) {
      Get.snackbar('Error', 'You cannot delete your own admin account.');
      return;
    }

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Confirm Deletion'),
        content: Text(
            'Are you sure you want to delete the admin "$adminName"? This action cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel')),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // TODO: Consider what happens to the underlying Auth user if using FirebaseAuth.
      // May need to delete the Auth user as well: await _firebaseAuth.currentUser?.delete(); (risky)
      // Or just disable the Firestore record.

      await _firestore.collection(_adminCollectionPath).doc(adminId).delete();
      await _logAdminAction('Deleted admin: $adminName ($adminId)');
      await fetchAdminUsers(); // Refresh list
      Get.snackbar('Success', 'Admin user deleted.');
    } catch (e) {
      print("Error deleting admin: $e");
      Get.snackbar('Error', 'Failed to delete admin: ${e.toString()}');
    }
  }

  // Helper to log actions
  Future<void> _logAdminAction(String action) async {
    try {
      await _firestore.collection('admin_logs').add({
        'adminId': _authService.adminUser.value?.id ?? 'unknown',
        'adminName': _authService.adminUser.value?.name ?? 'Unknown Admin',
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging admin action: $e');
    }
  }
}
