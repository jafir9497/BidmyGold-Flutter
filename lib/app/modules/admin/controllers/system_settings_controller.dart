import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../utils/admin_auth_service.dart';

class SystemSettingsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AdminAuthService _authService = Get.find<AdminAuthService>();
  final String _settingsDocPath = 'configs/appSettings';

  // Form controllers
  final goldRateController = TextEditingController();
  final loanInterestController = TextEditingController();
  final maxLoanPercentageController = TextEditingController();
  final minLoanAmountController = TextEditingController();
  final maxLoanAmountController = TextEditingController();
  final serviceChargeController = TextEditingController();
  final goldApiKeyController = TextEditingController();
  final defaultLoanRateController = TextEditingController();
  final maxLoanTenureController = TextEditingController();

  // Observables
  final RxBool isLoading = true.obs;
  final RxBool isSaving = false.obs;
  final RxBool goldRateManualEntry = false.obs;
  final RxString selectedCurrency = 'INR'.obs;
  final RxString notificationSettings = 'all'.obs;
  final RxBool pushNotificationsEnabled = true.obs;

  // Settings
  final RxDouble goldRate = 0.0.obs;
  final RxDouble loanInterestRate = 0.0.obs;
  final RxDouble maxLoanPercentage = 0.0.obs;
  final RxDouble minLoanAmount = 0.0.obs;
  final RxDouble maxLoanAmount = 0.0.obs;
  final RxDouble serviceCharge = 0.0.obs;
  final RxString lastGoldRateUpdate = ''.obs;
  final RxBool maintenanceMode = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchSettings();
  }

  @override
  void onClose() {
    goldRateController.dispose();
    loanInterestController.dispose();
    maxLoanPercentageController.dispose();
    minLoanAmountController.dispose();
    maxLoanAmountController.dispose();
    serviceChargeController.dispose();
    goldApiKeyController.dispose();
    defaultLoanRateController.dispose();
    maxLoanTenureController.dispose();
    super.onClose();
  }

  Future<void> fetchSettings() async {
    isLoading.value = true;
    try {
      final docSnapshot = await _firestore.doc(_settingsDocPath).get();

      if (docSnapshot.exists && docSnapshot.data() != null) {
        final data = docSnapshot.data()!;
        // Populate controllers and observables from Firestore data
        goldApiKeyController.text = data['goldApiKey'] ?? '';
        defaultLoanRateController.text =
            (data['defaultLoanRate'] ?? 0.0).toString();
        maxLoanTenureController.text =
            (data['maxLoanTenureMonths'] ?? 12).toString();
        pushNotificationsEnabled.value =
            data['pushNotificationsEnabled'] ?? true;
        goldRate.value = (data['goldRate'] ?? 0.0).toDouble();
        loanInterestRate.value = (data['loanInterestRate'] ?? 12.0).toDouble();
        maxLoanPercentage.value =
            (data['maxLoanPercentage'] ?? 90.0).toDouble();
        minLoanAmount.value = (data['minLoanAmount'] ?? 1000.0).toDouble();
        maxLoanAmount.value = (data['maxLoanAmount'] ?? 1000000.0).toDouble();
        serviceCharge.value = (data['serviceCharge'] ?? 2.0).toDouble();
        selectedCurrency.value = data['currency'] ?? 'INR';
        goldRateManualEntry.value = data['goldRateManualEntry'] ?? false;
        maintenanceMode.value = data['maintenanceMode'] ?? false;
        notificationSettings.value = data['notificationSettings'] ?? 'all';

        // Format for display
        final Timestamp? timestamp = data['lastGoldRateUpdate'];
        if (timestamp != null) {
          final date = timestamp.toDate();
          lastGoldRateUpdate.value =
              '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
        }

        // Update controllers
        goldRateController.text = goldRate.value.toString();
        loanInterestController.text = loanInterestRate.value.toString();
        maxLoanPercentageController.text = maxLoanPercentage.value.toString();
        minLoanAmountController.text = minLoanAmount.value.toString();
        maxLoanAmountController.text = maxLoanAmount.value.toString();
        serviceChargeController.text = serviceCharge.value.toString();
      } else {
        print("Settings document doesn't exist, using defaults.");
        goldApiKeyController.text = '';
        defaultLoanRateController.text = '12.0';
        maxLoanTenureController.text = '36';
        pushNotificationsEnabled.value = true;
        goldRate.value = 0.0;
        loanInterestRate.value = 12.0;
        maxLoanPercentage.value = 90.0;
        minLoanAmount.value = 1000.0;
        maxLoanAmount.value = 1000000.0;
        serviceCharge.value = 2.0;
        selectedCurrency.value = 'INR';
        goldRateManualEntry.value = false;
        maintenanceMode.value = false;
        notificationSettings.value = 'all';
        lastGoldRateUpdate.value = '';
      }
    } catch (e) {
      print("Error fetching system settings: $e");
      Get.snackbar('Error', 'Failed to load settings: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> saveSettings() async {
    isSaving.value = true;
    try {
      final settingsData = {
        'goldApiKey': goldApiKeyController.text.trim(),
        'defaultLoanRate':
            double.tryParse(defaultLoanRateController.text) ?? 12.0,
        'maxLoanTenureMonths': int.tryParse(maxLoanTenureController.text) ?? 36,
        'pushNotificationsEnabled': pushNotificationsEnabled.value,
        'goldRate': goldRate.value,
        'loanInterestRate': loanInterestRate.value,
        'maxLoanPercentage': maxLoanPercentage.value,
        'minLoanAmount': minLoanAmount.value,
        'maxLoanAmount': maxLoanAmount.value,
        'serviceCharge': serviceCharge.value,
        'currency': selectedCurrency.value,
        'goldRateManualEntry': goldRateManualEntry.value,
        'maintenanceMode': maintenanceMode.value,
        'notificationSettings': notificationSettings.value,
        'lastUpdated': FieldValue.serverTimestamp(),
        'lastUpdatedByAdmin': _authService.adminUser.value?.id ?? 'unknown',
        'lastGoldRateUpdate':
            goldRateManualEntry.value ? FieldValue.serverTimestamp() : null,
      };

      await _firestore
          .doc(_settingsDocPath)
          .set(settingsData, SetOptions(merge: true));

      await _logAdminAction('Updated system settings');

      Get.snackbar('Success', 'System settings saved successfully!');

      fetchSettings();
    } catch (e) {
      print("Error saving system settings: $e");
      Get.snackbar('Error', 'Failed to save settings: ${e.toString()}');
    } finally {
      isSaving.value = false;
    }
  }

  void toggleMaintenanceMode() {
    maintenanceMode.value = !maintenanceMode.value;
  }

  void toggleGoldRateManualEntry() {
    goldRateManualEntry.value = !goldRateManualEntry.value;
  }

  void setCurrency(String currency) {
    selectedCurrency.value = currency;
  }

  void setNotificationSettings(String setting) {
    notificationSettings.value = setting;
  }

  Future<void> _logAdminAction(String action) async {
    try {
      await _firestore.collection('admin_logs').add({
        'adminId': _authService.adminUser.value?.id ?? 'unknown',
        'adminName': _authService.adminUser.value?.name ?? 'Unknown Admin',
        'action': action,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging admin action: $e');
    }
  }
}
