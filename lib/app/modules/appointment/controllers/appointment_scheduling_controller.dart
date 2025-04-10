import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:bidmygoldflutter/app/data/services/notification_service.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart';

class AppointmentSchedulingController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final NotificationService _notificationService =
      Get.find<NotificationService>();

  // Form fields
  var selectedDate = Rxn<DateTime>();
  var selectedTime = RxString('');
  final notesController = TextEditingController();

  // Error fields
  var dateError = RxString('');
  var timeError = RxString('');

  // Loading states
  var isLoading = true.obs;
  var isSubmitting = false.obs;

  // Data fields
  var loanRequestId = ''.obs;
  var bidId = ''.obs;
  var loanAmount = 0.obs;
  var jewelType = ''.obs;
  var userName = ''.obs;
  var shopName = ''.obs;
  var shopAddress = ''.obs;
  var userId = ''.obs;
  var pawnbrokerId = ''.obs;
  var isPawnbroker = false.obs;
  var availableTimeSlots = <String>[
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '12:00 PM',
    '12:30 PM',
    '1:00 PM',
    '1:30 PM',
    '2:00 PM',
    '2:30 PM',
    '3:00 PM',
    '3:30 PM',
    '4:00 PM',
    '4:30 PM',
    '5:00 PM'
  ].obs;

  // Computed properties
  RxBool get isFormValid =>
      ((selectedDate.value != null) && selectedTime.value.isNotEmpty).obs;

  String get formattedLoanAmount {
    final formatter = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
      locale: 'en_IN',
    );
    return formatter.format(loanAmount.value);
  }

  @override
  void onInit() {
    super.onInit();

    // Get the current user ID
    final currentUserId = _auth.currentUser?.uid;
    if (currentUserId == null) {
      Get.back();
      return;
    }

    // Get arguments from navigation
    final args = Get.arguments as Map<String, dynamic>;
    loanRequestId.value = args['loanRequestId'] ?? '';
    bidId.value = args['bidId'] ?? '';

    // Determine user type
    _checkUserType(currentUserId).then((_) {
      fetchAppointmentData();
    });
  }

  Future<void> _checkUserType(String currentUserId) async {
    // Check if the user is a pawnbroker
    final pawnbrokerDoc =
        await _firestore.collection('pawnbrokers').doc(currentUserId).get();
    isPawnbroker.value = pawnbrokerDoc.exists;

    if (isPawnbroker.value) {
      pawnbrokerId.value = currentUserId;
    } else {
      userId.value = currentUserId;
    }
  }

  Future<void> fetchAppointmentData() async {
    try {
      isLoading.value = true;

      // Fetch loan request data
      final loanRequestDoc = await _firestore
          .collection('loanRequests')
          .doc(loanRequestId.value)
          .get();
      if (!loanRequestDoc.exists) {
        Get.back();
        Get.snackbar('Error', 'Loan request not found');
        return;
      }

      final loanRequestData = loanRequestDoc.data()!;
      loanAmount.value = loanRequestData['requestedAmount'] ?? 0;
      jewelType.value = loanRequestData['jewelType'] ?? 'Unknown';

      // Set user ID if not already set
      if (userId.value.isEmpty) {
        userId.value = loanRequestData['userId'] ?? '';
      }

      // Fetch bid data if bid ID is provided
      if (bidId.value.isNotEmpty) {
        final bidDoc =
            await _firestore.collection('bids').doc(bidId.value).get();
        if (bidDoc.exists) {
          final bidData = bidDoc.data()!;

          // Update loan amount from bid if available
          if (bidData['offeredAmount'] != null) {
            loanAmount.value = bidData['offeredAmount'];
          }

          // Set pawnbroker ID if not already set
          if (pawnbrokerId.value.isEmpty) {
            pawnbrokerId.value = bidData['pawnbrokerUid'] ?? '';
          }
        }
      }

      // Fetch user data
      if (userId.value.isNotEmpty) {
        final userDoc =
            await _firestore.collection('users').doc(userId.value).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          userName.value = userData['name'] ?? 'Unknown User';
        }
      }

      // Fetch pawnbroker data
      if (pawnbrokerId.value.isNotEmpty) {
        final pawnbrokerDoc = await _firestore
            .collection('pawnbrokers')
            .doc(pawnbrokerId.value)
            .get();
        if (pawnbrokerDoc.exists) {
          final pawnbrokerData = pawnbrokerDoc.data()!;
          shopName.value = pawnbrokerData['shopName'] ?? 'Unknown Shop';
          shopAddress.value = pawnbrokerData['address'] ?? '';
        }
      }

      // Set default date to tomorrow
      final tomorrow = DateTime.now().add(const Duration(days: 1));
      selectedDate.value =
          DateTime(tomorrow.year, tomorrow.month, tomorrow.day);
    } catch (e) {
      print('Error fetching appointment data: $e');
      Get.snackbar('Error', 'Failed to load appointment data');
    } finally {
      isLoading.value = false;
    }
  }

  void selectDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate =
        selectedDate.value ?? DateTime.now().add(const Duration(days: 1));

    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
    );

    if (pickedDate != null) {
      selectedDate.value = pickedDate;
      dateError.value = '';
    }
  }

  Future<void> scheduleAppointment() async {
    if (!validateForm()) {
      return;
    }

    try {
      isSubmitting.value = true;

      // Format date and time
      final appointmentDate = selectedDate.value!;
      final appointmentTime = selectedTime.value;

      // Parse time to create a complete DateTime
      final timeParts = appointmentTime.split(' ');
      final hourMinute = timeParts[0].split(':');
      final isPM = timeParts[1] == 'PM';

      int hour = int.parse(hourMinute[0]);
      final minute = int.parse(hourMinute[1]);

      // Convert 12-hour to 24-hour format
      if (isPM && hour < 12) {
        hour += 12;
      } else if (!isPM && hour == 12) {
        hour = 0;
      }

      final appointmentDateTime = DateTime(
        appointmentDate.year,
        appointmentDate.month,
        appointmentDate.day,
        hour,
        minute,
      );

      // Create appointment document
      final appointmentData = {
        'loanRequestId': loanRequestId.value,
        'bidId': bidId.value,
        'userId': userId.value,
        'pawnbrokerId': pawnbrokerId.value,
        'appointmentDateTime': appointmentDateTime,
        'notes': notesController.text.trim(),
        'status': 'pending', // pending, confirmed, completed, cancelled
        'createdAt': FieldValue.serverTimestamp(),
        'createdBy': _auth.currentUser?.uid,
      };

      // Save to Firestore
      final appointmentRef =
          await _firestore.collection('appointments').add(appointmentData);

      // Update bid status
      if (bidId.value.isNotEmpty) {
        await _firestore.collection('bids').doc(bidId.value).update({
          'status': 'accepted',
          'appointmentId': appointmentRef.id,
        });
      }

      // Send notification to other party
      _sendAppointmentNotification(appointmentRef.id);

      // Navigate to appointment details
      Get.offNamed(
        Routes.APPOINTMENT_DETAILS,
        arguments: {'appointmentId': appointmentRef.id},
      );

      Get.snackbar(
        'Success',
        'Appointment scheduled successfully',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error scheduling appointment: $e');
      Get.snackbar('Error', 'Failed to schedule appointment');
    } finally {
      isSubmitting.value = false;
    }
  }

  bool validateForm() {
    bool isValid = true;

    // Validate date
    if (selectedDate.value == null) {
      dateError.value = 'Please select a date';
      isValid = false;
    } else {
      dateError.value = '';
    }

    // Validate time
    if (selectedTime.value.isEmpty) {
      timeError.value = 'Please select a time';
      isValid = false;
    } else {
      timeError.value = '';
    }

    return isValid;
  }

  void _sendAppointmentNotification(String appointmentId) {
    final receiverId = isPawnbroker.value ? userId.value : pawnbrokerId.value;

    if (receiverId.isNotEmpty) {
      final appointmentDateStr =
          DateFormat('yyyy-MM-dd').format(selectedDate.value!);
      final message = 'appointment_confirmed_message'.trParams({
        'date': appointmentDateStr,
        'time': selectedTime.value,
      });

      _notificationService.sendNotification(
        userId: receiverId,
        title: 'Appointment Scheduled',
        body: message,
        data: {
          'type': 'appointment',
          'appointment_id': appointmentId,
        },
      );
    }
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }
}
