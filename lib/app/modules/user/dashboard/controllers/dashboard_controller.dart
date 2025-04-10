import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart';

class DashboardController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // User data
  var userName = ''.obs;
  var userEmail = ''.obs;
  var userPhone = ''.obs;
  var kycStatus = 'pending'.obs; // pending, verified, rejected
  var kycRejectionReason = ''.obs; // Store the reason for KYC rejection

  // Loan requests
  var loanRequests = <Map<String, dynamic>>[].obs;
  var isLoadingRequests = true.obs;
  var hasError = false.obs;
  var errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    loadUserData();
    loadLoanRequests();
  }

  // Load user profile data
  Future<void> loadUserData() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.offAllNamed(Routes.LOGIN);
        return;
      }

      // Get user's phone number from Firebase Auth
      userPhone.value = _auth.currentUser?.phoneNumber ?? '';

      // Get user data from Firestore
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        final userData = userDoc.data() as Map<String, dynamic>;
        userName.value = userData['name'] ?? '';
        userEmail.value = userData['email'] ?? '';
        kycStatus.value = userData['kycStatus'] ?? 'pending';
        // Get KYC rejection reason if available
        kycRejectionReason.value = userData['kycRejectionReason'] ?? '';
      }
    } catch (e) {
      print('Error loading user data: $e');
      hasError.value = true;
      errorMessage.value = 'Failed to load profile data';
    }
  }

  // Load user's loan requests
  Future<void> loadLoanRequests() async {
    try {
      isLoadingRequests.value = true;
      hasError.value = false;

      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.offAllNamed(Routes.LOGIN);
        return;
      }

      // Query loan requests for this user
      final querySnapshot = await _firestore
          .collection('loan_requests')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      final requests = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id; // Add document ID to the data
        return data;
      }).toList();

      loanRequests.value = requests;
      isLoadingRequests.value = false;
    } catch (e) {
      print('Error loading loan requests: $e');
      isLoadingRequests.value = false;
      hasError.value = true;
      errorMessage.value = 'Failed to load loan requests';
    }
  }

  // Create a new loan request
  void createNewLoanRequest() {
    Get.toNamed(Routes.LOAN_REQUEST);
  }

  // View a specific loan request
  void viewLoanRequest(String requestId) {
    // TODO: Navigate to loan request details screen
    print('Viewing loan request: $requestId');
    // Get.toNamed(Routes.LOAN_REQUEST_DETAILS, arguments: requestId);
  }

  // Refresh dashboard data
  Future<void> refreshData() async {
    await loadUserData();
    await loadLoanRequests();
  }

  // Sign out
  void signOut() async {
    try {
      await _auth.signOut();
      Get.offAllNamed(Routes.ANONYMOUS_HOME);
    } catch (e) {
      print('Error signing out: $e');
      Get.snackbar('Error', 'Failed to sign out');
    }
  }
}
