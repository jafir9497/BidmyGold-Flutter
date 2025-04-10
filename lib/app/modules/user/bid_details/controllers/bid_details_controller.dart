import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../../routes/app_pages.dart';
import '../../../../data/services/notification_service.dart';

class BidDetailsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Observables
  var isLoading = true.obs;
  var isAccepting = false.obs;
  var bidData = <String, dynamic>{}.obs;
  var loanRequestData = <String, dynamic>{}.obs;
  var pawnbrokerData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    loadBidDetails();
  }

  void loadBidDetails() {
    try {
      isLoading.value = true;

      // Get data from arguments
      final arguments = Get.arguments;
      if (arguments == null) {
        Get.back();
        return;
      }

      bidData.value = arguments['bid'] ?? {};
      loanRequestData.value = arguments['loanRequest'] ?? {};
      pawnbrokerData.value = arguments['pawnbroker'] ?? {};

      isLoading.value = false;
    } catch (e) {
      print('Error loading bid details: $e');
      Get.snackbar(
        'error'.tr,
        'failed_to_load_bid_details'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      isLoading.value = false;
    }
  }

  // Calculate monthly payment using PMT formula
  double calculateMonthlyPayment(
      double principal, double monthlyRate, int tenure) {
    if (monthlyRate == 0) {
      return principal / tenure;
    }

    final numerator = principal * monthlyRate * pow(1 + monthlyRate, tenure);
    final denominator = pow(1 + monthlyRate, tenure) - 1;

    return numerator / denominator;
  }

  // Helper for math.pow function
  double pow(double x, int y) {
    double result = 1.0;
    for (int i = 0; i < y; i++) {
      result *= x;
    }
    return result;
  }

  Future<void> acceptBid() async {
    try {
      // Show confirmation dialog
      final confirmed = await _showConfirmationDialog();
      if (confirmed != true) return;

      isAccepting.value = true;

      // Ensure we have necessary data
      final bidId = bidData['id'];
      if (bidId == null) {
        throw Exception('Missing bid ID');
      }

      final loanRequestId = loanRequestData['id'];
      if (loanRequestId == null) {
        throw Exception('Missing loan request ID');
      }

      final pawnbrokerUid = bidData['pawnbrokerUid'];
      if (pawnbrokerUid == null) {
        throw Exception('Missing pawnbroker UID');
      }

      // Get current user ID
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Update bid status to accepted
      await _firestore.collection('bids').doc(bidId).update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Update loan request status to bid accepted
      await _firestore.collection('loanRequests').doc(loanRequestId).update({
        'status': 'bid_accepted',
        'acceptedBidId': bidId,
        'acceptedPawnbrokerId': pawnbrokerUid,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Reject all other bids for this loan request
      final otherBidsQuery = await _firestore
          .collection('bids')
          .where('loanRequestId', isEqualTo: loanRequestId)
          .where(FieldPath.documentId, isNotEqualTo: bidId)
          .get();

      final batch = _firestore.batch();
      for (final doc in otherBidsQuery.docs) {
        batch.update(doc.reference, {
          'status': 'rejected',
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      await batch.commit();

      // Create appointment for the accepted bid
      final appointmentId = await _createAppointment();

      // Create a chat room between user and pawnbroker
      final chatId = await _createChatRoom();

      // Send notification to the pawnbroker (this would trigger a Cloud Function)
      await _firestore.collection('notifications').add({
        'userId': pawnbrokerUid,
        'title': 'bid_accepted_title'.tr,
        'body': 'bid_accepted_body'.tr,
        'data': {
          'type': 'bid_accepted',
          'loan_request_id': loanRequestId,
          'bid_id': bidId,
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
      Get.offAllNamed(Routes.APPOINTMENT_DETAILS, arguments: {
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

  Future<bool?> _showConfirmationDialog() {
    final shopName = pawnbrokerData['shopName'] ?? 'Unknown Shop';
    final offeredAmount = bidData['offeredAmount'] ?? 0.0;

    return Get.dialog<bool>(
      AlertDialog(
        title: Text('confirm_accept_bid'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('accept_bid_confirmation'.trParams({
              'shopName': shopName,
              'amount': offeredAmount.toString(),
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
            child: Text('confirm'.tr),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
            ),
          ),
        ],
      ),
    );
  }

  Future<String> _createAppointment() async {
    try {
      final userId = _auth.currentUser!.uid;
      final pawnbrokerUid = bidData['pawnbrokerUid'];
      final loanRequestId = loanRequestData['id'];
      final bidId = bidData['id'];

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
        'loanRequestId': loanRequestId,
        'bidId': bidId,
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

  Future<String> _createChatRoom() async {
    try {
      final userId = _auth.currentUser!.uid;
      final pawnbrokerUid = bidData['pawnbrokerUid'];
      final loanRequestId = loanRequestData['id'];
      final bidId = bidData['id'];

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
        'loanRequestId': loanRequestId,
        'bidId': bidId,
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
