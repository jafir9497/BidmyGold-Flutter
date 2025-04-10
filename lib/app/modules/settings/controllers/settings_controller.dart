import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsController extends GetxController {
  final box = GetStorage();
  final appVersion = ''.obs;
  final selectedLanguage = 'English'.obs;

  @override
  void onInit() {
    super.onInit();
    getAppVersion();
    loadLanguage();
  }

  Future<void> getAppVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    appVersion.value = packageInfo.version;
  }

  void loadLanguage() {
    selectedLanguage.value = box.read('language') ?? 'English';
  }

  void changeLanguage(String language) {
    selectedLanguage.value = language;
    box.write('language', language);
    
    // Update app locale based on language
    final locale = language == 'English' ? const Locale('en', 'US') : const Locale('hi', 'IN');
    Get.updateLocale(locale);
  }

  Future<void> openPrivacyPolicy() async {
    const url = 'https://bidmygold.com/privacy-policy';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> openTermsConditions() async {
    const url = 'https://bidmygold.com/terms';
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  Future<void> contactSupport() async {
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: 'support@bidmygold.com',
      queryParameters: {
        'subject': 'BidMyGold Support',
      },
    );
    
    if (await canLaunchUrl(emailLaunchUri)) {
      await launchUrl(emailLaunchUri);
    }
  }
}
