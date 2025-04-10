import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';

class LanguageController extends GetxController {
  final _getStorage = GetStorage();
  // List of supported languages (Locale code and Name)
  final supportedLanguages = [
    {'locale': const Locale('en', 'US'), 'name': 'English'},
    {'locale': const Locale('ta', 'IN'), 'name': 'தமிழ்'}, // Tamil
    // Add other supported languages here (e.g., Hindi, Malayalam, etc.)
    // {'locale': const Locale('hi', 'IN'), 'name': 'हिन्दी'},
  ].obs;

  // Variable to hold the currently selected locale
  final selectedLocale = Rx<Locale?>(null);


  // Function to update the application's locale
  void changeLanguage(Locale locale) {
    selectedLocale.value = locale;
    Get.updateLocale(locale);
    // Save setting immediately
    _getStorage.write('language_selected', true);
    _getStorage.write('locale_code', locale.languageCode); // Store lang code
    _getStorage.write(
        'locale_country', locale.countryCode); // Store country code
  }

  // Function to proceed to the next screen (e.g., Onboarding or Login/Home)
  void proceed() {
    if (selectedLocale.value != null) {
      // Save flag (redundant if saved in changeLanguage, but safe)
      _getStorage.write('language_selected', true);

      // Check if onboarding is complete
      final onboardingComplete =
          _getStorage.read<bool>('onboarding_complete') ?? false;

      if (!onboardingComplete) {
        Get.offNamed(Routes.ONBOARDING);
      } else {
        // Onboarding was already done, check auth state (listener will handle)
        // Navigate to anonymous home, AuthController listener will redirect if logged in
        Get.offNamed(Routes.ANONYMOUS_HOME);
      }
    } else {
      Get.snackbar('select_language_error'.tr, 'Please select a language',
          snackPosition: SnackPosition.BOTTOM);
    }
  }
}
