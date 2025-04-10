import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart'; // To get user details
import 'package:cloud_firestore/cloud_firestore.dart'; // To potentially log payments

// TODO: Replace with actual keys later
const String _razorpayKeyId = 'YOUR_KEY_ID';
// const String _razorpayKeySecret = 'YOUR_KEY_SECRET'; // Secret is usually used backend

class PaymentService extends GetxService {
  late Razorpay _razorpay;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void onInit() {
    super.onInit();
    _initializeRazorpay();
  }

  void _initializeRazorpay() {
    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
    print('Razorpay Initialized');
  }

  // --- Payment Processing ---

  Future<void> makePayment({
    required double amount, // Amount in paisa (e.g., 10000 for ₹100.00)
    required String orderId, // Razorpay Order ID obtained from your backend
    String? description = 'BidMyGold EMI Payment',
    String? userName,
    String? userEmail,
    String? userPhone,
  }) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) {
      _showErrorSnackbar('User not authenticated.');
      return;
    }

    // Fetch user details if not provided
    userName ??= currentUser.displayName ?? 'App User';
    userEmail ??=
        currentUser.email ?? 'not@provided.com'; // Razorpay prefers an email
    userPhone ??= currentUser.phoneNumber ?? '';

    if (userPhone == null || userPhone.isEmpty) {
      _showErrorSnackbar('User phone number is required for payment.');
      return;
    }

    var options = {
      'key': _razorpayKeyId, // Use the placeholder Key ID
      'amount': amount,
      'name': 'BidMyGold App',
      'order_id': orderId, // The Razorpay Order ID from your backend
      'description': description,
      'prefill': {
        'contact': userPhone,
        'email': userEmail,
        // 'name': userName // Name is optional in prefill
      },
      'external': {
        'wallets': ['paytm'] // Optional: Specify external wallets
      },
      // Add theme options if needed
      // 'theme': {
      //   'color': '#F37254'
      // }
    };

    try {
      print('Opening Razorpay Checkout with options: $options');
      _razorpay.open(options);
    } catch (e) {
      print('Error opening Razorpay checkout: $e');
      _showErrorSnackbar('Error initiating payment: ${e.toString()}');
    }
  }

  // --- Event Handlers ---

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print('Payment Successful: ${response.paymentId}');
    print('Order ID: ${response.orderId}');
    print('Signature: ${response.signature}');

    Get.snackbar(
      'Payment Successful',
      'Payment ID: ${response.paymentId}',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // **IMPORTANT:**
    // 1. Send response.paymentId, response.orderId, response.signature to your backend.
    // 2. Your backend MUST verify the payment signature using the Key Secret to confirm authenticity.
    // 3. Only after backend verification, update the loan status, payment record, etc.

    _logPaymentAttempt(
        orderId: response.orderId,
        paymentId: response.paymentId,
        signature: response.signature,
        status: 'success');

    // TODO: Navigate to a success screen or update UI
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print('Payment Failed: ${response.code} - ${response.message}');

    _showErrorSnackbar(
      'Payment Failed: ${response.message ?? "Unknown error"}',
    );

    // Log the failed attempt
    _logPaymentAttempt(
        orderId: null, // Order ID might be in response.error? check docs
        status: 'failed',
        errorCode: response.code?.toString(),
        errorMessage: response.message);

    // TODO: Navigate back or show error message in UI
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print('External Wallet Selected: ${response.walletName}');
    // You might not need to do much here, depends on requirements
    Get.snackbar(
      'External Wallet',
      'Processing via: ${response.walletName}',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  // --- Helper Methods ---

  void _showErrorSnackbar(String message) {
    Get.snackbar(
      'Payment Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      duration: const Duration(seconds: 5),
    );
  }

  Future<void> _logPaymentAttempt({
    String? orderId,
    String? paymentId,
    String? signature,
    required String status, // 'success', 'failed'
    String? errorCode,
    String? errorMessage,
  }) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore.collection('payment_logs').add({
        'userId': currentUser.uid,
        'phone': currentUser.phoneNumber,
        'orderId': orderId,
        'paymentId': paymentId,
        'signature': signature,
        'status': status,
        'errorCode': errorCode,
        'errorMessage': errorMessage,
        'timestamp': FieldValue.serverTimestamp(),
        'paymentMethod': 'razorpay', // Indicate payment provider
      });
    } catch (e) {
      print('Error logging payment attempt: $e');
    }
  }

  @override
  void onClose() {
    _razorpay.clear(); // Clear event listeners
    super.onClose();
  }
}
