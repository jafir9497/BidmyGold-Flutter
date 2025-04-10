import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/theme/app_theme.dart';
import '../controllers/anonymous_home_controller.dart';

class AnonymousHomeScreen extends GetView<AnonymousHomeController> {
  const AnonymousHomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'app_name'.tr,
                    style: Get.textTheme.headlineSmall?.copyWith(
                      color: AppTheme.dark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: controller.navigateToLogin,
                    icon: const Icon(Icons.login, color: AppTheme.gold),
                    label: Text(
                      'login'.tr,
                      style: Get.textTheme.bodyLarge?.copyWith(
                        color: AppTheme.gold,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'home_title'.tr,
                style: Get.textTheme.titleLarge?.copyWith(
                  color: AppTheme.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'home_subtitle'.tr,
                style: Get.textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              _buildHowItWorks(),
              const SizedBox(height: 32),
              _buildFeatures(),
              const SizedBox(height: 32),
              Text(
                'gold_calculator'.tr,
                style: Get.textTheme.titleLarge?.copyWith(
                  color: AppTheme.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: controller.weightController,
                            keyboardType: const TextInputType.numberWithOptions(decimal: true),
                            onChanged: controller.calculateLoan,
                            decoration: InputDecoration(
                              labelText: 'weight_of_gold'.tr,
                              suffixText: 'grams'.tr,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        DropdownButton<String>(
                          value: controller.selectedGoldType.value,
                          items: controller.goldTypes
                              .map((type) => DropdownMenuItem(
                                    value: type,
                                    child: Text(type),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            if (value != null) {
                              controller.selectedGoldType.value = value;
                              controller.calculateLoan(
                                  controller.weightController.text);
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'current_gold_rate'.tr,
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.dark,
                          ),
                        ),
                        Obx(() => Text(
                              '₹${controller.getCurrentRate().toStringAsFixed(2)}/g',
                              style: Get.textTheme.bodyLarge?.copyWith(
                                color: AppTheme.gold,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'estimated_gold_value'.tr,
                          style: Get.textTheme.bodyMedium?.copyWith(
                            color: AppTheme.dark,
                          ),
                        ),
                        Obx(() => Text(
                              '₹${(controller.getCurrentRate() * (double.tryParse(controller.weightController.text ?? '0') ?? 0.0)).toStringAsFixed(2)}',
                              style: Get.textTheme.bodyLarge?.copyWith(
                                color: AppTheme.gold,
                                fontWeight: FontWeight.bold,
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'loan_calculator'.tr,
                style: Get.textTheme.titleLarge?.copyWith(
                  color: AppTheme.dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: controller.requiredLoanController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                onChanged: controller.updateRequiredLoan,
                decoration: InputDecoration(
                  labelText: 'required_loan_amount'.tr,
                  errorText: controller.isValidLoanAmount.value ? null : 'amount_exceeds_limit'.tr,
                  prefixText: '₹',
                ),
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'loan_tenure'.tr,
                        style: Get.textTheme.bodyLarge,
                      ),
                      Obx(() => Text(
                            controller.getTenureDisplay(),
                            style: Get.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Slider(
                        value: controller.selectedTenure.value,
                        min: controller.tenureOptions.first,
                        max: controller.tenureOptions.last,
                        divisions: controller.tenureOptions.length - 1,
                        activeColor: AppTheme.gold,
                        inactiveColor: AppTheme.gold.withOpacity(0.3),
                        onChanged: controller.updateTenure,
                      )),
                ],
              ),
              const SizedBox(height: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'interest_rate'.tr,
                        style: Get.textTheme.bodyLarge,
                      ),
                      Obx(() => Text(
                            controller.getInterestDisplay(),
                            style: Get.textTheme.bodyLarge?.copyWith(
                              color: AppTheme.gold,
                              fontWeight: FontWeight.bold,
                            ),
                          )),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Obx(() => Slider(
                        value: controller.selectedInterest.value,
                        min: controller.interestOptions.first,
                        max: controller.interestOptions.last,
                        divisions: controller.interestOptions.length - 1,
                        activeColor: AppTheme.gold,
                        inactiveColor: AppTheme.gold.withOpacity(0.3),
                        onChanged: controller.updateInterest,
                      )),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'monthly_emi'.tr,
                          style: Get.textTheme.bodyLarge,
                        ),
                        Obx(() => Text(
                              controller.monthlyEmi.value > 0
                                  ? '₹${controller.monthlyEmi.value.toStringAsFixed(2)}'
                                  : '₹0.00',
                              style: Get.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.gold,
                              ),
                            )),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'total_interest'.tr,
                          style: Get.textTheme.bodyLarge,
                        ),
                        Obx(() => Text(
                              controller.totalInterest.value > 0
                                  ? '₹${controller.totalInterest.value.toStringAsFixed(2)}'
                                  : '₹0.00',
                              style: Get.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.gold,
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: Obx(() => ElevatedButton(
                      onPressed: controller.canProceed.value
                          ? controller.navigateToLogin
                          : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.canProceed.value
                            ? AppTheme.gold
                            : Colors.grey[300],
                        foregroundColor: controller.canProceed.value
                            ? AppTheme.dark
                            : Colors.grey[600],
                      ),
                      child: Text('get_started'.tr),
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHowItWorks() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'how_it_works'.tr,
          style: Get.textTheme.titleLarge?.copyWith(
            color: AppTheme.dark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'how_it_works_desc'.tr,
          style: Get.textTheme.bodyLarge?.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),
        _buildStepCard(
          step: 1,
          icon: Icons.calculate,
          title: 'step_1_title'.tr,
          description: 'step_1_desc'.tr,
        ),
        const SizedBox(height: 16),
        _buildStepCard(
          step: 2,
          icon: Icons.upload_file,
          title: 'step_2_title'.tr,
          description: 'step_2_desc'.tr,
        ),
        const SizedBox(height: 16),
        _buildStepCard(
          step: 3,
          icon: Icons.gavel,
          title: 'step_3_title'.tr,
          description: 'step_3_desc'.tr,
        ),
        const SizedBox(height: 16),
        _buildStepCard(
          step: 4,
          icon: Icons.account_balance_wallet,
          title: 'step_4_title'.tr,
          description: 'step_4_desc'.tr,
        ),
      ],
    );
  }

  Widget _buildStepCard({
    required int step,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: AppTheme.gold,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Center(
              child: Text(
                step.toString(),
                style: Get.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.gold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeatures() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildFeatureCard(
          icon: Icons.speed,
          title: 'quick_processing_title'.tr,
          description: 'quick_processing_desc'.tr,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.security,
          title: 'secure_trusted_title'.tr,
          description: 'secure_trusted_desc'.tr,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.currency_rupee,
          title: 'best_rates_title'.tr,
          description: 'best_rates_desc'.tr,
        ),
        const SizedBox(height: 16),
        _buildFeatureCard(
          icon: Icons.home,
          title: 'doorstep_title'.tr,
          description: 'doorstep_desc'.tr,
        ),
      ],
    );
  }

  Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.gold.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.gold),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
