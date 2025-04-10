import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/pawnbroker_place_bid_controller.dart';
import 'package:intl/intl.dart';

class PawnbrokerPlaceBidScreen extends GetView<PawnbrokerPlaceBidController> {
  const PawnbrokerPlaceBidScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(controller.isEditMode ? 'edit_bid'.tr : 'place_bid'.tr),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: controller.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildLoanRequestInfoCard(),
                const SizedBox(height: 20),
                _buildBidDetailsCard(),
                const SizedBox(height: 30),
                _buildSubmitButton(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildLoanRequestInfoCard() {
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );

    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'loan_request_details'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildDetailRow(
              'requested_amount'.tr,
              currencyFormat
                  .format(controller.loanRequestData['loanAmount'] ?? 0),
            ),
            _buildDetailRow(
              'gold_weight'.tr,
              '${controller.loanRequestData['jewelWeight'] ?? 0} ${'grams'.tr}',
            ),
            _buildDetailRow(
              'gold_purity'.tr,
              '${controller.loanRequestData['jewelPurity'] ?? '22K'}',
            ),
            _buildDetailRow(
              'user_name'.tr,
              controller.userData['name'] ?? 'N/A',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBidDetailsCard() {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'your_bid'.tr,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'offer_amount'.tr,
                prefixText: '₹',
                border: const OutlineInputBorder(),
              ),
              validator: (value) => controller.validateAmount(value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.interestRateController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'interest_rate'.tr,
                suffixText: '%',
                border: const OutlineInputBorder(),
              ),
              validator: (value) => controller.validateInterestRate(value),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              value: controller.selectedTenure.value,
              decoration: InputDecoration(
                labelText: 'loan_tenure'.tr,
                border: const OutlineInputBorder(),
              ),
              items: controller.tenureOptions.map((tenure) {
                return DropdownMenuItem<int>(
                  value: tenure,
                  child: Text('$tenure ${'months'.tr}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  controller.selectedTenure.value = value;
                }
              },
              validator: (value) => controller.validateTenure(value),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: controller.noteController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'additional_note'.tr,
                hintText: 'optional_note_hint'.tr,
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    return Obx(() {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: controller.isSubmitting.value
              ? null
              : () => controller.submitBid(),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: controller.isSubmitting.value
              ? const CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                )
              : Text(
                  controller.isEditMode ? 'update_bid'.tr : 'submit_bid'.tr,
                  style: const TextStyle(fontSize: 16),
                ),
        ),
      );
    });
  }
}
