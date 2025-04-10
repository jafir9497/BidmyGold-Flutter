import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PawnbrokerDashboardController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observables for pawnbroker profile
  var isLoading = true.obs;
  var shopName = ''.obs;
  var ownerName = ''.obs;
  var address = ''.obs;
  var verificationStatus = 'pending'.obs; // 'pending', 'verified', 'rejected'
  var rejectionReason =
      ''.obs; // Reason for rejection if verification was rejected
  var averageRating = 0.0.obs; // Added for average rating
  var totalRatings = 0.obs; // Added for total rating count

  // Loan requests
  var loanRequests = <Map<String, dynamic>>[].obs;
  var isLoadingRequests = true.obs;

  // Bids history
  var bidsHistory = <Map<String, dynamic>>[].obs;
  var isLoadingBids = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPawnbrokerData();
    fetchLoanRequests();
    fetchBidsHistory();
  }

  // Fetch pawnbroker profile data from Firestore
  Future<void> fetchPawnbrokerData() async {
    try {
      isLoading.value = true;

      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        // Handle case where user is not logged in
        return;
      }

      final doc = await _firestore.collection('pawnbrokers').doc(userId).get();

      if (doc.exists) {
        final data = doc.data()!;
        shopName.value = data['shopName'] ?? '';
        ownerName.value = data['ownerName'] ?? '';
        address.value = data['address'] ?? '';
        verificationStatus.value = data['verificationStatus'] ?? 'pending';
        // Get rejection reason if status is rejected
        rejectionReason.value = data['rejectionReason'] ?? '';
        // Get rating info
        averageRating.value = (data['averageRating'] ?? 0.0).toDouble();
        totalRatings.value = data['totalRatings'] ?? 0;
      }
    } catch (e) {
      print('Error fetching pawnbroker data: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Fetch nearby loan requests
  Future<void> fetchLoanRequests() async {
    try {
      isLoadingRequests.value = true;

      // In a real app, this would filter by the pawnbroker's service area
      // For now, just get all loan requests
      final snapshot = await _firestore
          .collection('loanRequests')
          .where('status', isEqualTo: 'pending')
          .orderBy('createdAt', descending: true)
          .limit(10)
          .get();

      final requests = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'jewelType': data['jewelType'] ?? '',
          'jewelWeight': data['jewelWeight'] ?? 0.0,
          'requestedAmount': data['requestedAmount'] ?? 0,
          'userUid': data['userUid'] ?? '',
          'createdAt': data['createdAt'] ?? Timestamp.now(),
          'photos': data['photos'] ?? [],
          // Add other relevant fields
        };
      }).toList();

      loanRequests.value = requests;
    } catch (e) {
      print('Error fetching loan requests: $e');
    } finally {
      isLoadingRequests.value = false;
    }
  }

  // Fetch bids history for this pawnbroker
  Future<void> fetchBidsHistory() async {
    try {
      isLoadingBids.value = true;

      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final snapshot = await _firestore
          .collection('bids')
          .where('pawnbrokerUid', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      final bids = snapshot.docs.map((doc) {
        final data = doc.data();
        return {
          'id': doc.id,
          'loanRequestId': data['loanRequestId'] ?? '',
          'offeredAmount': data['offeredAmount'] ?? 0,
          'interestRate': data['interestRate'] ?? 0.0,
          'status':
              data['status'] ?? 'pending', // 'pending', 'accepted', 'rejected'
          'createdAt': data['createdAt'] ?? Timestamp.now(),
          // Add other relevant fields
        };
      }).toList();

      bidsHistory.value = bids;
    } catch (e) {
      print('Error fetching bids history: $e');
    } finally {
      isLoadingBids.value = false;
    }
  }

  // Navigate to view loan request details
  void viewLoanRequestDetails(String requestId) {
    // Navigate to loan request details page
    // Get.toNamed(Routes.PAWNBROKER_LOAN_REQUEST_DETAILS, arguments: requestId);
    print('Navigate to loan request details for ID: $requestId');
  }

  // Navigate to submit a bid
  void submitBid(String requestId) {
    // Navigate to bid submission page
    // Get.toNamed(Routes.PAWNBROKER_SUBMIT_BID, arguments: requestId);
    print('Navigate to submit bid for loan request ID: $requestId');
  }

  // Navigate to view bid details
  void viewBidDetails(String bidId) {
    // Navigate to bid details page
    // Get.toNamed(Routes.PAWNBROKER_BID_DETAILS, arguments: bidId);
    print('Navigate to bid details for ID: $bidId');
  }

  // Refresh all data
  Future<void> refreshData() async {
    await Future.wait(
        [fetchPawnbrokerData(), fetchLoanRequests(), fetchBidsHistory()]);
  }

  // TODO: Implement navigation to a full reviews screen if needed
  void viewAllReviews() {
    print("Navigate to all reviews screen (not implemented)");
  }
}
