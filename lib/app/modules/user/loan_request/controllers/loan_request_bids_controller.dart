import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../../../routes/app_pages.dart';
import '../../../../data/models/bid_model.dart';
import '../../../../data/models/loan_request_model.dart';
import '../../../../data/services/notification_service.dart';

class LoanRequestBidsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Observables
  var isLoading = true.obs;
  var loanRequestId = ''.obs;
  var loanRequestData = <String, dynamic>{}.obs;
  var bids = <Map<String, dynamic>>[].obs;
  var pawnbrokerDataMap = <String, Map<String, dynamic>>{}.obs;
  var selectedBid = Rxn<Map<String, dynamic>>();
  var isAccepting = false.obs;

  @override
  void onInit() {
    super.onInit();
    loanRequestId.value = Get.arguments?['loanRequestId'] ?? '';
    if (loanRequestId.value.isNotEmpty) {
      fetchLoanRequestAndBids();
    } else {
      isLoading.value = false;
    }
  }

  Future<void> fetchLoanRequestAndBids() async {
    try {
      isLoading.value = true;

      // Get the current user
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.back();
        return;
      }

      // Fetch loan request details
      final loanRequestDoc = await _firestore
          .collection('loanRequests')
          .doc(loanRequestId.value)
          .get();

      if (!loanRequestDoc.exists) {
        Get.back();
        Get.snackbar(
          'error'.tr,
          'loan_request_not_found'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Ensure the user owns this loan request
      final loanData = loanRequestDoc.data()!;
      if (loanData['userId'] != userId) {
        Get.back();
        Get.snackbar(
          'error'.tr,
          'unauthorized_access'.tr,
          snackPosition: SnackPosition.BOTTOM,
        );
        return;
      }

      // Store loan request data
      loanRequestData.value = {
        'id': loanRequestDoc.id,
        ...loanData,
      };

      // Fetch bids for this loan request
      final bidsQuery = await _firestore
          .collection('bids')
          .where('loanRequestId', isEqualTo: loanRequestId.value)
          .get();

      // Process bids
      final bidsList = <Map<String, dynamic>>[];
      final pawnbrokerIds = <String>{};

      for (final doc in bidsQuery.docs) {
        final bidData = doc.data();
        bidData['id'] = doc.id;

        // Add pawnbroker ID to the set for later lookup
        if (bidData.containsKey('pawnbrokerUid')) {
          pawnbrokerIds.add(bidData['pawnbrokerUid']);
        }

        bidsList.add(bidData);
      }

      // Sort bids by offered amount (highest first)
      bidsList.sort((a, b) {
        final aAmount = a['offeredAmount'] ?? 0.0;
        final bAmount = b['offeredAmount'] ?? 0.0;
        return bAmount.compareTo(aAmount);
      });

      bids.value = bidsList;

      // Fetch pawnbroker details for all bids
      await _fetchPawnbrokerDetails(pawnbrokerIds);
    } catch (e) {
      print('Error fetching loan request and bids: $e');
      Get.snackbar(
        'error'.tr,
        'failed_to_load_bids'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _fetchPawnbrokerDetails(Set<String> pawnbrokerIds) async {
    try {
      final pawnbrokerMap = <String, Map<String, dynamic>>{};

      for (final pawnbrokerId in pawnbrokerIds) {
        final doc =
            await _firestore.collection('pawnbrokers').doc(pawnbrokerId).get();

        if (doc.exists) {
          pawnbrokerMap[pawnbrokerId] = {
            'id': doc.id,
            ...doc.data() ?? {},
          };
        }
      }

      pawnbrokerDataMap.value = pawnbrokerMap;
    } catch (e) {
      print('Error fetching pawnbroker details: $e');
    }
  }

  void viewBidDetails(Map<String, dynamic> bid) {
    selectedBid.value = bid;
    final pawnbrokerData = pawnbrokerDataMap[bid['pawnbrokerUid']] ?? {};

    Get.toNamed(Routes.BID_DETAILS, arguments: {
      'bid': bid,
      'loanRequest': loanRequestData.value,
      'pawnbroker': pawnbrokerData,
    });
  }

  Future<void> acceptBid(Map<String, dynamic> bid) async {
    try {
      // Show confirmation dialog
      final confirmed = await _showConfirmationDialog(bid);
      if (confirmed != true) return;

      isAccepting.value = true;

      // Update bid status to accepted
      await _firestore.collection('bids').doc(bid['id']).update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Update loan request status to bid accepted
      await _firestore
          .collection('loanRequests')
          .doc(loanRequestId.value)
          .update({
        'status': 'bid_accepted',
        'acceptedBidId': bid['id'],
        'acceptedPawnbrokerId': bid['pawnbrokerUid'],
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Reject all other bids
      for (final otherBid in bids) {
        if (otherBid['id'] != bid['id']) {
          await _firestore.collection('bids').doc(otherBid['id']).update({
            'status': 'rejected',
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      }

      // Create appointment for the accepted bid
      final appointmentId = await _createAppointment(bid);

      // Create a chat room between user and pawnbroker
      final chatId = await _createChatRoom(bid);

      // Send notification to the pawnbroker (this would trigger a Cloud Function)
      await _firestore.collection('notifications').add({
        'userId': bid['pawnbrokerUid'],
        'title': 'bid_accepted_title'.tr,
        'body': 'bid_accepted_body'.tr,
        'data': {
          'type': 'bid_accepted',
          'loan_request_id': loanRequestId.value,
          'bid_id': bid['id'],
          'appointment_id': appointmentId,
          'chat_id': chatId,
        },
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Show success message and navigate to the appointment screen
      isAccepting.value = false;
      Get.snackbar(
        'success'.tr,
        'bid_accepted_success'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );

      // Navigate to the appointment details screen
      Get.offNamed(Routes.APPOINTMENT_DETAILS, arguments: {
        'appointmentId': appointmentId,
      });
    } catch (e) {
      isAccepting.value = false;
      print('Error accepting bid: $e');
      Get.snackbar(
        'error'.tr,
        'failed_to_accept_bid'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool?> _showConfirmationDialog(Map<String, dynamic> bid) async {
    final pawnbrokerData = pawnbrokerDataMap[bid['pawnbrokerUid']] ?? {};
    final shopName = pawnbrokerData['shopName'] ?? 'Unknown Shop';

    final offeredAmount = bid['offeredAmount'] ?? 0.0;
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );

    return Get.dialog<bool>(
      AlertDialog(
        title: Text('confirm_accept_bid'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('accept_bid_confirmation'.trParams({
              'shopName': shopName,
              'amount': currencyFormat.format(offeredAmount),
            })),
            const SizedBox(height: 16),
            Text(
              'accept_bid_warning'.tr,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  Future<String> _createAppointment(Map<String, dynamic> bid) async {
    try {
      final userId = _auth.currentUser!.uid;
      final pawnbrokerUid = bid['pawnbrokerUid'];

      // Default appointment date (tomorrow at 12:00 PM)
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final defaultDate = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        12, // Hour (12 PM)
        0, // Minute
      );

      // Create appointment document
      final appointmentRef = await _firestore.collection('appointments').add({
        'loanRequestId': loanRequestId.value,
        'bidId': bid['id'],
        'userId': userId,
        'pawnbrokerId': pawnbrokerUid,
        'proposedDate': Timestamp.fromDate(defaultDate),
        'confirmedDate': null,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      return appointmentRef.id;
    } catch (e) {
      print('Error creating appointment: $e');
      rethrow;
    }
  }

  Future<String> _createChatRoom(Map<String, dynamic> bid) async {
    try {
      final userId = _auth.currentUser!.uid;
      final pawnbrokerUid = bid['pawnbrokerUid'];

      // Create chat document
      final chatRef = await _firestore.collection('chats').add({
        'participants': [userId, pawnbrokerUid],
        'participantInfo': {
          userId: {
            'type': 'user',
            'lastSeen': FieldValue.serverTimestamp(),
          },
          pawnbrokerUid: {
            'type': 'pawnbroker',
            'lastSeen': FieldValue.serverTimestamp(),
          },
        },
        'loanRequestId': loanRequestId.value,
        'bidId': bid['id'],
        'lastMessage': null,
        'lastMessageTime': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Add welcome message
      await _firestore.collection('chats/${chatRef.id}/messages').add({
        'text': 'chat_welcome_message'.tr,
        'senderId': 'system',
        'senderType': 'system',
        'timestamp': FieldValue.serverTimestamp(),
        'read': false,
      });

      return chatRef.id;
    } catch (e) {
      print('Error creating chat room: $e');
      rethrow;
    }
  }
}
