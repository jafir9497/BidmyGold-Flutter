import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart';
import 'package:get_storage/get_storage.dart';

class OnboardingController extends GetxController {
  final _getStorage = GetStorage();
  final pageController = PageController();
  var currentPageIndex = 0.obs;

  final List<Map<String, String>> onboardingPages = [
    {
      'image': 'assets/images/onboarding_upload.png',
      'title': 'onboarding_title_1',
      'description': 'onboarding_desc_1',
    },
    {
      'image': 'assets/images/onboarding_bids.png',
      'title': 'onboarding_title_2',
      'description': 'onboarding_desc_2',
    },
    {
      'image': 'assets/images/onboarding_connect.png',
      'title': 'onboarding_title_3',
      'description': 'onboarding_desc_3',
    },
  ];

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentPageIndex.value = index;
  }

  void nextPage() {
    if (currentPageIndex.value < onboardingPages.length - 1) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      finishOnboarding();
    }
  }

  void skipOnboarding() {
    finishOnboarding();
  }

  void finishOnboarding() {
    _getStorage.write('onboarding_complete', true);
    Get.offNamed(Routes.ANONYMOUS_HOME);
  }
}
