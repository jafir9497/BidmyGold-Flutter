import 'package:get/get.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
// For context, snackbars etc.

// For secure storage/retrieval of API keys
// import 'package:flutter_dotenv/flutter_dotenv.dart';

class RazorpayService extends GetxService {
  late Razorpay _razorpay;

  // TODO: Replace with secure retrieval (e.g., env variables)
  final String _apiKey = 'YOUR_RAZORPAY_KEY_ID'; // <-- Replace!
  // final String _apiSecret = 'YOUR_RAZORPAY_KEY_SECRET'; // <-- Secret should NOT be in client code

  // Callback handlers
  Function(PaymentSuccessResponse)? _onPaymentSuccess;
  Function(PaymentFailureResponse)? _onPaymentError;
  Function(ExternalWalletResponse)? _onExternalWallet;

  @override
  void onInit() {
    super.onInit();
    _razorpay = Razorpay();
    _initializeRazorpayListeners();
    print('RazorpayService Initialized');
  }

  void _initializeRazorpayListeners() {
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  // --- Public Methods ---

  /// Initiates the Razorpay payment process.
  /// Requires order options (amount, currency, receipt, order_id from your backend).
  /// Also requires prefill data (name, email, contact).
  void openCheckout({
    // Required options from your server's order creation
    required double
        amount, // Amount in smallest currency unit (e.g., paise for INR)
    required String orderId,
    required String currency, // e.g., 'INR'
    required String receiptId,
    // User details
    required String userName,
    required String userContact,
    required String userEmail,
    // Other optional details
    String description = 'BidMyGold EMI Payment',
    String appName = 'BidMyGold',
    // Callbacks for this specific payment attempt
    required Function(PaymentSuccessResponse) onPaymentSuccess,
    required Function(PaymentFailureResponse) onPaymentError,
    required Function(ExternalWalletResponse) onExternalWallet,
  }) {
    // Store callbacks for this specific attempt
    _onPaymentSuccess = onPaymentSuccess;
    _onPaymentError = onPaymentError;
    _onExternalWallet = onExternalWallet;

    var options = {
      'key': _apiKey,
      'amount': amount, // Amount should be in paise
      'name': appName,
      'description': description,
      'receipt': receiptId,
      'order_id': orderId, // Generate order_id on your backend
      'prefill': {'contact': userContact, 'email': userEmail, 'name': userName},
      // Add theme, notes, etc. if needed
      // 'theme': {
      //  'color': '#F37254' // Example color
      // },
      // 'notes': {
      // 'loan_id': loanId,
      // 'user_id': userId
      // }
    };

    try {
      print("Opening Razorpay Checkout with options: $options");
      _razorpay.open(options);
    } catch (e) {
      print("Error opening Razorpay checkout: $e");
      // Handle immediate error, maybe call error callback
      _handlePaymentError(PaymentFailureResponse(
          Razorpay.UNKNOWN_ERROR, "Error opening checkout: $e", null));
    }
  }

  // --- Event Handlers ---

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    print("Payment Successful: ${response.paymentId}");
    // IMPORTANT: Verify payment signature on your backend before confirming success!
    // The response contains paymentId, orderId, and signature.
    // Send these to your backend for verification.

    // For now, just call the success callback
    _onPaymentSuccess?.call(response);
    _clearCallbacks();
    // Get.snackbar('Success', "Payment Successful: ID ${response.paymentId}");
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("Payment Error: ${response.code} - ${response.message}");
    // Handle payment failure (e.g., show error message to user)
    _onPaymentError?.call(response);
    _clearCallbacks();
    // Get.snackbar('Payment Failed',
    //              "Error: ${response.code} - ${response.message}",
    //              backgroundColor: Colors.red,
    //              colorText: Colors.white);
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    print("External Wallet Selected: ${response.walletName}");
    // Handle external wallet selection (e.g., inform user)
    _onExternalWallet?.call(response);
    _clearCallbacks();
    // Get.snackbar('Info', "Processing via ${response.walletName}");
  }

  // Helper to clear callbacks after a payment attempt concludes
  void _clearCallbacks() {
    _onPaymentSuccess = null;
    _onPaymentError = null;
    _onExternalWallet = null;
  }

  @override
  void onClose() {
    _razorpay.clear(); // Clear listeners when the service is closed
    super.onClose();
    print('RazorpayService Closed');
  }
}
