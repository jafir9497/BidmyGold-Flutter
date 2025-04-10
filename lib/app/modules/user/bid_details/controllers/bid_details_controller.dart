import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:bidmygoldflutter/app/data/models/bid.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart';
import 'package:bidmygoldflutter/app/data/services/notification_service.dart';

class BidDetailsController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = Get.find<NotificationService>();

  // Observables
  final isLoading = true.obs;
  final isAccepting = false.obs;
  final bidData = Rx<Bid?>(null);
  final loanRequestData = <String, dynamic>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadBidDetails();
  }

  Future<void> _loadBidDetails() async {
    try {
      isLoading.value = true;

      // Get arguments passed to this screen
      final arguments = Get.arguments as Map<String, dynamic>?;
      if (arguments == null) {
        Get.back();
        return;
      }

      // Convert bid data to Bid model
      final Map<String, dynamic> bidMap = arguments['bid'] ?? {};
      bidData.value = Bid.fromMap(bidMap);
      loanRequestData.value = arguments['loanRequest'] ?? {};

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'Error',
        'Failed to load bid details: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> acceptBid() async {
    try {
      isAccepting.value = true;

      // Ensure we have necessary data
      final bid = bidData.value;
      if (bid?.id == null) {
        throw Exception('Missing bid ID');
      }

      final loanRequestId = loanRequestData['id'];
      if (loanRequestId == null) {
        throw Exception('Missing loan request ID');
      }

      // Show confirmation dialog
      final confirmed = await _showConfirmationDialog();
      if (confirmed != true) {
        isAccepting.value = false;
        return;
      }

      // Update bid status
      await _firestore.collection('bids').doc(bid!.id).update({
        'status': 'accepted',
        'acceptedAt': FieldValue.serverTimestamp(),
      });

      // Create appointment
      final appointmentId = await _createAppointment();

      // Create chat room
      final chatRoomId = await _createChatRoom();

      // Update loan request status
      await _firestore.collection('loanRequests').doc(loanRequestId).update({
        'status': 'accepted',
        'acceptedBidId': bid.id,
        'appointmentId': appointmentId,
        'chatRoomId': chatRoomId,
      });

      // Send notification to pawnbroker
      await _notificationService.sendBidAcceptedNotification(bid.id!);

      Get.offNamed(Routes.APPOINTMENT_DETAILS, arguments: {
        'appointmentId': appointmentId,
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to accept bid: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isAccepting.value = false;
    }
  }

  Future<void> rejectBid() async {
    try {
      final bid = bidData.value;
      if (bid?.id == null) {
        throw Exception('Missing bid ID');
      }

      // Update bid status
      await _firestore.collection('bids').doc(bid!.id).update({
        'status': 'rejected',
        'rejectedAt': FieldValue.serverTimestamp(),
      });

      // Send notification to pawnbroker
      await _notificationService.sendBidRejectedNotification(bid.id!);

      Get.back();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to reject bid: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<bool?> _showConfirmationDialog() {
    final bid = bidData.value;
    if (bid == null) return Future.value(false);

    return Get.dialog<bool>(
      AlertDialog(
        title: Text('confirm_accept_bid'.tr),
        content: Text(
          'confirm_accept_bid_message'.trParams({
            'shopName': bid.name ?? 'Unknown Shop',
            'amount': bid.loanAmount?.toStringAsFixed(2) ?? '0.00',
          }),
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text('cancel'.tr),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            child: Text('confirm'.tr),
          ),
        ],
      ),
    );
  }

  Future<String> _createAppointment() async {
    try {
      final bid = bidData.value;
      if (bid == null) throw Exception('Missing bid data');

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Default appointment date (tomorrow at 12:00 PM)
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      final defaultAppointmentDate = DateTime(
        tomorrow.year,
        tomorrow.month,
        tomorrow.day,
        12, // 12:00 PM
      );

      // Create appointment document
      final appointmentRef = await _firestore.collection('appointments').add({
        'userId': userId,
        'pawnbrokerUid': bid.pawnbrokerUid,
        'bidId': bid.id,
        'loanRequestId': loanRequestData['id'],
        'scheduledAt': defaultAppointmentDate.toIso8601String(),
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return appointmentRef.id;
    } catch (e) {
      rethrow;
    }
  }

  Future<String> _createChatRoom() async {
    try {
      final bid = bidData.value;
      if (bid == null) throw Exception('Missing bid data');

      final userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception('User not authenticated');

      // Create chat document
      final chatRef = await _firestore.collection('chats').add({
        'participants': [userId, bid.pawnbrokerUid],
        'bidId': bid.id,
        'loanRequestId': loanRequestData['id'],
        'lastMessage': null,
        'lastMessageTime': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return chatRef.id;
    } catch (e) {
      rethrow;
    }
  }
}
