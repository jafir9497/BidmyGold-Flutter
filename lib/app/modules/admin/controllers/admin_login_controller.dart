import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../utils/admin_auth_service.dart';

class AdminLoginController extends GetxController {
  // Services
  final AdminAuthService _authService = Get.find<AdminAuthService>();
  final _storage = GetStorage();

  // Form controllers
  late TextEditingController emailController;
  late TextEditingController passwordController;

  // Observables
  var isLoading = false.obs;
  var errorMessage = ''.obs;
  var rememberMe = false.obs;
  var obscurePassword = true.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();

    // Check if there are saved credentials
    checkSavedCredentials();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Check for saved email in local storage
  void checkSavedCredentials() {
    final savedEmail = _storage.read<String>('admin_email');
    if (savedEmail != null && savedEmail.isNotEmpty) {
      emailController.text = savedEmail;
      rememberMe.value = true;
    }
  }

  // Toggle password visibility
  void togglePasswordVisibility() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Toggle remember me checkbox
  void toggleRememberMe() {
    rememberMe.value = !rememberMe.value;
  }

  // Validate form inputs
  bool validateInputs() {
    if (emailController.text.isEmpty) {
      errorMessage.value = 'Please enter your email address';
      return false;
    }

    if (!GetUtils.isEmail(emailController.text)) {
      errorMessage.value = 'Please enter a valid email address';
      return false;
    }

    if (passwordController.text.isEmpty) {
      errorMessage.value = 'Please enter your password';
      return false;
    }

    return true;
  }

  // Login function
  Future<void> login() async {
    // Clear any previous error message
    errorMessage.value = '';

    // Validate inputs
    if (!validateInputs()) {
      return;
    }

    try {
      isLoading.value = true;

      final success = await _authService.signInWithEmailAndPassword(
          emailController.text.trim(), passwordController.text);

      if (success) {
        // Save email if remember me is checked
        if (rememberMe.value) {
          await _storage.write('admin_email', emailController.text.trim());
        } else {
          await _storage.remove('admin_email');
        }

        // Navigate to admin dashboard
        Get.offAllNamed('/admin-dashboard');
      } else {
        errorMessage.value = 'Invalid credentials or account is inactive';
      }
    } catch (e) {
      print('Login error: $e');
      errorMessage.value = 'Failed to sign in. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  // Reset password function
  void resetPassword() {
    if (emailController.text.isEmpty ||
        !GetUtils.isEmail(emailController.text)) {
      errorMessage.value = 'Please enter a valid email address';
      return;
    }

    Get.dialog(
      AlertDialog(
        title: const Text('Reset Password'),
        content: Text(
            'Send password reset instructions to ${emailController.text}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Get.back();
              try {
                isLoading.value = true;
                await FirebaseAuth.instance
                    .sendPasswordResetEmail(email: emailController.text.trim());
                Get.snackbar(
                  'Password Reset',
                  'Password reset instructions have been sent to your email',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } catch (e) {
                print('Password reset error: $e');
                Get.snackbar(
                  'Error',
                  'Failed to send password reset email. Please try again.',
                  snackPosition: SnackPosition.BOTTOM,
                );
              } finally {
                isLoading.value = false;
              }
            },
            child: const Text('Send'),
          ),
        ],
      ),
    );
  }
}
