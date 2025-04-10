import 'dart:io'; // For File operations
import 'dart:typed_data'; // For Uint8List
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:path_provider/path_provider.dart'; // To get temp directory
import 'package:open_file/open_file.dart'; // To open the saved PDF
import 'package:flutter/material.dart'; // Import Material for dialog widgets
import 'package:razorpay_flutter/razorpay_flutter.dart'; // Import Razorpay types

import '../../../../services/razorpay_service.dart'; // Import new RazorpayService
import '../../../../data/services/receipt_service.dart'; // Corrected ReceiptService path

// Placeholder for EMI data structure
class EmiData {
  final String id; // EMI document ID
  final int emiNumber;
  final double amount;
  final Timestamp dueDate;
  final String status; // e.g., 'due', 'paid', 'overdue', 'upcoming'
  final Timestamp? paidDate;
  final String? paymentId;

  EmiData({
    required this.id,
    required this.emiNumber,
    required this.amount,
    required this.dueDate,
    required this.status,
    this.paidDate,
    this.paymentId,
  });

  factory EmiData.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return EmiData(
      id: doc.id,
      emiNumber: data['emiNumber'] ?? 0,
      amount: (data['amount'] ?? 0.0).toDouble(),
      dueDate: data['dueDate'] ?? Timestamp.now(),
      status: data['status'] ?? 'unknown',
      paidDate: data['paidDate'] as Timestamp?,
      paymentId: data['paymentId'] as String?,
    );
  }
}

class EmiPaymentController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // Replace PaymentService with RazorpayService
  final RazorpayService _razorpayService = Get.find<RazorpayService>();
  final ReceiptService _receiptService =
      Get.put(ReceiptService()); // Instantiate ReceiptService

  // Observables
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;
  final Rxn<Map<String, dynamic>> activeLoan = Rxn<Map<String, dynamic>>();
  final RxList<EmiData> emiSchedule = <EmiData>[].obs;
  final RxBool isPaymentProcessing =
      false.obs; // For specific EMI payment action
  final RxBool isGeneratingReceipt =
      false.obs; // Loading state for receipt generation

  User? get currentUser => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    fetchLoanAndEmiDetails();
  }

  Future<void> fetchLoanAndEmiDetails({bool isRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    if (isRefresh) {
      activeLoan.value = null;
      emiSchedule.clear();
    }

    if (currentUser == null) {
      errorMessage.value = 'User not authenticated.';
      isLoading.value = false;
      return;
    }

    try {
      // 1. Fetch Active Loan for the user
      final loanQuery = await _firestore
          .collection('loans') // Assuming 'loans' collection
          .where('userId', isEqualTo: currentUser!.uid)
          .where('status', isEqualTo: 'active') // Assuming 'active' status
          .limit(1)
          .get();

      if (loanQuery.docs.isEmpty) {
        // No active loan found
        activeLoan.value = null;
        emiSchedule.clear();
        isLoading.value = false;
        print('No active loan found for user ${currentUser!.uid}');
        return;
      }

      final loanDoc = loanQuery.docs.first;
      activeLoan.value = loanDoc.data()
        ..['id'] = loanDoc.id; // Store loan data including its ID

      // Fetch Pawnbroker details associated with the loan (assuming pawnbrokerId is on the loan)
      final String? pawnbrokerId = activeLoan.value?['pawnbrokerId'];
      Map<String, dynamic> pawnbrokerData = {};
      if (pawnbrokerId != null) {
        final pawnbrokerDoc =
            await _firestore.collection('pawnbrokers').doc(pawnbrokerId).get();
        if (pawnbrokerDoc.exists) {
          pawnbrokerData = pawnbrokerDoc.data()!;
        }
      }
      // Store pawnbroker data if needed elsewhere, or pass directly to receipt function
      // For simplicity, we'll pass it directly later.

      // 2. Fetch EMI Schedule for the active loan
      // Assuming EMIs are in a subcollection named 'emis' within the loan document
      final emiQuery = await loanDoc.reference
          .collection('emis')
          .orderBy('emiNumber', descending: false)
          .get();

      emiSchedule.value =
          emiQuery.docs.map((doc) => EmiData.fromFirestore(doc)).toList();

      print('Fetched loan ${loanDoc.id} and ${emiSchedule.length} EMIs.');
    } catch (e) {
      print("Error fetching loan/EMI details: $e");
      errorMessage.value = 'Failed to load loan details: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  // --- Payment Initiation ---

  Future<void> initiateEmiPayment(EmiData emiToPay) async {
    if (isPaymentProcessing.value) return;
    if (activeLoan.value == null) {
      Get.snackbar('Error', 'No active loan found.');
      return;
    }
    if (currentUser == null) {
      Get.snackbar('Error', 'Authentication error.');
      return;
    }

    isPaymentProcessing.value = true;
    try {
      // **STEP 1 (Backend Simulation): Create Razorpay Order**
      // In a real app, call your backend endpoint here, passing details like:
      // - loanId: activeLoan.value!['id']
      // - emiId: emiToPay.id
      // - amount: emiToPay.amount * 100 // Convert to paisa
      // - userId: currentUser!.uid
      // Your backend uses the Razorpay SDK (with secret) to create the order
      // and returns the order_id.

      // --- Placeholder ---
      print(
          '[STUB] Calling backend to create Razorpay order for EMI ${emiToPay.emiNumber}...');
      await Future.delayed(
          const Duration(seconds: 1)); // Simulate network delay
      // Replace this with the actual order ID from your backend
      final String razorpayOrderId =
          'order_EMISTUB_${DateTime.now().millisecondsSinceEpoch}';
      print('[STUB] Received Razorpay Order ID: $razorpayOrderId');
      // --- End Placeholder ---

      // **STEP 2: Initiate Payment via RazorpayService**
      // Fetch user details for prefill (or ensure they are loaded elsewhere)
      String userName = currentUser!.displayName ?? 'App User';
      String? userEmail = currentUser!.email;
      String? userPhone = currentUser!.phoneNumber;

      // Attempt to fetch name from Firestore if display name is null/empty
      if (userName == 'App User') {
        final userDoc =
            await _firestore.collection('users').doc(currentUser!.uid).get();
        if (userDoc.exists) {
          userName = userDoc.data()?['name'] ?? userName;
          userEmail ??= userDoc
              .data()?['email']; // Use Firestore email if auth email is null
        }
      }

      // Call RazorpayService openCheckout
      _razorpayService.openCheckout(
        amount: emiToPay.amount * 100, // Amount in paisa
        orderId: razorpayOrderId,
        currency: 'INR', // Assuming INR
        receiptId:
            'EMI_${activeLoan.value!['id']}_${emiToPay.emiNumber}', // Example receipt ID
        description:
            'EMI Payment #${emiToPay.emiNumber} for Loan ${activeLoan.value!['id']}',
        userName: userName,
        userContact: userPhone ?? '', // Provide empty string if null
        userEmail: userEmail ?? 'no-email@bidmygold.app', // Provide a fallback
        // Define callbacks
        onPaymentSuccess: (PaymentSuccessResponse response) {
          _handleRazorpaySuccess(response, emiToPay.id);
        },
        onPaymentError: (PaymentFailureResponse response) {
          _handleRazorpayError(response);
        },
        onExternalWallet: (ExternalWalletResponse response) {
          _handleRazorpayExternalWallet(response);
        },
      );

      // **STEP 3: Handle Response (via Callbacks)**
      // Logic is now moved to the callback methods below.
      // The UI might need manual refresh or reactive updates based on Firestore changes initiated by backend verification.
    } catch (e) {
      print("Error initiating EMI payment: $e");
      Get.snackbar(
          'Payment Error', 'Could not start payment process: ${e.toString()}');
      isPaymentProcessing.value = false; // Ensure loading stops on error
    }
  }

  // --- Razorpay Callback Handlers ---

  void _handleRazorpaySuccess(
      PaymentSuccessResponse response, String emiDocId) {
    print(
        'Razorpay Success: PaymentID=${response.paymentId}, OrderID=${response.orderId}, Signature=${response.signature}');
    isPaymentProcessing.value = false; // Stop loading indicator

    // !!! CRITICAL TODO: SEND TO BACKEND FOR SIGNATURE VERIFICATION !!!
    // Your backend must verify response.signature using response.orderId, response.paymentId and your API Secret.
    // Only after successful backend verification should the payment be considered truly complete.
    // Your backend should then update the Firestore EMI status to 'paid'.

    // --- Placeholder ---
    Get.snackbar('Payment Successful (Pending Verification)',
        'Payment ID: ${response.paymentId}. Please wait for confirmation.',
        duration: const Duration(seconds: 5));
    // Manually refresh data after a delay (temporary solution - ideally backend updates trigger UI refresh)
    Future.delayed(const Duration(seconds: 3),
        () => fetchLoanAndEmiDetails(isRefresh: true));
    // --- End Placeholder ---
  }

  void _handleRazorpayError(PaymentFailureResponse response) {
    print('Razorpay Error: Code=${response.code}, Message=${response.message}');
    isPaymentProcessing.value = false; // Stop loading indicator
    Get.snackbar(
        'Payment Failed', 'Error ${response.code}: ${response.message}',
        backgroundColor: Colors.red,
        colorText: Colors.white,
        duration: const Duration(seconds: 5));
  }

  void _handleRazorpayExternalWallet(ExternalWalletResponse response) {
    print('Razorpay External Wallet: ${response.walletName}');
    isPaymentProcessing.value = false; // Typically stop loading here too
    // You might want to show an info message
    // Get.snackbar('Info', 'Processing payment via ${response.walletName}...');
  }

  // --- Receipt Generation ---

  Future<void> downloadReceipt(EmiData emiData) async {
    if (isGeneratingReceipt.value) return;
    if (emiData.status != 'paid') {
      Get.snackbar('Info', 'Receipt is only available for paid EMIs.');
      return;
    }
    if (activeLoan.value == null || currentUser == null) {
      Get.snackbar('Error', 'Required loan or user data is missing.');
      return;
    }

    isGeneratingReceipt.value = true;
    Get.dialog(
        // Show a loading dialog
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false);

    try {
      // 1. Prepare Data for PDF Service
      // Fetch pawnbroker details (assuming pawnbrokerId is on the loan document)
      final String? pawnbrokerId = activeLoan.value?['pawnbrokerId'];
      Map<String, dynamic> pawnbrokerData = {};
      if (pawnbrokerId != null) {
        final pawnbrokerDoc =
            await _firestore.collection('pawnbrokers').doc(pawnbrokerId).get();
        if (pawnbrokerDoc.exists) {
          pawnbrokerData = pawnbrokerDoc.data()!;
        }
      }

      // Prepare user data
      Map<String, dynamic> userData = {
        'name': currentUser!.displayName, // Start with Auth display name
        'phone': currentUser!.phoneNumber ?? 'N/A',
      };
      // Fetch from Firestore if display name is null/empty
      if (userData['name'] == null || (userData['name'] as String).isEmpty) {
        final userDoc =
            await _firestore.collection('users').doc(currentUser!.uid).get();
        if (userDoc.exists) {
          userData['name'] = userDoc.data()?['name'] ?? 'App User';
        }
      }

      // 2. Generate PDF Bytes
      final Uint8List pdfBytes = await _receiptService.generateEmiReceiptPdf(
        emiData: emiData,
        loanData: activeLoan.value!,
        userData: userData,
        pawnbrokerData: pawnbrokerData, // Pass fetched pawnbroker data
      );

      // 3. Get Temporary Directory
      final Directory tempDir = await getTemporaryDirectory();
      final String filePath =
          '${tempDir.path}/EMI-Receipt-${activeLoan.value!['id']}-${emiData.emiNumber}.pdf';

      // 4. Save the PDF File
      final File file = File(filePath);
      await file.writeAsBytes(pdfBytes, flush: true);
      print('Receipt saved to: $filePath');

      // 5. Open the PDF File
      final result = await OpenFile.open(filePath);
      print('OpenFile result: ${result.type} - ${result.message}');

      if (result.type != ResultType.done) {
        Get.snackbar('Error', 'Could not open receipt file: ${result.message}');
      }
    } catch (e) {
      print("Error generating or opening receipt: $e");
      Get.snackbar(
          'Error', 'Failed to generate or open receipt: ${e.toString()}');
    } finally {
      if (Get.isDialogOpen ?? false) Get.back(); // Close loading dialog
      isGeneratingReceipt.value = false;
    }
  }

  // Helper for formatting dates in the UI
  String formatDate(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return DateFormat('dd MMM yyyy').format(timestamp.toDate());
  }
}
