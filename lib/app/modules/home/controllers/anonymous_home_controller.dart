import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';
import '../../../routes/app_pages.dart';

class AnonymousHomeController extends GetxController {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController requiredLoanController = TextEditingController();
  final selectedGoldType = 'Gold 22K'.obs;
  final selectedTenure = 12.0.obs;
  final selectedInterest = 1.0.obs; // Default 1 rupee per 100
  final loanAmount = 0.0.obs;
  final requiredAmount = 0.0.obs;
  final monthlyEmi = 0.0.obs;
  final totalInterest = 0.0.obs;
  final isLoading = false.obs;
  final goldRates = <String, double>{}.obs;
  final usdToInrRate = 0.0.obs;
  final isValidLoanAmount = true.obs;
  final canProceed = false.obs;

  final List<String> goldTypes = [
    'Gold 24K',
    'Gold 22K',
    'Gold 18K',
  ];

  // Interest options in rupees per 100
  final List<double> interestOptions = [0.5, 1.0, 2.0, 5.0];
  
  // Tenure options in months
  final List<double> tenureOptions = [3, 6, 9, 12, 15, 24];

  @override
  void onInit() {
    super.onInit();
    fetchUsdToInrRate();
  }

  Future<void> fetchGoldRates() async {
    try {
      isLoading.value = true;
      final response = await http.get(
        Uri.parse('https://api.metalpriceapi.com/v1/latest?api_key=9a3d8c0dd64594a0d616dff03e7594da&base=USD&currencies=XAU'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final goldPricePerGramUsd = (1 / data['rates']['XAU']) / 31.1035;
        final goldPricePerGramInr = goldPricePerGramUsd * usdToInrRate.value;

        goldRates.value = {
          'Gold 24K': goldPricePerGramInr,
          'Gold 22K': goldPricePerGramInr * (22/24),
          'Gold 18K': goldPricePerGramInr * (18/24),
        };
        calculateLoan(weightController.text);
      } else {
        Get.snackbar('Error', 'Failed to fetch gold rates',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch gold rates: $e',
          snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchUsdToInrRate() async {
    try {
      final response = await http.get(
        Uri.parse('https://api.exchangerate-api.com/v4/latest/USD'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        usdToInrRate.value = data['rates']['INR'];
        await fetchGoldRates();
      } else {
        Get.snackbar('Error', 'Failed to fetch currency rates',
            snackPosition: SnackPosition.BOTTOM);
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to fetch currency rates: $e',
          snackPosition: SnackPosition.BOTTOM);
    }
  }

  void selectGoldType(String type) {
    selectedGoldType.value = type;
    calculateLoan(weightController.text);
  }

  void updateTenure(double months) {
    selectedTenure.value = months;
    calculateLoan(weightController.text);
  }

  void updateInterest(double rate) {
    selectedInterest.value = rate;
    calculateLoan(weightController.text);
  }

  void updateRequiredLoan(String amount) {
    if (amount.isEmpty) {
      requiredAmount.value = 0.0;
      isValidLoanAmount.value = true;
      canProceed.value = false;
      monthlyEmi.value = 0.0;
      totalInterest.value = 0.0;
      calculateLoan(weightController.text);
      return;
    }

    try {
      final requested = double.parse(amount);
      if (requested <= loanAmount.value && requested > 0) {
        requiredAmount.value = requested;
        isValidLoanAmount.value = true;
        canProceed.value = true;
      } else {
        isValidLoanAmount.value = false;
        requiredAmount.value = 0.0;
        canProceed.value = false;
        monthlyEmi.value = 0.0;
        totalInterest.value = 0.0;
        Get.snackbar(
          'Invalid Amount',
          requested <= 0 
              ? 'Please enter a valid amount greater than 0'
              : 'Loan amount exceeds maximum limit of ₹${loanAmount.value.toStringAsFixed(2)}',
          snackPosition: SnackPosition.TOP,
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 3),
        );
      }
      calculateLoan(weightController.text);
    } catch (e) {
      requiredAmount.value = 0.0;
      isValidLoanAmount.value = false;
      canProceed.value = false;
      monthlyEmi.value = 0.0;
      totalInterest.value = 0.0;
    }
  }

  void calculateLoan(String weight) {
    if (weight.isEmpty) {
      loanAmount.value = 0.0;
      monthlyEmi.value = 0.0;
      totalInterest.value = 0.0;
      canProceed.value = false;
      return;
    }

    try {
      final goldWeight = double.parse(weight);
      final rate = goldRates[selectedGoldType.value] ?? 0.0;
      // Maximum loan amount (70% of gold value)
      final maxLoan = goldWeight * rate * 0.70;
      loanAmount.value = maxLoan;

      // Only calculate EMI if the required amount is valid
      if (isValidLoanAmount.value && requiredAmount.value > 0 && requiredAmount.value <= maxLoan) {
        final principal = requiredAmount.value;
        final monthlyInterest = selectedInterest.value / 100;
        final tenure = selectedTenure.value;

        if (principal > 0) {
          final emi = (principal * monthlyInterest * pow(1 + monthlyInterest, tenure)) /
              (pow(1 + monthlyInterest, tenure) - 1);
          monthlyEmi.value = emi;
          totalInterest.value = (emi * tenure) - principal;
          canProceed.value = true;
          return;
        }
      }
      
      // If we reach here, either the amount is invalid or no amount is entered
      monthlyEmi.value = 0.0;
      totalInterest.value = 0.0;
      canProceed.value = false;
      
    } catch (e) {
      loanAmount.value = 0.0;
      monthlyEmi.value = 0.0;
      totalInterest.value = 0.0;
      canProceed.value = false;
    }
  }

  double getCurrentRate() {
    return goldRates[selectedGoldType.value] ?? 0.0;
  }

  String getInterestDisplay() {
    return '₹${selectedInterest.value} per ₹100';
  }

  String getTenureDisplay() {
    return '${selectedTenure.value.toInt()} months';
  }

  void navigateToLogin() {
    Get.toNamed(Routes.LOGIN);
  }

  @override
  void onClose() {
    weightController.dispose();
    requiredLoanController.dispose();
    super.onClose();
  }
}
