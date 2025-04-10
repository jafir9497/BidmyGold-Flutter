import 'package:flutter/material.dart'; // For TextEditingController
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../../../data/models/user_model.dart';
import '../utils/admin_auth_service.dart';

class KycVerificationController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final AdminAuthService _authService = Get.find<AdminAuthService>();

  // Observables for pending users
  final RxList<UserModel> pendingUsers = <UserModel>[].obs;
  final RxBool isLoading = true.obs;
  final Rxn<UserModel> selectedUser = Rxn<UserModel>();
  final RxString searchQuery = ''.obs;

  // Observables for detailed view
  final RxnString idProofUrl = RxnString();
  final RxnString addressProofUrl = RxnString();
  final RxnString selfieUrl = RxnString();
  final rejectionReasonController = TextEditingController(); // Use controller
  final RxBool isSubmitting = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Debounce search if needed
    debounce(searchQuery, (_) => _filterUsers(),
        time: const Duration(milliseconds: 300));
    fetchPendingUsers();
  }

  @override
  void onClose() {
    rejectionReasonController.dispose();
    super.onClose();
  }

  // Fetch users with pending KYC status
  Future<void> fetchPendingUsers() async {
    isLoading.value = true;
    try {
      final QuerySnapshot snapshot = await _firestore
          .collection('users')
          .where('kycStatus', isEqualTo: 'pending') // Fetch pending users
          .orderBy('createdAt', descending: true)
          .get();

      pendingUsers.value =
          snapshot.docs.map((doc) => UserModel.fromFirestore(doc)).toList();
      // Apply initial filter/search if any
      _filterUsers();
    } catch (e) {
      print('Error fetching pending KYC users: $e');
      Get.snackbar('Error', 'Failed to load pending users');
    } finally {
      isLoading.value = false;
    }
  }

  // --- Filtering/Searching Logic ---
  // Computed property for filtered list based on search query
  List<UserModel> get filteredPendingUsers {
    if (searchQuery.isEmpty) {
      return pendingUsers;
    }
    final query = searchQuery.value.toLowerCase();
    return pendingUsers.where((user) {
      return (user.name ?? '').toLowerCase().contains(query) ||
          (user.phone ?? '').toLowerCase().contains(query) ||
          (user.email ?? '').toLowerCase().contains(query);
    }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    // Filtering is done reactively by the getter
  }

  // Apply filter/search (called internally)
  void _filterUsers() {
    // This is now handled by the computed property `filteredPendingUsers` used in the UI
    // We might trigger an update if needed, but Obx should handle it.
    pendingUsers.refresh(); // Trigger update for Obx using the getter
  }

  // Select user and fetch their document URLs
  void selectUser(UserModel user) {
    selectedUser.value = user;
    // Reset fields for the new selection
    idProofUrl.value = null;
    addressProofUrl.value = null;
    selfieUrl.value = null;
    rejectionReasonController.clear();

    // Fetch URLs from the user's kycDocuments map
    final docs = user.kycDocuments;
    if (docs != null) {
      idProofUrl.value = docs['idProofUrl'] as String?;
      addressProofUrl.value = docs['addressProofUrl'] as String?;
      selfieUrl.value = docs['selfieUrl'] as String?;
      // Print URLs for debugging
      print('ID Proof URL: ${idProofUrl.value}');
      print('Address Proof URL: ${addressProofUrl.value}');
      print('Selfie URL: ${selfieUrl.value}');
    } else {
      print('KYC documents map is null for user ${user.id}');
    }
  }

  void clearSelectedUser() {
    selectedUser.value = null;
    idProofUrl.value = null;
    addressProofUrl.value = null;
    selfieUrl.value = null;
    rejectionReasonController.clear();
  }

  // Approve KYC
  Future<void> approveRequest() async {
    if (selectedUser.value == null) return;
    isSubmitting.value = true;

    try {
      final userId = selectedUser.value!.id;
      await _firestore.collection('users').doc(userId).update({
        'kycStatus': 'verified',
        'kycVerifiedAt': FieldValue.serverTimestamp(),
        'kycVerifiedByAdminId': _authService.adminUser.value?.id ?? 'unknown',
        'kycRejectionReason': null, // Clear any previous rejection reason
      });

      await _logAdminAction('Approved KYC for user: $userId');
      Get.snackbar('Success', 'KYC Approved successfully');
      _postActionCleanup(); // Refresh list and clear selection
    } catch (e) {
      print('Error approving KYC: $e');
      Get.snackbar('Error', 'Failed to approve KYC: ${e.toString()}');
    } finally {
      isSubmitting.value = false;
    }
  }

  // Reject KYC
  Future<void> rejectRequest() async {
    if (selectedUser.value == null) return;
    final reason = rejectionReasonController.text.trim();
    if (reason.isEmpty) {
      Get.snackbar('Error', 'Rejection reason is required');
      return;
    }
    isSubmitting.value = true;

    try {
      final userId = selectedUser.value!.id;
      await _firestore.collection('users').doc(userId).update({
        'kycStatus': 'rejected',
        'kycRejectionReason': reason,
        'kycVerifiedAt': FieldValue.serverTimestamp(), // Timestamp of review
        'kycVerifiedByAdminId': _authService.adminUser.value?.id ?? 'unknown',
      });

      await _logAdminAction('Rejected KYC for user: $userId. Reason: $reason');
      Get.snackbar('Success', 'KYC Rejected successfully');
      _postActionCleanup(); // Refresh list and clear selection
    } catch (e) {
      print('Error rejecting KYC: $e');
      Get.snackbar('Error', 'Failed to reject KYC: ${e.toString()}');
    } finally {
      isSubmitting.value = false;
    }
  }

  // Helper to run after approve/reject actions
  void _postActionCleanup() {
    clearSelectedUser();
    fetchPendingUsers(); // Refresh the list of pending users
  }

  // Helper to log admin actions
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
