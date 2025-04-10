import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/admin_auth_service.dart';
import '../models/app_user.dart';
import '../../../data/models/user_model.dart'; // Assuming UserModel exists
import 'package:intl/intl.dart'; // Add import for DateFormat
import '../../../routes/app_pages.dart'; // Import for Routes

class UserManagementController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminAuthService _authService = Get.find<AdminAuthService>();

  // Observables
  final RxBool isLoading = false.obs; // Tracks initial loading or loading more
  final RxBool isInitialLoading = true.obs; // Specifically for the first load
  final RxList<UserModel> users = <UserModel>[].obs;
  final RxList<UserModel> filteredUsers = <UserModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxString selectedFilter = 'all'.obs;
  final Rxn<UserModel> selectedUser = Rxn<UserModel>();
  final RxBool isSubmitting = false.obs;

  // Pagination
  final int _pageSize = 15; // Number of users per page
  DocumentSnapshot? _lastDocument;
  final RxBool hasMoreData = true.obs;
  final RxBool isLoadingMore = false.obs;

  // Stores the ID of the user whose status is currently being toggled
  final RxnString togglingUserId = RxnString();

  @override
  void onInit() {
    super.onInit();
    debounce(searchQuery, (_) => refreshUsers(),
        time: const Duration(milliseconds: 500));
    fetchUsers(isRefresh: true); // Initial fetch
  }

  // Main fetch function, handles refresh and loading more
  Future<void> fetchUsers({bool isRefresh = false}) async {
    if (isLoadingMore.value) return; // Use public property

    if (isRefresh) {
      isInitialLoading.value = true;
      _lastDocument = null;
      hasMoreData.value = true; // Use public property
      users.clear(); // Clear existing users on refresh
    }

    if (!hasMoreData.value) {
      // Use public property
      print("No more users to fetch.");
      return; // No more data to load
    }

    isLoading.value = true;
    if (!isRefresh) isLoadingMore.value = true; // Use public property

    try {
      Query query = _firestore
          .collection('users')
          .orderBy('createdAt', descending: true)
          .limit(_pageSize);

      // Apply pagination
      if (_lastDocument != null && !isRefresh) {
        query = query.startAfterDocument(_lastDocument!);
      }

      // --- NOTE: Filtering is complex with Firestore pagination & client-side search ---
      // Simple approach: Fetch paginated data, then filter client-side.
      // More complex: Modify Firestore query based on filters (requires indexes).
      // Let's stick to client-side filtering for now after fetching a page.

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        hasMoreData.value = false; // Use public property
      } else {
        _lastDocument = snapshot.docs.last;
        final fetchedUsers =
            snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();

        if (isRefresh) {
          users.value = fetchedUsers;
        } else {
          users.addAll(fetchedUsers);
        }

        // Check if the number of fetched docs is less than page size
        if (snapshot.docs.length < _pageSize) {
          hasMoreData.value = false; // Use public property
        }

        // Apply filters/search to the *entire* current users list
        _applyFiltersAndSearch();
      }
    } catch (e) {
      print("Error fetching users: \$e");
      Get.snackbar('Error', 'Failed to fetch users: \${e.toString()}');
    } finally {
      isLoading.value = false;
      isInitialLoading.value = false; // Initial loading finished
      isLoadingMore.value = false; // Use public property
    }
  }

  // Renamed from filterUsers to avoid confusion with fetch filtering
  void _applyFiltersAndSearch() {
    final query = searchQuery.value.toLowerCase();
    final filter = selectedFilter.value;

    filteredUsers.value = users.where((user) {
      // Apply status filter
      bool statusMatch = true;
      if (filter == 'disabled') {
        statusMatch = user.isDisabled; // Show only disabled users
      } else if (filter != 'all') {
        // For other filters, ensure user is NOT disabled first
        if (user.isDisabled) return false;
        // Then check KYC status
        statusMatch = (user.kycStatus ?? 'pending').toLowerCase() == filter;
      } else {
        // 'all' filter: Still exclude disabled users unless explicitly asked for?
        // Or show truly all? Let's show all non-disabled for 'all'.
        // If you want to show literally *all*, remove this check.
        if (user.isDisabled) return false;
      }

      if (!statusMatch) return false;

      // Apply search query filter
      if (query.isEmpty) return true;
      return (user.name ?? '').toLowerCase().contains(query) ||
          (user.email ?? '').toLowerCase().contains(query) ||
          (user.phone ?? '').toLowerCase().contains(query);
    }).toList();
  }

  void setSearchQuery(String query) {
    if (searchQuery.value != query) {
      searchQuery.value = query;
      // Debounced refresh handles applying the search
    }
  }

  void setFilter(String filter) {
    if (selectedFilter.value != filter) {
      selectedFilter.value = filter;
      refreshUsers(); // Re-fetch and filter when filter changes
    }
  }

  // Triggered by UI to load next page
  void loadMoreUsers() {
    print("Attempting to load more users...");
    if (!isLoading.value && hasMoreData.value && !isLoadingMore.value) {
      // Use public properties
      fetchUsers();
    }
  }

  // Called when search query or filter changes to reset and fetch
  Future<void> refreshUsers() async {
    await fetchUsers(isRefresh: true);
  }

  void selectUser(UserModel user) {
    selectedUser.value = user;
  }

  void clearSelectedUser() {
    selectedUser.value = null;
  }

  Future<void> toggleUserAccountStatus(
      String userId, bool currentIsDisabledStatus) async {
    // Prevent multiple toggles at once
    if (togglingUserId.value != null) return; // Use public property

    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: Text(currentIsDisabledStatus ? 'Enable User' : 'Disable User'),
        content: Text(
            'Are you sure you want to ${currentIsDisabledStatus ? "enable" : "disable"} this user account?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            child: Text(currentIsDisabledStatus ? 'Enable' : 'Disable'),
            style: TextButton.styleFrom(
              foregroundColor:
                  currentIsDisabledStatus ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    togglingUserId.value = userId; // Use public property
    isLoading.value = true; // Use general loading indicator for simplicity

    try {
      final bool newStatus = !currentIsDisabledStatus;
      await _firestore.collection('users').doc(userId).update({
        'isDisabled': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'lastModifiedByAdmin':
            _authService.adminUser.value?.id ?? 'unknown', // Log admin ID
      });

      // Log admin action
      await _logAdminAction(
          '${newStatus ? "Disabled" : "Enabled"} user account for ID: $userId');

      // Update local list immediately for responsiveness
      int index = users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        users[index] = users[index].copyWith(isDisabled: newStatus);
        // Re-apply filters to update the filtered list
        _applyFiltersAndSearch();
      }

      Get.snackbar('Success', 'User account status updated.');
    } catch (e) {
      print("Error updating user status: $e");
      Get.snackbar('Error', 'Failed to update user status.');
    } finally {
      isLoading.value = false;
      togglingUserId.value = null; // Use public property
    }
  }

  void viewUserDetails(UserModel user) {
    // Navigate to the dedicated detail screen, passing the user object
    Get.toNamed(Routes.USER_PROFILE_DETAIL, arguments: user);
  }

  Future<void> deleteUser(String userId) async {
    isSubmitting.value = true;
    try {
      // Show confirmation dialog
      final confirm = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text(
              'This action cannot be undone. All user data including KYC documents and loan requests will be deleted.\n\nAre you sure you want to proceed?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Delete'),
            ),
          ],
        ),
      );

      if (confirm != true) {
        isSubmitting.value = false;
        return;
      }

      // Delete from users collection
      await _firestore.collection('users').doc(userId).delete();

      // Log admin action
      await _logAdminAction('Deleted user $userId');

      // Clear selection if this was the selected user
      if (selectedUser.value?.id == userId) {
        clearSelectedUser();
      }

      // Remove from the list
      users.removeWhere((user) => user.id == userId);

      Get.snackbar('Success', 'User deleted successfully',
          snackPosition: SnackPosition.BOTTOM);
    } catch (e) {
      print('Error deleting user: $e');
      Get.snackbar('Error', 'Failed to delete user: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // Log admin actions for audit trail
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
