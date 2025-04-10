import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/onboarding/controllers/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: controller.skipOnboarding,
                  child: Text('skip'.tr),
                ),
              ),
              Expanded(
                // Page View
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: controller.onboardingPages.length,
                  itemBuilder: (context, index) {
                    final page = controller.onboardingPages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Placeholder Image - Replace with actual image widget
                        Image.asset(
                          page['image']!,
                          height: Get.height * 0.3,
                          errorBuilder: (context, error, stackTrace) => Icon(
                              Icons.image_not_supported,
                              size:
                                  Get.height * 0.3), // Show icon if image fails
                        ),
                        const SizedBox(height: 40),
                        Text(
                          page['title']!.tr,
                          style: theme.textTheme.headlineMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          page['description']!.tr,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Dots Indicator and Next Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dots
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.onboardingPages.length,
                            (index) => Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: controller.currentPageIndex.value == index
                                  ? 12
                                  : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color:
                                    controller.currentPageIndex.value == index
                                        ? theme.colorScheme.primary
                                        : Colors.grey,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        )),
                    // Next/Done Button
                    Obx(() => ElevatedButton(
                          onPressed: controller.nextPage,
                          child: Text(
                            controller.currentPageIndex.value ==
                                    controller.onboardingPages.length - 1
                                ? 'done'.tr
                                : 'next'.tr,
                          ),
                        )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
