import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/calculator/controllers/calculator_controller.dart';
import 'package:bidmygoldflutter/app/modules/home/controllers/anonymous_home_controller.dart';
import 'package:intl/intl.dart'; // For number formatting

class GoldLoanCalculatorWidget extends StatelessWidget {
  // Inject controller or find it if already initialized globally/in parent binding
  final CalculatorController controller = Get.put(CalculatorController());
  // final CalculatorController controller = Get.find<CalculatorController>(); // Use this if bound elsewhere
  final bool
      showProceedButton; // Option to show proceed button (for Anonymous Home)

  GoldLoanCalculatorWidget({super.key, this.showProceedButton = false});

  final NumberFormat currencyFormat = NumberFormat.currency(
      locale: 'en_IN', symbol: '₹', decimalDigits: 0); // Indian Rupee format

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Input Row 1: Weight & Purity
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Weight Input
            Expanded(
              child: TextField(
                controller: controller.weightController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$')),
                ],
                decoration: InputDecoration(
                  labelText: 'gold_weight_grams'.tr,
                ),
                onChanged: (_) => controller.resetCalculation(),
              ),
            ),
            const SizedBox(width: 16),
            // Purity Dropdown
            Expanded(
              child: Obx(() => DropdownButtonFormField<String>(
                    value: controller.selectedPurity.value,
                    items: controller.purityList
                        .map((purity) => DropdownMenuItem(
                              value: purity,
                              child: Text(purity),
                            ))
                        .toList(),
                    onChanged: controller.onPurityChanged,
                    decoration: InputDecoration(
                      labelText: 'gold_purity'.tr,
                    ),
                  )),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Input Row 2: Required Amount
        TextField(
          controller: controller.amountController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: 'required_loan_amount_optional'.tr,
            prefixText: '₹ ',
          ),
          onChanged: (_) => controller.resetCalculation(),
        ),

        const SizedBox(height: 20),

        // Calculate Button
        ElevatedButton(
          onPressed: controller.calculateLoan,
          child: Text('calculate_loan'.tr),
        ),
        const SizedBox(height: 5),
        TextButton(
          onPressed: controller.clearForm,
          child: Text('clear_form'.tr),
        ),

        const SizedBox(height: 20),
        
        // Results Section
        Obx(() {
          if (!controller.calculationDone.value) {
            return const SizedBox.shrink();
          }
          
          return Card(
            color: theme.colorScheme.secondaryContainer.withOpacity(0.5),
            elevation: 0,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('results'.tr, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 10),
                  Obx(() {
                    if (controller.knowPurity.value &&
                        controller.estimatedMaxValue.value > 0) {
                      return _buildResultRow(
                        'max_loan_value'.tr,
                        currencyFormat.format(controller.estimatedMaxValue.value),
                      );
                    }
                    return const SizedBox.shrink();
                  }),
                  _buildResultRow(
                    'eligible_loan_amount'.tr,
                    currencyFormat.format(controller.calculatedLoanAmount.value),
                  ),
                  _buildResultRow(
                    'estimated_monthly_emi'.tr,
                    currencyFormat.format(controller.estimatedEmi.value),
                  ),
                  const SizedBox(height: 5),
                  Text('emi_note'.tr, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          );
        }),

        // Optional Proceed Button
        if (showProceedButton)
          Padding(
            padding: const EdgeInsets.only(top: 20.0),
            child: Obx(() => ElevatedButton(
                  onPressed: controller.calculationDone.value &&
                          controller.calculatedLoanAmount.value > 0
                      ? () => Get.find<AnonymousHomeController>().navigateToLogin()
                      : null,
                  child: Text('get_estimate_cta'.tr),
                )),
          ),
      ],
    );
  }

  Widget _buildResultRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label.tr, style: Get.textTheme.bodyLarge),
          Text(value,
              style: Get.textTheme.bodyLarge
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
