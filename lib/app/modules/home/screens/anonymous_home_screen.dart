import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/home/controllers/anonymous_home_controller.dart';
import 'package:bidmygoldflutter/app/modules/calculator/widgets/gold_loan_calculator_widget.dart';

class AnonymousHomeScreen extends GetView<AnonymousHomeController> {
  const AnonymousHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('app_title'.tr),
        actions: [
          TextButton(
            onPressed: controller.navigateToLogin,
            child: Text('login_register'.tr,
                style: TextStyle(
                    color: Theme.of(context).appBarTheme.foregroundColor)),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Section: App Explanation/Process
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('how_it_works'.tr, style: Get.textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Text('how_it_works_desc'.tr),
                    // Could add steps or icons here
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Section: Gold Loan Estimator
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('loan_estimator'.tr, style: Get.textTheme.titleLarge),
                    const SizedBox(height: 10),
                    Text('estimator_desc'.tr),
                    const SizedBox(height: 15),
                    // --- Replace Placeholder with Actual Widget ---
                    GoldLoanCalculatorWidget(showProceedButton: true),
                    // --- End Replacement ---
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Optional Bottom CTA
            //  ElevatedButton(
            //    onPressed: controller.navigateToLogin,
            //    child: Text('get_started_now'.tr),
            //  ),
          ],
        ),
      ),
    );
  }
}
