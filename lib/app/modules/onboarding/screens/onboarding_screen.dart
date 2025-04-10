import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:bidmygoldflutter/app/modules/onboarding/controllers/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              // Skip Button
              Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: controller.skipOnboarding,
                  style: TextButton.styleFrom(
                    foregroundColor: const Color(0xFF1A1A1A),
                  ),
                  child: Text(
                    'skip'.tr,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              Expanded(
                // Page View
                child: PageView.builder(
                  controller: controller.pageController,
                  onPageChanged: controller.onPageChanged,
                  itemCount: 3,
                  itemBuilder: (context, index) {
                    IconData icon;
                    Color iconBgColor;
                    
                    // Select icon and background color based on page
                    switch (index) {
                      case 0:
                        icon = Icons.upload_rounded;
                        iconBgColor = const Color(0xFFFFF8E1);
                        break;
                      case 1:
                        icon = Icons.gavel_rounded;
                        iconBgColor = const Color(0xFFF5F5F5);
                        break;
                      case 2:
                        icon = Icons.handshake_rounded;
                        iconBgColor = const Color(0xFFE3F2FD);
                        break;
                      default:
                        icon = Icons.circle;
                        iconBgColor = Colors.grey[100]!;
                    }

                    final page = controller.onboardingPages[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Icon with background
                        Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: iconBgColor,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 64,
                            color: const Color(0xFFFFB800),
                          ),
                        ),
                        const SizedBox(height: 48),
                        Text(
                          page['title']!.tr,
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF1A1A1A),
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          page['description']!.tr,
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: const Color(0xFF757575),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              // Dots Indicator and Next Button
              Padding(
                padding: const EdgeInsets.only(bottom: 20.0, top: 20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Dots
                    Obx(() => Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            controller.onboardingPages.length,
                            (index) => AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: controller.currentPageIndex.value == index
                                  ? 24
                                  : 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: controller.currentPageIndex.value == index
                                    ? const Color(0xFFFFB800)
                                    : const Color(0xFFE0E0E0),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        )),
                    // Next/Done Button
                    Obx(() => ElevatedButton(
                          onPressed: controller.nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFFB800),
                            foregroundColor: Colors.white,
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Text(
                            controller.currentPageIndex.value ==
                                    controller.onboardingPages.length - 1
                                ? 'done'.tr
                                : 'next'.tr,
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
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
