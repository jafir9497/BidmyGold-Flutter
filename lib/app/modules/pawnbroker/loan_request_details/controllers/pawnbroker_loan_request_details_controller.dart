import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart';
import 'package:intl/intl.dart';
import '../../../../data/services/auth_service.dart';

class PawnbrokerLoanRequestDetailsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = Get.find<AuthService>();

  // Observable properties
  var isLoading = true.obs;
  var requestId = ''.obs;
  var loanRequest = Rxn<Map<String, dynamic>>();
  var userDetails = Rxn<Map<String, dynamic>>();
  var existingBid = Rxn<Map<String, dynamic>>();

  // Image variables
  var images = <String>[].obs;
  var videoUrl = RxnString();

  // Getters for UI access
  Map<String, dynamic> get loanRequestData => loanRequest.value ?? {};
  Map<String, dynamic> get userData => userDetails.value ?? {};

  @override
  void onInit() {
    super.onInit();
    requestId.value = Get.arguments['loanRequestId'] ?? '';
    if (requestId.value.isNotEmpty) {
      fetchLoanRequestDetails();
    } else {
      isLoading.value = false;
    }
  }

  Future<void> fetchLoanRequestDetails() async {
    try {
      isLoading.value = true;

      if (requestId.value.isEmpty) return;

      // Get the pawnbroker's ID
      final pawnbrokerId = _auth.currentUser?.uid;
      if (pawnbrokerId == null) return;

      // Fetch loan request details
      final loanRequestDoc = await _firestore
          .collection('loanRequests')
          .doc(requestId.value)
          .get();

      if (!loanRequestDoc.exists) {
        Get.back();
        Get.snackbar('Error', 'Loan request not found');
        return;
      }

      final data = loanRequestDoc.data()!;
      loanRequest.value = {
        'id': loanRequestDoc.id,
        ...data,
      };

      // Extract images and video
      final photos = data['jewelPhotoUrls'] as List<dynamic>? ?? [];
      images.value = photos.cast<String>();

      if (data.containsKey('jewelVideoUrl') && data['jewelVideoUrl'] != null) {
        videoUrl.value = data['jewelVideoUrl'] as String;
      }

      // Fetch user details
      final userId = data['userId'] as String?;
      if (userId != null) {
        final userDoc = await _firestore.collection('users').doc(userId).get();

        if (userDoc.exists) {
          userDetails.value = userDoc.data();
        }
      }

      // Check if the pawnbroker has already placed a bid
      final bidQuery = await _firestore
          .collection('bids')
          .where('loanRequestId', isEqualTo: requestId.value)
          .where('pawnbrokerUid', isEqualTo: pawnbrokerId)
          .limit(1)
          .get();

      if (bidQuery.docs.isNotEmpty) {
        existingBid.value = {
          'id': bidQuery.docs.first.id,
          ...bidQuery.docs.first.data()
        };
      }
    } catch (e) {
      print('Error fetching loan request details: $e');
      Get.snackbar('Error', 'Failed to load request details');
    } finally {
      isLoading.value = false;
    }
  }

  void navigateToPlaceBid() {
    // If the pawnbroker already has a bid, edit it
    if (existingBid.value != null) {
      Get.toNamed(Routes.PAWNBROKER_PLACE_BID, arguments: {
        'loanRequestId': requestId.value,
        'existingBid': existingBid.value,
      });
    } else {
      // Otherwise, create a new bid
      Get.toNamed(Routes.PAWNBROKER_PLACE_BID, arguments: {
        'loanRequestId': requestId.value,
      });
    }
  }

  // Format a Timestamp for display
  String formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else {
      // Handle other possible formats if needed
      return 'N/A';
    }

    return DateFormat('dd MMM yyyy, hh:mm a').format(dateTime);
  }

  void navigateToBidPlacement({bool edit = false}) {
    Get.toNamed(
      Routes.PAWNBROKER_PLACE_BID,
      arguments: {
        'loanRequestId': requestId.value,
        'loanRequestData': loanRequest.value,
        'userData': userDetails.value,
        'editBid': edit,
        'existingBid': edit ? existingBid.value : null,
      },
    )?.then((result) {
      if (result == true) {
        // Refresh data after placing/editing a bid
        fetchLoanRequestDetails();
      }
    });
  }
}
