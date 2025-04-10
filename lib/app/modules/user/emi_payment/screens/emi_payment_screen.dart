import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/emi_payment_controller.dart';

class EmiPaymentScreen extends GetView<EmiPaymentController> {
  const EmiPaymentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('EMI Payments'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Loan Details',
            onPressed: () => controller.fetchLoanAndEmiDetails(isRefresh: true),
          )
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.errorMessage.value.isNotEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text('Error: ${controller.errorMessage.value}'),
            ),
          );
        }
        if (controller.activeLoan.value == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(20.0),
              child: Text('No active loan found.'),
            ),
          );
        }
        return _buildLoanDetailsView();
      }),
    );
  }

  Widget _buildLoanDetailsView() {
    final loan = controller.activeLoan.value!;
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Loan Summary Card
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            elevation: 2,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Loan Summary (ID: ${loan['id'] ?? 'N/A'})',
                      style: Get.textTheme.titleLarge
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const Divider(height: 20),
                  _buildSummaryRow('Principal Amount',
                      currencyFormat.format(loan['principalAmount'] ?? 0.0)),
                  _buildSummaryRow(
                      'Interest Rate', '${loan['interestRate'] ?? 'N/A'}%'),
                  _buildSummaryRow(
                      'Tenure', '${loan['tenureMonths'] ?? 'N/A'} months'),
                  _buildSummaryRow('EMI Amount',
                      currencyFormat.format(loan['emiAmount'] ?? 0.0)),
                  // Add more relevant loan summary fields if needed
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Text('EMI Schedule',
              style: Get.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.bold)),
        ),
        // EMI List
        Expanded(
          child: Obx(() {
            if (controller.emiSchedule.isEmpty) {
              return const Center(child: Text('No EMI schedule found.'));
            }
            return ListView.builder(
              itemCount: controller.emiSchedule.length,
              itemBuilder: (context, index) {
                final emi = controller.emiSchedule[index];
                return _buildEmiListItem(emi);
              },
            );
          }),
        ),
      ],
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: Get.textTheme.bodyMedium),
          Text(value,
              style: Get.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildEmiListItem(EmiData emi) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final isDue = emi.status == 'due' || emi.status == 'overdue';
    final isPaid = emi.status == 'paid';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPaid
              ? Colors.green
              : (isDue ? Colors.orange : Colors.grey.shade300),
          child: Text(
            emi.emiNumber.toString(),
            style: TextStyle(
                color: isPaid || isDue ? Colors.white : Colors.grey.shade700,
                fontWeight: FontWeight.bold),
          ),
        ),
        title: Text('EMI Amount: ${currencyFormat.format(emi.amount)}'),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Due Date: ${controller.formatDate(emi.dueDate)}'),
            Text('Status: ${emi.status.capitalizeFirst ?? emi.status}',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isPaid
                        ? Colors.green
                        : (isDue ? Colors.orange : Colors.grey.shade700))),
            if (isPaid && emi.paidDate != null)
              Text('Paid on: ${controller.formatDate(emi.paidDate)}'),
            if (isPaid && emi.paymentId != null)
              Text('Payment ID: ${emi.paymentId}',
                  style: Get.textTheme.labelSmall),
          ],
        ),
        trailing: isPaid
            ? // Show download button if paid
            Obx(() => IconButton(
                  icon: controller.isGeneratingReceipt.value
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2))
                      : const Icon(Icons.download_for_offline,
                          color: Colors.blue),
                  tooltip: 'Download Receipt',
                  onPressed: controller.isGeneratingReceipt.value
                      ? null
                      : () => controller.downloadReceipt(emi),
                ))
            : (isDue
                ? // Show Pay Now button if due
                Obx(() => ElevatedButton(
                      onPressed: controller.isPaymentProcessing.value
                          ? null // Disable button while processing
                          : () => controller.initiateEmiPayment(emi),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                      ),
                      child: controller.isPaymentProcessing.value
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                  strokeWidth: 2, color: Colors.white))
                          : const Text('Pay Now'),
                    ))
                : null // No button if upcoming/other status
            ),
      ),
    );
  }
}
