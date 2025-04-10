import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart';
// TODO: Import Firestore service later for saving data
import 'package:firebase_auth/firebase_auth.dart'; // To get current user UID
import 'package:get_storage/get_storage.dart'; // To save completion flag

class UserDetailsController extends GetxController {
  final _auth = FirebaseAuth.instance;
  final _getStorage = GetStorage();

  final formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final emailController = TextEditingController();

  var isLoading = false.obs;

  @override
  void onClose() {
    nameController.dispose();
    emailController.dispose();
    super.onClose();
  }

  String? validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'name_required'.tr;
    }
    return null;
  }

  String? validateEmail(String? value) {
    // Email is optional, but if entered, it must be valid
    if (value != null && value.isNotEmpty && !GetUtils.isEmail(value)) {
      return 'invalid_email'.tr;
    }
    return null;
  }

  Future<void> saveUserDetails() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        Get.snackbar('Error', 'User not logged in!'); // Should not happen
        isLoading.value = false;
        return;
      }

      final name = nameController.text.trim();
      final email = emailController.text.trim();

      print('Saving User Details for $userId: Name=$name, Email=$email');

      // --- TODO: Save to Firestore --- (Requires firestore package)
      // Example structure:
      // try {
      //   await FirebaseFirestore.instance.collection('users').doc(userId).set({
      //     'name': name,
      //     'email': email.isNotEmpty ? email : null, // Store null if empty
      //     'mobileNumber': _auth.currentUser?.phoneNumber, // Store phone number
      //     'profileComplete': true, // Flag that basic details are saved
      //     'kycStatus': 'pending', // Initial KYC status
      //     'createdAt': FieldValue.serverTimestamp(),
      //   }, SetOptions(merge: true)); // Merge to avoid overwriting other fields
      // } catch (e) {
      //   isLoading.value = false;
      //   Get.snackbar('Error', 'Database Error: Failed to save details: $e');
      //   return; // Stop if DB save fails
      // }
      // -----------------------------

      // Simulate network delay (REMOVE WHEN FIRESTORE IS ADDED)
      await Future.delayed(const Duration(seconds: 1));

      try {
        // Mark user details as complete in local storage
        // This flag helps decide if we need to show this screen again next login
        _getStorage.write('user_details_complete_$userId', true);

        isLoading.value = false;
        Get.snackbar('Success', 'Details saved!');

        // Navigate to the KYC Upload screen
        Get.offNamed(Routes.KYC_UPLOAD);
      } catch (e) {
        // This catch is mainly for the GetStorage write, less likely to fail
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to update status: $e');
      }
    }
  }
}
