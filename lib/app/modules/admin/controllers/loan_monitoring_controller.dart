import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart'; // Added for context
import 'package:get/get.dart';

import '../../../data/models/loan_request_model.dart';
import '../utils/admin_auth_service.dart';
import '../../../routes/app_pages.dart'; // Import routes
import '../../../data/models/user_model.dart'; // Import UserModel

class LoanMonitoringController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminAuthService _authService =
      Get.find<AdminAuthService>(); // For potential future use (logging)

  // Data Observables
  final RxBool isLoading = false.obs;
  final RxList<LoanRequestModel> allLoanRequests = <LoanRequestModel>[].obs;
  final Rxn<DocumentSnapshot> _lastDocument = Rxn<DocumentSnapshot>();
  final RxBool hasMoreData = true.obs;
  final RxBool isLoadingMore = false.obs;
  final int _limit = 15; // Number of requests to fetch per page

  // Detail View Observables
  final RxMap<String, String> userNames = <String, String>{}.obs;
  final RxBool isSubmitting = false.obs; // Added for status updates

  // Filter & Search Observables
  final RxString searchQuery = ''.obs;
  final RxString selectedStatusFilter =
      'all'.obs; // 'all', 'pending', 'active', 'completed', 'rejected' etc.

  // Statistics Observables
  final RxInt totalRequestCount = 0.obs;
  final RxDouble totalRequestedAmount = 0.0.obs;
  // Add more stats as needed (e.g., average amount, counts per status)

  @override
  void onInit() {
    super.onInit();
    fetchInitialLoanRequests();
  }

  // Combined filter and search logic
  List<LoanRequestModel> get filteredLoanRequests {
    return allLoanRequests.where((request) {
      final statusMatch = selectedStatusFilter.value == 'all' ||
          request.status.toLowerCase() == selectedStatusFilter.value;

      final query = searchQuery.value.toLowerCase();
      if (query.isEmpty) return statusMatch;

      final userIdMatch = request.userId.toLowerCase().contains(query);
      final requestIdMatch = request.id.toLowerCase().contains(query);
      final amountMatch = request.loanAmount.toString().contains(query);
      final typeMatch = request.jewelType.toLowerCase().contains(query);

      return statusMatch &&
          (userIdMatch || requestIdMatch || amountMatch || typeMatch);
    }).toList();
  }

  // --- Data Fetching ---

  Future<void> fetchInitialLoanRequests({bool isRefresh = false}) async {
    if (isLoading.value) return;
    isLoading.value = true;
    if (isRefresh) {
      allLoanRequests.clear();
      _lastDocument.value = null;
      hasMoreData.value = true;
    }

    try {
      Query query = _firestore
          .collection('loan_requests')
          .orderBy('createdAt', descending: true);

      // Apply status filter if not 'all'
      if (selectedStatusFilter.value != 'all') {
        query = query.where('status', isEqualTo: selectedStatusFilter.value);
      }

      query = query.limit(_limit);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument.value = snapshot.docs.last;
        final requests = snapshot.docs
            .map((doc) => LoanRequestModel.fromFirestore(doc))
            .toList();
        allLoanRequests.addAll(requests);
        // Fetch user names for newly loaded requests
        _fetchUserNames(requests.map((r) => r.userId).toList());
      } else {
        hasMoreData.value = false;
      }
      // Calculate initial stats after fetching
      calculateStatistics();
    } catch (e) {
      print("Error fetching initial loan requests: $e");
      Get.snackbar('Error', 'Could not load loan requests.');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loadMoreLoanRequests() async {
    if (isLoadingMore.value ||
        !hasMoreData.value ||
        _lastDocument.value == null) {
      return;
    }
    isLoadingMore.value = true;

    try {
      Query query = _firestore
          .collection('loan_requests')
          .orderBy('createdAt', descending: true);

      // Apply status filter if not 'all'
      if (selectedStatusFilter.value != 'all') {
        query = query.where('status', isEqualTo: selectedStatusFilter.value);
      }

      query = query.startAfterDocument(_lastDocument.value!).limit(_limit);

      final snapshot = await query.get();

      if (snapshot.docs.isNotEmpty) {
        _lastDocument.value = snapshot.docs.last;
        final requests = snapshot.docs
            .map((doc) => LoanRequestModel.fromFirestore(doc))
            .toList();
        allLoanRequests.addAll(requests);
        // Fetch user names for newly loaded requests
        _fetchUserNames(requests.map((r) => r.userId).toList());
      } else {
        hasMoreData.value = false;
      }
    } catch (e) {
      print("Error loading more loan requests: $e");
      // Optionally show snackbar
    } finally {
      isLoadingMore.value = false;
    }
  }

  // --- Filtering and Searching ---

  void setSearchQuery(String query) {
    searchQuery.value = query;
    // No need to refetch, filtering is done client-side on the existing list
    // If the dataset becomes very large, server-side search might be needed
  }

  void setStatusFilter(String status) {
    if (selectedStatusFilter.value != status.toLowerCase()) {
      selectedStatusFilter.value = status.toLowerCase();
      // Refetch data with the new filter
      fetchInitialLoanRequests(isRefresh: true);
    }
  }

  // --- Statistics Calculation ---

  void calculateStatistics() {
    // Fetch all documents for accurate stats if needed, or calculate based on loaded data
    // For simplicity, calculating based on currently loaded data
    totalRequestCount.value = allLoanRequests.length;
    totalRequestedAmount.value =
        allLoanRequests.fold(0.0, (sum, item) => sum + item.loanAmount);

    // TODO: Implement more detailed stats if required
    // e.g., Counts per status, average loan amount, etc.
    // This might require fetching *all* documents if not already loaded
    // Or using Firebase aggregation queries (requires setup)
    print(
        'Stats calculated: Count=${totalRequestCount.value}, Amount=${totalRequestedAmount.value}');
  }

  // Fetch user names for a list of user IDs
  Future<void> _fetchUserNames(List<String> userIds) async {
    final idsToFetch =
        userIds.toSet().where((id) => !userNames.containsKey(id)).toList();
    if (idsToFetch.isEmpty) return;

    // Fetch in batches of 10 (Firestore 'in' query limit)
    for (int i = 0; i < idsToFetch.length; i += 10) {
      final batchIds = idsToFetch.sublist(
          i, i + 10 > idsToFetch.length ? idsToFetch.length : i + 10);
      try {
        final snapshot = await _firestore
            .collection('users')
            .where(FieldPath.documentId, whereIn: batchIds)
            .get();
        for (var doc in snapshot.docs) {
          final user = UserModel.fromFirestore(doc);
          userNames[user.id] = user.name ?? 'Unknown User';
        }
      } catch (e) {
        print("Error fetching user names batch: $e");
      }
    }
  }

  // --- Actions ---

  void viewLoanRequestDetails(String requestId) {
    final request = allLoanRequests.firstWhereOrNull((r) => r.id == requestId);
    if (request != null) {
      // Ensure the username is loaded before navigating
      if (!userNames.containsKey(request.userId)) {
        _fetchUserNames([request.userId]).then((_) {
          // Navigate after potentially fetching name
          Get.toNamed(Routes.LOAN_REQUEST_DETAIL, arguments: request);
        });
      } else {
        Get.toNamed(Routes.LOAN_REQUEST_DETAIL, arguments: request);
      }
    } else {
      Get.snackbar('Error', 'Could not find loan request details.');
    }
  }

  // Method to update loan status
  Future<void> updateLoanStatus(String requestId, String newStatus,
      {String? note}) async {
    if (isSubmitting.value) return;
    isSubmitting.value = true;

    try {
      final docRef = _firestore.collection('loan_requests').doc(requestId);
      final updateData = {
        'status': newStatus,
        'updatedAt': FieldValue.serverTimestamp(),
        'statusUpdatedBy': _authService.adminUser.value?.id ?? 'unknown',
      };
      if (note != null && note.isNotEmpty) {
        updateData['adminNote'] = note;
      }

      await docRef.update(updateData);

      // Update local list
      final index = allLoanRequests.indexWhere((r) => r.id == requestId);
      if (index != -1) {
        final updatedRequest =
            allLoanRequests[index].copyWith(status: newStatus);
        allLoanRequests[index] = updatedRequest;
      }

      Get.back(); // Go back from detail screen
      Get.snackbar('Success', 'Loan status updated to $newStatus');
      await _logAdminAction(
          'Updated loan $requestId status to $newStatus${note != null && note.isNotEmpty ? ' with note' : ''}');
    } catch (e) {
      print("Error updating loan status: $e");
      Get.snackbar('Error', 'Failed to update loan status. Please try again.');
    } finally {
      isSubmitting.value = false;
    }
  }

  // Log admin actions
  Future<void> _logAdminAction(String action) async {
    try {
      await _firestore.collection('admin_logs').add({
        'adminId': _authService.adminUser.value?.id ?? 'unknown',
        'adminName': _authService.adminUser.value?.name ?? 'Unknown Admin',
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print("Error logging admin action: $e");
    }
  }
}
