import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:bidmygoldflutter/app/data/services/notification_service.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart';
import '../../../data/models/review_model.dart'; // Import ReviewModel

class AppointmentDetailsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Loading state
  var isLoading = true.obs;
  var isSubmittingReview = false.obs; // For review submission loading state

  // Appointment data
  var appointmentId = ''.obs;
  var appointmentStatus = RxString('pending');
  var appointmentNotes = '';
  DateTime? appointmentDateTime;

  // Related data
  var loanRequestId = ''.obs;
  var bidId = ''.obs;
  var loanAmount = 0.obs;
  var jewelType = RxString('');
  var userName = RxString('');
  var shopName = RxString('');
  var shopAddress = RxString('');
  var userId = ''.obs;
  var pawnbrokerId = ''.obs;
  var isPawnbroker = false.obs;
  var hasUserReviewed = false.obs; // Track if user already submitted a review

  // Review State
  final RxInt selectedRating = 0.obs; // Use RxInt for reactivity
  final reviewTextController = TextEditingController();

  // Computed properties
  String get formattedLoanAmount {
    return NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
      locale: 'en_IN',
    ).format(loanAmount.value);
  }

  @override
  void onInit() {
    super.onInit();

    // Get appointment ID from arguments
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      appointmentId.value = args['appointmentId'] ?? '';
    }

    // Get current user ID
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      Get.back();
      return;
    }

    // Check if user is pawnbroker
    _checkUserType(currentUserId).then((_) {
      fetchAppointmentDetails();
    });
  }

  @override
  void onClose() {
    reviewTextController.dispose(); // Dispose the text controller
    super.onClose();
  }

  Future<void> _checkUserType(String currentUserId) async {
    // Check if current user is the pawnbroker for this appointment
    // We need pawnbrokerId before calling this, fetchAppointmentDetails sets it
    // This logic might need adjustment based on when pawnbrokerId is available.
    // For now, assume fetchAppointmentDetails is called first.
    if (pawnbrokerId.value.isNotEmpty) {
      // Ensure pawnbrokerId is loaded
      isPawnbroker.value = (currentUserId == pawnbrokerId.value);
    } else {
      // If pawnbrokerId isn't ready, check the DB (less efficient)
      final pawnbrokerDoc =
          await _firestore.collection('pawnbrokers').doc(currentUserId).get();
      isPawnbroker.value = pawnbrokerDoc.exists;
    }
  }

  Future<void> fetchAppointmentDetails() async {
    try {
      isLoading.value = true;
      hasUserReviewed.value = false; // Reset review status

      // Fetch appointment data
      final appointmentDoc = await _firestore
          .collection('appointments')
          .doc(appointmentId.value)
          .get();

      if (!appointmentDoc.exists) {
        Get.back();
        Get.snackbar('Error', 'Appointment not found');
        return;
      }

      final appointmentData = appointmentDoc.data()!;

      // Set appointment fields
      appointmentStatus.value = appointmentData['status'] ?? 'pending';
      appointmentNotes = appointmentData['notes'] ?? '';

      // Convert timestamp to DateTime
      if (appointmentData['appointmentDateTime'] != null) {
        if (appointmentData['appointmentDateTime'] is Timestamp) {
          appointmentDateTime =
              (appointmentData['appointmentDateTime'] as Timestamp).toDate();
        }
      }

      // Set IDs
      loanRequestId.value = appointmentData['loanRequestId'] ?? '';
      bidId.value = appointmentData['bidId'] ?? '';
      userId.value = appointmentData['userId'] ?? '';
      pawnbrokerId.value = appointmentData['pawnbrokerId'] ?? '';

      // Fetch loan request data
      if (loanRequestId.value.isNotEmpty) {
        await fetchLoanRequestData();
      }

      // Fetch bid data
      if (bidId.value.isNotEmpty) {
        await fetchBidData();
      }

      // Fetch user and pawnbroker data
      await Future.wait([
        fetchUserData(),
        fetchPawnbrokerData(),
      ]);

      // Check if the current user (if not the pawnbroker) has already reviewed
      if (!isPawnbroker.value && appointmentStatus.value == 'completed') {
        await _checkIfUserReviewed();
      }
    } catch (e) {
      print('Error fetching appointment details: $e');
      Get.snackbar('Error', 'Failed to load appointment details');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchLoanRequestData() async {
    try {
      final loanRequestDoc = await _firestore
          .collection('loanRequests')
          .doc(loanRequestId.value)
          .get();

      if (loanRequestDoc.exists) {
        final loanRequestData = loanRequestDoc.data()!;
        jewelType.value = loanRequestData['jewelType'] ?? 'Unknown';

        // Set loan amount if not set by bid
        if (loanAmount.value == 0) {
          loanAmount.value = loanRequestData['requestedAmount'] ?? 0;
        }
      }
    } catch (e) {
      print('Error fetching loan request data: $e');
    }
  }

  Future<void> fetchBidData() async {
    try {
      final bidDoc = await _firestore.collection('bids').doc(bidId.value).get();

      if (bidDoc.exists) {
        final bidData = bidDoc.data()!;
        // Override loan amount with offered amount
        if (bidData['offeredAmount'] != null) {
          loanAmount.value = bidData['offeredAmount'];
        }
      }
    } catch (e) {
      print('Error fetching bid data: $e');
    }
  }

  Future<void> fetchUserData() async {
    if (userId.value.isEmpty) return;

    try {
      final userDoc =
          await _firestore.collection('users').doc(userId.value).get();

      if (userDoc.exists) {
        final userData = userDoc.data()!;
        userName.value = userData['name'] ?? 'Unknown User';
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> fetchPawnbrokerData() async {
    if (pawnbrokerId.value.isEmpty) return;

    try {
      final pawnbrokerDoc = await _firestore
          .collection('pawnbrokers')
          .doc(pawnbrokerId.value)
          .get();

      if (pawnbrokerDoc.exists) {
        final pawnbrokerData = pawnbrokerDoc.data()!;
        shopName.value = pawnbrokerData['shopName'] ?? 'Unknown Shop';
        shopAddress.value = pawnbrokerData['address'] ?? '';
      }
    } catch (e) {
      print('Error fetching pawnbroker data: $e');
    }
  }

  Future<void> _checkIfUserReviewed() async {
    if (userId.value.isEmpty || pawnbrokerId.value.isEmpty) return;

    try {
      final reviewQuery = await _firestore
          .collection('reviews')
          .where('userId', isEqualTo: userId.value)
          .where('pawnbrokerId', isEqualTo: pawnbrokerId.value)
          // Optionally filter by appointmentId if reviews are linked to appointments
          // .where('appointmentId', isEqualTo: appointmentId.value)
          .limit(1)
          .get();

      hasUserReviewed.value = reviewQuery.docs.isNotEmpty;
      print('User has reviewed this pawnbroker: ${hasUserReviewed.value}');
    } catch (e) {
      print('Error checking existing review: $e');
      // Assume not reviewed if check fails, or handle error differently
    }
  }

  void updateRating(int rating) {
    selectedRating.value = rating;
  }

  Future<void> submitReview() async {
    if (selectedRating.value <= 0) {
      Get.snackbar('Error', 'Please select a star rating (1-5).');
      return;
    }
    if (isSubmittingReview.value) return;

    final currentUser = _auth.currentUser;
    if (currentUser == null || isPawnbroker.value) {
      Get.snackbar('Error', 'Only the customer can submit a review.');
      return;
    }

    isSubmittingReview.value = true;

    try {
      // Create the review data
      final reviewData = {
        'pawnbrokerId': pawnbrokerId.value,
        'userId': userId.value,
        'userName': userName.value, // Denormalized user name
        'userProfilePicUrl':
            null, // TODO: Add user profile pic URL if available
        'rating': selectedRating.value,
        'reviewText': reviewTextController.text.trim(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending', // Start as pending for moderation
        'appointmentId':
            appointmentId.value, // Optional: link review to appointment
      };

      // Add to Firestore
      await _firestore.collection('reviews').add(reviewData);

      // Trigger Cloud Function (implicitly by adding doc)
      // The Cloud Function will update the pawnbroker's averageRating and ratingCount.

      hasUserReviewed.value = true; // Prevent submitting again
      Get.snackbar('Success', 'Review submitted successfully! Thank you.');

      // Optionally clear fields after submission
      // selectedRating.value = 0;
      // reviewTextController.clear();
    } catch (e) {
      print('Error submitting review: $e');
      Get.snackbar('Error', 'Failed to submit review. Please try again.');
    } finally {
      isSubmittingReview.value = false;
    }
  }

  Future<void> confirmAppointment() async {
    try {
      // Can only confirm if pending
      if (appointmentStatus.value != 'pending') {
        Get.snackbar('Error', 'Cannot confirm this appointment');
        return;
      }

      // Update appointment status
      await _firestore
          .collection('appointments')
          .doc(appointmentId.value)
          .update({
        'status': 'confirmed',
        'confirmedAt': FieldValue.serverTimestamp(),
        'confirmedBy': _auth.currentUser?.uid,
      });

      // Update local status
      appointmentStatus.value = 'confirmed';

      // Send notification to other party
      _sendStatusChangeNotification('confirmed');

      Get.snackbar(
        'Success',
        'Appointment confirmed',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error confirming appointment: $e');
      Get.snackbar('Error', 'Failed to confirm appointment');
    }
  }

  Future<void> cancelAppointment() async {
    try {
      // Can cancel if pending or confirmed
      if (appointmentStatus.value != 'pending' &&
          appointmentStatus.value != 'confirmed') {
        Get.snackbar('Error', 'Cannot cancel this appointment');
        return;
      }

      // Get confirmation
      final result = await Get.dialog<bool>(
        AlertDialog(
          title: Text('cancel_appointment'.tr),
          content: Text('cancel_appointment_confirmation'.tr),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: Text('no'.tr),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: Text('yes'.tr),
            ),
          ],
        ),
      );

      if (result != true) return;

      // Update appointment status
      await _firestore
          .collection('appointments')
          .doc(appointmentId.value)
          .update({
        'status': 'cancelled',
        'cancelledAt': FieldValue.serverTimestamp(),
        'cancelledBy': _auth.currentUser?.uid,
      });

      // Update local status
      appointmentStatus.value = 'cancelled';

      // Send notification to other party
      _sendStatusChangeNotification('cancelled');

      Get.snackbar(
        'Success',
        'Appointment cancelled',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      print('Error cancelling appointment: $e');
      Get.snackbar('Error', 'Failed to cancel appointment');
    }
  }

  void rescheduleAppointment() {
    // Navigate to appointment scheduling screen with pre-filled data
    Get.toNamed(
      Routes.APPOINTMENT_SCHEDULING,
      arguments: {
        'loanRequestId': loanRequestId.value,
        'bidId': bidId.value,
        'originalAppointmentId': appointmentId.value,
      },
    )?.then((result) {
      if (result == true) {
        // Refresh on return
        fetchAppointmentDetails();
      }
    });
  }

  void startChat() {
    // Navigate to chat screen
    final otherPartyId = isPawnbroker.value ? userId.value : pawnbrokerId.value;

    Get.toNamed(
      Routes.CHAT,
      arguments: {
        'otherUserId': otherPartyId,
        'appointmentId': appointmentId.value,
      },
    );
  }

  void _sendStatusChangeNotification(String status) {
    // Determine receiver
    final currentUserId = _auth.currentUser?.uid;
    final receiverId =
        currentUserId == userId.value ? pawnbrokerId.value : userId.value;

    if (receiverId.isEmpty) return;

    // Format date for notification
    final dateStr = appointmentDateTime != null
        ? DateFormat('MMM d, yyyy').format(appointmentDateTime!)
        : '';

    final timeStr = appointmentDateTime != null
        ? DateFormat('h:mm a').format(appointmentDateTime!)
        : '';

    // Create notification message
    String title, body;

    switch (status) {
      case 'confirmed':
        title = 'Appointment Confirmed';
        body = 'Your appointment on $dateStr at $timeStr has been confirmed.';
        break;
      case 'cancelled':
        title = 'Appointment Cancelled';
        body = 'Your appointment on $dateStr at $timeStr has been cancelled.';
        break;
      default:
        title = 'Appointment Update';
        body = 'Your appointment status has been updated.';
    }

    // Send notification via FCM
    _firestore.collection('notifications').add({
      'userId': receiverId,
      'title': title,
      'body': body,
      'data': {
        'type': 'appointment',
        'appointment_id': appointmentId.value,
      },
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
