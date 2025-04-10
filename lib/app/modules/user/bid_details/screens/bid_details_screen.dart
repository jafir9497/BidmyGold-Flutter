import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bid_details_controller.dart';
import 'package:intl/intl.dart';

class BidDetailsScreen extends GetView<BidDetailsController> {
  const BidDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bid_details'.tr),
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildPawnbrokerInfoSection(),
              const SizedBox(height: 16),
              _buildBidDetailsSection(),
              const SizedBox(height: 16),
              _buildComparisonSection(),
              const SizedBox(height: 24),
              _buildActionButtons(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPawnbrokerInfoSection() {
    final pawnbroker = controller.pawnbrokerData;
    final shopName = pawnbroker['shopName'] ?? 'Unknown Shop';
    final ownerName = pawnbroker['ownerName'] ?? '';
    final address = pawnbroker['address'] ?? '';
    final city = pawnbroker['city'] ?? '';
    final state = pawnbroker['state'] ?? '';
    final pinCode = pawnbroker['pinCode'] ?? '';
    final rating = pawnbroker['rating'] ?? 0.0;
    final reviewCount = pawnbroker['reviewCount'] ?? 0;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      color: Get.theme.colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: Get.theme.colorScheme.primary.withOpacity(0.1),
                child: Icon(
                  Icons.store,
                  size: 30,
                  color: Get.theme.colorScheme.primary,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shopName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (ownerName.isNotEmpty)
                      Text(
                        ownerName,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    const SizedBox(height: 4),
                    if (rating > 0)
                      Row(
                        children: [
                          const Icon(
                            Icons.star,
                            size: 16,
                            color: Colors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '$rating',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '($reviewCount ${'reviews'.tr})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey.shade700,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (address.isNotEmpty || city.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.location_on,
                    size: 18,
                    color: Colors.grey.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      [
                        if (address.isNotEmpty) address,
                        if (city.isNotEmpty && state.isNotEmpty)
                          '$city, $state',
                        if (pinCode.isNotEmpty) pinCode,
                      ].join(', '),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade800,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBidDetailsSection() {
    final bid = controller.bidData;
    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );

    final offeredAmount = bid['offeredAmount'] ?? 0.0;
    final interestRate = bid['interestRate'] ?? 0.0;
    final loanTenure = bid['loanTenure'] ?? 6;
    final note = bid['note'] ?? '';

    // Calculate monthly payment
    final principal = offeredAmount;
    final monthlyRate = interestRate / 100 / 12;
    final monthlyPayment = controller.calculateMonthlyPayment(
      principal,
      monthlyRate,
      loanTenure,
    );

    // Calculate total interest
    final totalPayment = monthlyPayment * loanTenure;
    final totalInterest = totalPayment - principal;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade300,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'bid_offer'.tr,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'offered_amount'.tr,
            currencyFormat.format(offeredAmount),
            highlight: true,
          ),
          _buildDetailRow(
            'interest_rate'.tr,
            '${interestRate.toStringAsFixed(1)}%',
          ),
          _buildDetailRow(
            'loan_tenure'.tr,
            '$loanTenure ${'months'.tr}',
          ),
          _buildDetailRow(
            'monthly_payment'.tr,
            currencyFormat.format(monthlyPayment),
          ),
          _buildDetailRow(
            'total_interest'.tr,
            currencyFormat.format(totalInterest),
          ),
          _buildDetailRow(
            'total_repayment'.tr,
            currencyFormat.format(totalPayment),
          ),
          if (note.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(
              'note_from_pawnbroker'.tr,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Text(
                note,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildComparisonSection() {
    final loanRequest = controller.loanRequestData;
    final bid = controller.bidData;

    final requestedAmount = loanRequest['loanAmount'] ?? 0.0;
    final offeredAmount = bid['offeredAmount'] ?? 0.0;

    final difference = offeredAmount - requestedAmount;
    final differencePercent = (difference / requestedAmount) * 100;

    final currencyFormat = NumberFormat.currency(
      symbol: '₹',
      decimalDigits: 0,
    );

    if (difference == 0) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: difference > 0 ? Colors.green.shade50 : Colors.amber.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: difference > 0 ? Colors.green.shade200 : Colors.amber.shade200,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            difference > 0
                ? 'bid_higher_than_requested'.tr
                : 'bid_lower_than_requested'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: difference > 0
                  ? Colors.green.shade700
                  : Colors.amber.shade700,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'requested_amount'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(requestedAmount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'offered_amount'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      currencyFormat.format(offeredAmount),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'difference'.tr,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${difference > 0 ? '+' : ''}${currencyFormat.format(difference)} (${differencePercent.toStringAsFixed(1)}%)',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: difference > 0
                            ? Colors.green.shade700
                            : Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Obx(() => ElevatedButton(
                onPressed: controller.isAccepting.value
                    ? null
                    : () => controller.acceptBid(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: controller.isAccepting.value
                    ? const CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      )
                    : Text(
                        'accept_bid'.tr,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              )),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: () => Get.back(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: Text(
              'back_to_bids'.tr,
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool highlight = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: highlight ? Get.theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }
}
