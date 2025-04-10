import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/data/providers/gold_api_provider.dart'; // Import API provider

class CalculatorController extends GetxController {
  final GoldApiProvider _apiProvider =
      GoldApiProvider(); // Instance of the provider

  // --- Inputs ---
  final weightController = TextEditingController();
  final amountController = TextEditingController();
  final purityList = ['24K', '22K', '18K', 'Don\'t Know'];
  var selectedPurity = '22K'.obs; // Default value
  var knowPurity = true.obs; // To toggle amount/purity input logic

  // --- Outputs ---
  var estimatedMaxValue = 0.0.obs;
  var estimatedEmi = 0.0.obs;
  var calculatedLoanAmount = 0.0.obs; // Loan amount based on weight/purity

  // --- State ---
  var isLoadingRate = false.obs; // For API call later
  var calculationDone = false.obs;
  var currentGoldRate =
      0.0.obs; // Store the fetched rate (per gram, assume 24k for base)
  var goldRateTimestamp = 0.obs; // Store timestamp of fetched rate
  var apiError = RxnString(); // To store API error messages

  // --- Config ---
  final double ltvPercentage = 0.90; // Loan-to-value (90%)
  final String currency = 'INR'; // Target currency

  @override
  void onInit() {
    super.onInit();
    fetchGoldRate(); // Fetch rate when controller initializes
  }

  @override
  void onClose() {
    weightController.dispose();
    amountController.dispose();
    super.onClose();
  }

  // --- API Call ---
  Future<void> fetchGoldRate() async {
    isLoadingRate.value = true;
    apiError.value = null; // Clear previous error
    try {
      final result = await _apiProvider.getLatestGoldPrice(currency);
      if (result['success']) {
        currentGoldRate.value = result['rate_per_gram'];
        goldRateTimestamp.value = result['timestamp'];
        print(
            'Successfully fetched gold rate: ${currentGoldRate.value} $currency/gram');
      } else {
        apiError.value = result['error'];
        Get.snackbar(
            'API Error', apiError.value ?? 'Failed to fetch gold rate');
        // Keep using placeholder or disable calculation?
      }
    } catch (e) {
      apiError.value = 'Exception during API call: $e';
      Get.snackbar('Error', 'Could not connect to get gold rate');
    } finally {
      isLoadingRate.value = false;
    }
  }

  void onPurityChanged(String? newValue) {
    if (newValue != null) {
      selectedPurity.value = newValue;
      if (newValue == 'Don\'t Know') {
        knowPurity.value = false;
        // Clear weight if user doesn't know purity, they must enter amount
        // weightController.clear();
      } else {
        knowPurity.value = true;
        // Clear amount if user knows purity, we calculate based on weight
        // amountController.clear();
      }
      resetCalculation();
    }
  }

  void calculateLoan() {
    // Clear previous results
    resetCalculation();
    calculationDone.value = false;

    if (currentGoldRate.value <= 0 && apiError.value == null) {
      // Rate not fetched yet or failed, maybe trigger fetch again or show error
      Get.snackbar('Error', 'Gold rate not available. Please try again.');
      fetchGoldRate(); // Attempt to fetch again
      return;
    }
    if (currentGoldRate.value <= 0 && apiError.value != null) {
      Get.snackbar(
          'Error', 'Cannot calculate without gold rate. ${apiError.value}');
      return;
    }

    // --- Basic Validation ---
    if (knowPurity.value && weightController.text.isEmpty) {
      Get.snackbar('Input Error', 'Please enter gold weight');
      return;
    }
    if (!knowPurity.value && amountController.text.isEmpty) {
      Get.snackbar('Input Error', 'Please enter desired loan amount');
      return;
    }

    double weightInGrams = double.tryParse(weightController.text) ?? 0.0;
    double requestedAmount = double.tryParse(amountController.text) ?? 0.0;

    // Calculation using fetched gold rate (assuming API returns 24k rate per gram)
    if (knowPurity.value && weightInGrams > 0) {
      double purityMultiplier = 1.0; // Assume 24k if API rate is 24k
      switch (selectedPurity.value) {
        case '24K':
          purityMultiplier = 1.0;
          break;
        case '22K':
          purityMultiplier = 22.0 / 24.0;
          break;
        case '18K':
          purityMultiplier = 18.0 / 24.0;
          break;
        // default: purityMultiplier = 1.0; // Should not happen if selectedPurity is validated
      }

      double effectiveRatePerGram = currentGoldRate.value * purityMultiplier;
      double totalGoldValue = weightInGrams * effectiveRatePerGram;
      estimatedMaxValue.value = totalGoldValue * ltvPercentage;
      calculatedLoanAmount.value =
          estimatedMaxValue.value; // Start with max eligible

      // Adjust if user requested less
      if (amountController.text.isNotEmpty &&
          requestedAmount > 0 &&
          requestedAmount < calculatedLoanAmount.value) {
        calculatedLoanAmount.value = requestedAmount;
      }
      // Cap input field if user requested more than eligible
      if (amountController.text.isNotEmpty &&
          requestedAmount > calculatedLoanAmount.value) {
        amountController.text = calculatedLoanAmount.value.toStringAsFixed(0);
      }
    } else if (!knowPurity.value && requestedAmount > 0) {
      estimatedMaxValue.value = 0; // Cannot estimate max value accurately
      calculatedLoanAmount.value = requestedAmount;
    } else {
      return; // Invalid state
    }

    // Placeholder EMI
    // TODO: Implement actual EMI calculation based on tenure/interest rate
    if (calculatedLoanAmount.value > 0) {
      estimatedEmi.value = calculatedLoanAmount.value *
          0.05; // TODO: Replace with actual EMI logic
    }

    calculationDone.value = true;
  }

  void resetCalculation() {
    estimatedMaxValue.value = 0.0;
    estimatedEmi.value = 0.0;
    calculatedLoanAmount.value = 0.0;
    calculationDone.value = false;
    // Optionally clear controllers depending on desired UX
    // weightController.clear();
    // amountController.clear();
  }

  void clearForm() {
    weightController.clear();
    amountController.clear();
    selectedPurity.value = '22K'; // Reset purity
    knowPurity.value = true;
    resetCalculation();
  }
}
