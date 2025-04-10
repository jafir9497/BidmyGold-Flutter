import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../routes/app_pages.dart';
import '../../../../data/models/bid_model.dart';

class PawnbrokerPlaceBidController extends GetxController {
  // Form key
  final formKey = GlobalKey<FormState>();

  // Form controllers
  final amountController = TextEditingController();
  final interestRateController = TextEditingController();
  final noteController = TextEditingController();

  // Firebase instances
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  // Observable properties
  var isLoading = true.obs;
  var isSubmitting = false.obs;
  var loanRequestId = ''.obs;
  var loanRequestData = <String, dynamic>{}.obs;
  var userData = <String, dynamic>{}.obs;
  var selectedTenure = 6.obs;
  var existingBid = Rxn<Map<String, dynamic>>();

  // Tenure options
  final List<int> tenureOptions = [3, 6, 9, 12, 24];

  // Edit mode flag
  bool get isEditMode => existingBid.value != null;

  @override
  void onInit() {
    super.onInit();
    _getArgumentsAndSetupForm();
  }

  @override
  void onClose() {
    amountController.dispose();
    interestRateController.dispose();
    noteController.dispose();
    super.onClose();
  }

  // Initialize the controller with data from arguments
  void _getArgumentsAndSetupForm() {
    try {
      isLoading.value = true;

      final args = Get.arguments;
      if (args == null) {
        Get.back();
        return;
      }

      // Get loan request ID and data
      loanRequestId.value = args['loanRequestId'] ?? '';
      loanRequestData.value = args['loanRequestData'] ?? {};
      userData.value = args['userData'] ?? {};

      // Check if editing an existing bid
      if (args['editBid'] == true && args['existingBid'] != null) {
        existingBid.value = args['existingBid'];
        _populateFormWithExistingBid();
      } else {
        // For new bids, set default amount to the requested amount
        if (loanRequestData.containsKey('loanAmount')) {
          amountController.text = loanRequestData['loanAmount'].toString();
        }
        // Set default interest rate
        interestRateController.text = '12.0'; // Default 12%
      }
    } catch (e) {
      print('Error initializing bid form: $e');
      Get.snackbar('Error', 'Failed to load bid form data');
    } finally {
      isLoading.value = false;
    }
  }

  // Populate form with existing bid data
  void _populateFormWithExistingBid() {
    if (existingBid.value == null) return;

    final bid = existingBid.value!;
    amountController.text = bid['offeredAmount']?.toString() ?? '';
    interestRateController.text = bid['interestRate']?.toString() ?? '';
    noteController.text = bid['note'] ?? '';
    selectedTenure.value = bid['loanTenure'] ?? 6;
  }

  // Validate amount field
  String? validateAmount(String? value) {
    if (value == null || value.isEmpty) {
      return 'amount_required'.tr;
    }
    try {
      final amount = double.parse(value);
      if (amount <= 0) {
        return 'amount_must_be_positive'.tr;
      }
    } catch (e) {
      return 'invalid_amount'.tr;
    }
    return null;
  }

  // Validate interest rate field
  String? validateInterestRate(String? value) {
    if (value == null || value.isEmpty) {
      return 'interest_rate_required'.tr;
    }
    try {
      final rate = double.parse(value);
      if (rate <= 0) {
        return 'rate_must_be_positive'.tr;
      }
      if (rate > 36) {
        return 'rate_too_high'.tr;
      }
    } catch (e) {
      return 'invalid_rate'.tr;
    }
    return null;
  }

  // Validate tenure field
  String? validateTenure(int? value) {
    if (value == null) {
      return 'tenure_required'.tr;
    }
    return null;
  }

  // Submit or update bid
  Future<void> submitBid() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    try {
      isSubmitting.value = true;

      final pawnbrokerUid = _auth.currentUser?.uid;
      if (pawnbrokerUid == null) {
        throw Exception('User not logged in');
      }

      final amount = double.parse(amountController.text);
      final interestRate = double.parse(interestRateController.text);
      final note = noteController.text.trim();
      final tenure = selectedTenure.value;

      if (isEditMode) {
        // Update existing bid
        await _updateBid(
          pawnbrokerUid,
          amount,
          interestRate,
          tenure,
          note,
        );
        Get.snackbar('Success', 'bid_updated'.tr);
      } else {
        // Create new bid
        await _createNewBid(
          pawnbrokerUid,
          amount,
          interestRate,
          tenure,
          note,
        );
        Get.snackbar('Success', 'bid_placed'.tr);
      }

      // Return success result and go back
      Get.back(result: true);
    } catch (e) {
      print('Error submitting bid: $e');
      Get.snackbar('Error', 'Failed to submit bid: $e');
    } finally {
      isSubmitting.value = false;
    }
  }

  // Create a new bid
  Future<void> _createNewBid(
    String pawnbrokerUid,
    double amount,
    double interestRate,
    int tenure,
    String note,
  ) async {
    await _firestore.collection('bids').add({
      'loanRequestId': loanRequestId.value,
      'pawnbrokerUid': pawnbrokerUid,
      'offeredAmount': amount,
      'interestRate': interestRate,
      'loanTenure': tenure,
      'note': note,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update loan request status if needed
    await _firestore
        .collection('loanRequests')
        .doc(loanRequestId.value)
        .update({
      'hasBids': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Update an existing bid
  Future<void> _updateBid(
    String pawnbrokerUid,
    double amount,
    double interestRate,
    int tenure,
    String note,
  ) async {
    if (existingBid.value == null || !existingBid.value!.containsKey('id')) {
      throw Exception('No valid bid to update');
    }

    final bidId = existingBid.value!['id'];
    await _firestore.collection('bids').doc(bidId).update({
      'offeredAmount': amount,
      'interestRate': interestRate,
      'loanTenure': tenure,
      'note': note,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
