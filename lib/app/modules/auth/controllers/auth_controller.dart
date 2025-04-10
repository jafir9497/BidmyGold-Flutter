import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _getStorage = GetStorage();

  // Observables for UI state
  var isLoading = false.obs;
  var isOtpSent = false.obs;
  var mobileNumber = ''.obs;
  var otp = ''.obs;
  var verificationId = ''.obs;
  var resendToken = Rxn<int>(); // For OTP resend functionality
  var countdown = 0.obs; // For OTP resend timer
  Timer? _timer;

  // Text editing controllers
  late TextEditingController mobileController;
  late TextEditingController otpController;

  // Firebase User Stream
  Rx<User?> firebaseUser = Rx<User?>(null);

  @override
  void onInit() {
    super.onInit();
    mobileController = TextEditingController();
    otpController = TextEditingController();
    firebaseUser.bindStream(_auth.authStateChanges());

    // Auto navigate based on auth state
    ever(firebaseUser, _handleAuthStateChanged);
  }

  // Renamed from _setInitialScreen to avoid confusion with SplashController
  void _handleAuthStateChanged(User? user) async {
    // This listener should only react *after* the initial splash/onboarding flow
    // by navigating between the main logged-out and logged-in states.
    final currentRoute = Get.currentRoute;

    // Avoid navigation loops if already on the correct screen or during initial setup
    if (currentRoute == Routes.SPLASH ||
        currentRoute == Routes.LANGUAGE_SELECTION ||
        currentRoute == Routes.ONBOARDING) {
      return;
    }

    if (user != null) {
      // User is logged in
      final userId = user.uid;

      // Check if the user is a pawnbroker
      try {
        final pawnbrokerDoc = await FirebaseFirestore.instance
            .collection('pawnbrokers')
            .doc(userId)
            .get();

        final isPawnbroker = pawnbrokerDoc.exists;

        if (isPawnbroker) {
          // User is a pawnbroker, navigate to pawnbroker dashboard
          if (currentRoute != Routes.PAWNBROKER_DASHBOARD) {
            print(
                'Auth Listener: Pawnbroker logged in, navigating to PAWNBROKER_DASHBOARD');
            Get.offAllNamed(Routes.PAWNBROKER_DASHBOARD);
          }
          return; // Exit early, no need to check regular user flow
        }
      } catch (e) {
        print('Error checking pawnbroker status: $e');
        // Continue with regular user flow
      }

      // Regular user flow
      final detailsComplete =
          _getStorage.read<bool>('user_details_complete_$userId') ?? false;
      final kycSubmitted =
          _getStorage.read<bool>('kyc_submitted_$userId') ?? false;
      // TODO: Ideally, also check Firestore if profile/KYC status exists as backup

      if (!detailsComplete) {
        // Navigate to User Details screen if not complete
        if (currentRoute != Routes.USER_DETAILS) {
          print(
              'Auth Listener: User logged in, details incomplete, navigating to USER_DETAILS');
          Get.offAllNamed(Routes.USER_DETAILS);
        }
      } else if (!kycSubmitted) {
        // Navigate to KYC Upload screen if details are complete but KYC not submitted
        if (currentRoute != Routes.KYC_UPLOAD) {
          print(
              'Auth Listener: User logged in, details complete, KYC incomplete, navigating to KYC_UPLOAD');
          Get.offAllNamed(Routes.KYC_UPLOAD);
        }
      } else {
        // Navigate to Home (Dashboard) if details and KYC are complete
        if (currentRoute != Routes.HOME) {
          print(
              'Auth Listener: User logged in, profile complete, navigating to HOME');
          Get.offAllNamed(Routes.HOME);
        }
      }
    } else {
      // User is logged out
      // Navigate to Anonymous Home if not already there (or on Login/OTP)
      if (currentRoute != Routes.ANONYMOUS_HOME &&
          currentRoute != Routes.LOGIN &&
          currentRoute != Routes.OTP) {
        print('Auth Listener: User logged out, navigating to ANONYMOUS_HOME');
        Get.offAllNamed(Routes.ANONYMOUS_HOME);
      }
    }
  }

  @override
  void onClose() {
    mobileController.dispose();
    otpController.dispose();
    _timer?.cancel();
    super.onClose();
  }

  // Method to send OTP
  Future<void> sendOtp() async {
    if (mobileController.text.isEmpty || mobileController.text.length != 10) {
      Get.snackbar('Error', 'Please enter a valid 10-digit mobile number',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    mobileNumber.value = '+91${mobileController.text}';

    try {
      await _auth.verifyPhoneNumber(
        phoneNumber: mobileNumber.value,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification if Android supports it
          await _signInWithCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          isLoading.value = false;
          Get.snackbar('Error', e.message ?? 'Verification failed',
              snackPosition: SnackPosition.BOTTOM);
          isOtpSent.value = false;
        },
        codeSent: (String verificationId, int? resendToken) {
          this.verificationId.value = verificationId;
          this.resendToken.value = resendToken;
          isLoading.value = false;
          isOtpSent.value = true;
          startResendTimer();
          Get.toNamed(Routes.OTP); // Navigate to OTP Screen (Need to define this route)
          Get.snackbar('Success', 'OTP sent to ${mobileNumber.value}',
              snackPosition: SnackPosition.BOTTOM);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          this.verificationId.value = verificationId;
        },
        timeout: const Duration(seconds: 60),
        forceResendingToken: resendToken.value,
      );
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Failed to send OTP: $e',
          snackPosition: SnackPosition.BOTTOM);
      isOtpSent.value = false; // Reset state
    }
  }

  // Method to verify OTP
  Future<void> verifyOtp() async {
    if (otpController.text.isEmpty || otpController.text.length != 6) {
      Get.snackbar('Error', 'Please enter the 6-digit OTP',
          snackPosition: SnackPosition.BOTTOM);
      return;
    }

    isLoading.value = true;
    otp.value = otpController.text;

    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId.value,
        smsCode: otp.value,
      );
      await _signInWithCredential(credential);
    } catch (e) {
      isLoading.value = false;
      Get.snackbar('Error', 'Invalid OTP or verification failed: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      // Don't set isLoading to false here, let _signInWithCredential handle it or the auth state change listener
    }
  }

  // Sign in helper
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      UserCredential userCredential =
          await _auth.signInWithCredential(credential);
      Get.snackbar('Success', 'Logged in successfully!',
          snackPosition: SnackPosition.BOTTOM);
      // Clear fields after successful login
      mobileController.clear();
      otpController.clear();
      isOtpSent.value = false;
      _timer?.cancel();
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Login Error', 'Failed to sign in: ${e.message}',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  // Resend OTP
  Future<void> resendOtp() async {
    if (resendToken.value != null) {
      isLoading.value = true;
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: mobileNumber.value,
          verificationCompleted: (PhoneAuthCredential credential) async {
            /* ... */
          },
          verificationFailed: (FirebaseAuthException e) {/* ... */},
          codeSent: (String verificationId, int? resendToken) {
            this.verificationId.value = verificationId;
            this.resendToken.value = resendToken;
            isLoading.value = false;
            startResendTimer(); // Restart timer
            Get.snackbar('Success', 'New OTP sent to ${mobileNumber.value}',
                snackPosition: SnackPosition.BOTTOM);
          },
          codeAutoRetrievalTimeout: (String verificationId) {/* ... */},
          timeout: const Duration(seconds: 60),
          forceResendingToken: resendToken.value, // Crucial for resend
        );
      } catch (e) {
        isLoading.value = false;
        Get.snackbar('Error', 'Failed to resend OTP: $e',
            snackPosition: SnackPosition.BOTTOM);
      }
    } else {
      Get.snackbar('Error', 'Cannot resend OTP yet.',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  // Start Resend Timer
  void startResendTimer() {
    _timer?.cancel(); // Cancel any existing timer
    countdown.value = 60; // Set countdown duration
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown.value > 0) {
        countdown.value--;
      } else {
        timer.cancel();
      }
    });
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    // Listener (_handleAuthStateChanged) will navigate to ANONYMOUS_HOME
  }
}
