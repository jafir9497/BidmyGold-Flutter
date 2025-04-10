import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/admin_auth_service.dart';
import '../models/activity_log.dart';
import '../models/admin_log_entry.dart';

class AdminLogsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminAuthService _authService = Get.find<AdminAuthService>();

  // Observables
  final RxList<AdminLogEntry> logs = <AdminLogEntry>[].obs;
  final RxBool isLoading = false.obs;
  final RxString searchQuery = ''.obs;
  final RxString filterByAdminId = ''.obs;
  final RxBool isInitialLoading = true.obs;
  final RxList<AdminLogEntry> adminLogs = <AdminLogEntry>[].obs;

  // Pagination
  final int _pageSize = 20;
  DocumentSnapshot? _lastDocument;
  final RxBool hasMoreData = true.obs;
  final RxBool isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchLogs(isRefresh: true);
  }

  Future<void> fetchLogs({bool isRefresh = false}) async {
    if (isLoadingMore.value) return;

    if (isRefresh) {
      isInitialLoading.value = true;
      _lastDocument = null;
      hasMoreData.value = true;
      logs.clear();
    }

    if (!hasMoreData.value) return;

    isLoading.value = true;
    if (!isRefresh) isLoadingMore.value = true;

    try {
      Query query = _firestore
          .collection('admin_logs')
          .orderBy('timestamp', descending: true)
          .limit(_pageSize);

      if (filterByAdminId.isNotEmpty) {
        query = query.where('adminId', isEqualTo: filterByAdminId.value);
      }

      if (_lastDocument != null && !isRefresh) {
        query = query.startAfterDocument(_lastDocument!);
      }

      final snapshot = await query.get();

      if (snapshot.docs.isEmpty) {
        hasMoreData.value = false;
      } else {
        _lastDocument = snapshot.docs.last;
        final fetchedLogs = snapshot.docs
            .map((doc) => AdminLogEntry.fromFirestore(doc))
            .toList();

        if (isRefresh) {
          logs.value = fetchedLogs;
        } else {
          logs.addAll(fetchedLogs);
        }

        if (snapshot.docs.length < _pageSize) {
          hasMoreData.value = false;
        }
      }
    } catch (e) {
      print('Error fetching activity logs: $e');
      Get.snackbar('Error', 'Failed to load activity logs: $e');
    } finally {
      isLoading.value = false;
      isInitialLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  List<AdminLogEntry> _filterLogsBySearch(List<AdminLogEntry> logList) {
    final query = searchQuery.value.toLowerCase();
    return logList.where((log) {
      return log.action.toLowerCase().contains(query) ||
          log.adminName.toLowerCase().contains(query);
    }).toList();
  }

  void setSearchQuery(String query) {
    searchQuery.value = query;
    refreshLogs();
  }

  void setAdminFilter(String adminId) {
    filterByAdminId.value = adminId;
    refreshLogs();
  }

  void clearFilters() {
    searchQuery.value = '';
    filterByAdminId.value = '';
    refreshLogs();
  }

  void refreshLogs() {
    fetchLogs(isRefresh: true);
  }

  void loadMoreLogs() {
    if (!isLoading.value && hasMoreData.value && !isLoadingMore.value) {
      fetchLogs();
    }
  }
}
