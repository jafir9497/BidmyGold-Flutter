import 'package:get/get.dart';
import 'package:flutter/material.dart'; // Import Material
import '../utils/admin_auth_service.dart';
import '../../../routes/app_pages.dart'; // Assuming routes are defined here
import 'package:cloud_firestore/cloud_firestore.dart';

// Import screen widgets needed for the getter
import '../screens/widgets/admin_dashboard_content.dart'; // Assuming dashboard content is extracted
import '../screens/kyc_verification_screen.dart';
import '../screens/pawnbroker_verification_screen.dart';
import '../screens/user_management_screen.dart'; // Assuming this exists
import '../screens/loan_monitoring_screen.dart'; // Assuming this exists
import '../screens/system_settings_screen.dart'; // Assuming this exists
import '../screens/admin_logs_screen.dart'; // Assuming this exists
import '../screens/admin_management_screen.dart';

class AdminDashboardController extends GetxController {
  final AdminAuthService _authService = Get.find<AdminAuthService>();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observables for dashboard data
  var isLoading = true.obs;
  var adminName = ''.obs;
  var adminRole = ''.obs;
  var totalUsers = 0.obs;
  var totalPawnbrokers = 0.obs;
  var pendingKycVerifications = 0.obs;
  var pendingPawnbrokerVerifications = 0.obs;
  var activeLoanRequests = 0.obs;

  // Selected navigation index
  var selectedIndex = 0.obs;

  // Add getter for the current page widget
  Widget get currentPage {
    switch (selectedIndex.value) {
      case 0: // Dashboard
        return const AdminDashboardContent(); // Use the extracted widget
      case 1: // KYC Verification
        return const KycVerificationScreen();
      case 2: // Pawnbroker Verification
        return const PawnbrokerVerificationScreen();
      case 3: // User Management
        return const UserManagementScreen(); // Assuming UserManagementScreen exists
      case 4: // Loan Monitoring
        return const LoanMonitoringScreen(); // Assuming LoanMonitoringScreen exists
      case 5: // Settings
        return const SystemSettingsScreen(); // Assuming SystemSettingsScreen exists
      case 6: // Logs
        return const AdminLogsScreen(); // Assuming AdminLogsScreen exists
      case 7: // Admin Management
        return const AdminManagementScreen();
      default:
        return const AdminDashboardContent(); // Default to dashboard content
    }
  }

  @override
  void onInit() {
    super.onInit();
    loadAdminData();
    fetchDashboardMetrics();
  }

  // Load basic admin data
  void loadAdminData() {
    final admin = _authService.adminUser.value;
    if (admin != null) {
      adminName.value = admin.name;
      adminRole.value = admin.role;
    }
  }

  // Fetch key metrics for the dashboard
  Future<void> fetchDashboardMetrics() async {
    try {
      isLoading.value = true;

      // Use Future.wait for concurrent fetching
      final results = await Future.wait([
        _firestore.collection('users').count().get(),
        _firestore.collection('pawnbrokers').count().get(),
        _firestore
            .collection('users')
            .where('kycStatus', isEqualTo: 'pending')
            .count()
            .get(),
        _firestore
            .collection('pawnbrokers')
            .where('verificationStatus', isEqualTo: 'pending')
            .count()
            .get(),
        _firestore
            .collection('loan_requests')
            .where('status', isEqualTo: 'pending')
            .count()
            .get(),
      ]);

      totalUsers.value = results[0].count ?? 0;
      totalPawnbrokers.value = results[1].count ?? 0;
      pendingKycVerifications.value = results[2].count ?? 0;
      pendingPawnbrokerVerifications.value = results[3].count ?? 0;
      activeLoanRequests.value = results[4].count ?? 0;
    } catch (e) {
      print('Error fetching dashboard metrics: $e');
      Get.snackbar('Error', 'Failed to load dashboard data.');
    } finally {
      isLoading.value = false;
    }
  }

  // Change selected navigation item
  void changePage(int index) {
    selectedIndex.value = index;
    // No need to navigate using Get.toNamed here,
    // the UI will automatically update based on selectedIndex
    // and the currentPage getter.

    // Remove the old switch statement for navigation
    /*
    switch (index) {
      case 0: // Dashboard
        break;
      case 1: // KYC Verification
        Get.toNamed(Routes.KYC_VERIFICATION);
        break;
      case 2: // Pawnbroker Verification
        Get.toNamed(Routes.PAWNBROKER_VERIFICATION);
        break;
      case 3: // User Management
        Get.toNamed(Routes.USER_MANAGEMENT);
        break;
      case 4: // Loan Monitoring
        Get.toNamed(Routes.LOAN_MONITORING);
        break;
      case 5: // Settings
        Get.toNamed(Routes.SYSTEM_SETTINGS);
        break;
      case 6: // Logs
        Get.toNamed(Routes.ADMIN_LOGS);
        break;
      case 7: // Admin Management
        Get.toNamed(Routes.ADMIN_MANAGEMENT);
        break;
      default:
        break;
    }
    */
  }

  // Sign out function
  Future<void> signOut() async {
    await _authService.signOut();
    Get.offAllNamed(Routes.ADMIN_LOGIN);
  }
}
