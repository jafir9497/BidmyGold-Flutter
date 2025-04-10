import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FeedbackController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final feedbackTextController = TextEditingController();
  final RxBool isSubmitting = false.obs;

  User? get currentUser => _auth.currentUser;

  @override
  void onClose() {
    feedbackTextController.dispose();
    super.onClose();
  }

  Future<void> submitFeedback() async {
    if (feedbackTextController.text.trim().isEmpty) {
      Get.snackbar('Error', 'Please enter your feedback before submitting.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }
    if (currentUser == null) {
      Get.snackbar('Error', 'You must be logged in to submit feedback.',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isSubmitting.value = true;

    try {
      await _firestore.collection('feedback').add({
        'userId': currentUser!.uid,
        'userPhone': currentUser!.phoneNumber ?? 'N/A',
        'userEmail': currentUser!.email ?? 'N/A',
        'feedbackText': feedbackTextController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'new', // Default status
      });

      feedbackTextController.clear(); // Clear field on success
      Get.back(); // Go back to previous screen
      Get.snackbar(
        'Feedback Sent',
        'Thank you for your feedback!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      print('Error submitting feedback: $e');
      Get.snackbar(
          'Error', 'Could not submit feedback. Please try again later.',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isSubmitting.value = false;
    }
  }
}
