import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../controllers/payment_history_controller.dart';

class PaymentHistoryScreen extends GetView<PaymentHistoryController> {
  const PaymentHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment History'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh History',
            onPressed: () => controller.fetchPaymentHistory(isRefresh: true),
          ),
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
                  child: Text('Error: ${controller.errorMessage.value}')));
        }
        if (controller.paymentLogs.isEmpty) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('No payment history found.'),
          ));
        }
        return ListView.separated(
          padding: const EdgeInsets.all(8.0),
          itemCount: controller.paymentLogs.length,
          itemBuilder: (context, index) {
            final log = controller.paymentLogs[index];
            return _buildLogItem(log);
          },
          separatorBuilder: (context, index) => const Divider(height: 1),
        );
      }),
    );
  }

  Widget _buildLogItem(PaymentLog log) {
    final isSuccess = log.status == 'success';
    final titleStyle = Get.textTheme.titleMedium?.copyWith(
      fontWeight: FontWeight.w500,
    );
    final subtitleStyle =
        Get.textTheme.bodySmall?.copyWith(color: Colors.grey[600]);

    return ListTile(
      leading: Icon(
        isSuccess ? Icons.check_circle : Icons.error,
        color: isSuccess ? Colors.green : Colors.red,
        size: 30,
      ),
      title: Text(
        isSuccess ? 'Payment Successful' : 'Payment Failed',
        style:
            titleStyle?.copyWith(color: isSuccess ? Colors.green : Colors.red),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Date: ${controller.formatTimestamp(log.timestamp)}',
              style: subtitleStyle),
          if (log.paymentId != null)
            Text('Payment ID: ${log.paymentId}', style: subtitleStyle),
          if (log.orderId != null)
            Text('Order ID: ${log.orderId}', style: subtitleStyle),
          if (!isSuccess && log.errorMessage != null)
            Text('Details: ${log.errorMessage}',
                style: subtitleStyle?.copyWith(color: Colors.red[700])),
        ],
      ),
      // isThreeLine: !isSuccess && log.errorMessage != null, // Adjust layout if error message is long
      dense: true,
    );
  }
}
