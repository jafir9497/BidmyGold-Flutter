import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/data/models/bid.dart';
import 'package:bidmygoldflutter/app/theme/app_theme.dart';
import '../controllers/bid_details_controller.dart';

class BidDetailsScreen extends GetView<BidDetailsController> {
  const BidDetailsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('bid_details'.tr),
        backgroundColor: AppTheme.gold,
      ),
      body: Obx(() {
        final bid = controller.bidData.value;
        if (bid == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              _buildPawnbrokerInfo(bid),
              const SizedBox(height: 16),
              _buildBidDetails(bid),
              const SizedBox(height: 16),
              _buildComparisonSection(bid),
              const SizedBox(height: 16),
              _buildActionButtons(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildPawnbrokerInfo(Bid bid) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'pawnbroker_info'.tr,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppTheme.gold.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.store,
                  color: AppTheme.gold,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      bid.name ?? '',
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      bid.location ?? '',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(
                Icons.star,
                color: Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                bid.rating?.toString() ?? '0.0',
                style: Get.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.access_time,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                bid.operatingHours ?? '',
                style: Get.textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Icon(
                Icons.phone,
                color: Colors.grey[600],
                size: 20,
              ),
              const SizedBox(width: 4),
              Text(
                bid.contact ?? '',
                style: Get.textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBidDetails(Bid bid) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'bid_details'.tr,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            'loan_amount'.tr,
            '₹${bid.loanAmount?.toStringAsFixed(2) ?? '0.00'}',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'interest_rate'.tr,
            '${bid.interestRate?.toStringAsFixed(1) ?? '0.0'}%',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'loan_tenure'.tr,
            '${bid.tenure ?? 0} ${'months'.tr}',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'monthly_emi'.tr,
            '₹${bid.emi?.toStringAsFixed(2) ?? '0.00'}',
          ),
          const SizedBox(height: 8),
          _buildDetailRow(
            'processing_fee'.tr,
            '₹${bid.processingFee?.toStringAsFixed(2) ?? '0.00'}',
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'status'.tr,
                style: Get.textTheme.bodyLarge,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: bid.status == 'Pending'
                      ? Colors.amber.shade50
                      : Colors.green.shade50,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      bid.status == 'Pending'
                          ? Icons.timer
                          : Icons.check_circle,
                      size: 16,
                      color: bid.status == 'Pending'
                          ? Colors.amber.shade700
                          : Colors.green.shade700,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      bid.status ?? '',
                      style: Get.textTheme.bodyMedium?.copyWith(
                        color: bid.status == 'Pending'
                            ? Colors.amber.shade700
                            : Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (bid.expiresAt != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'expires_in'.tr,
                  style: Get.textTheme.bodyLarge,
                ),
                Text(
                  _getTimeRemaining(bid.expiresAt!),
                  style: Get.textTheme.bodyMedium?.copyWith(
                    color: Colors.red[700],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: Get.textTheme.bodyLarge,
        ),
        Text(
          value,
          style: Get.textTheme.bodyLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getTimeRemaining(DateTime expiresAt) {
    final now = DateTime.now();
    final difference = expiresAt.difference(now);

    if (difference.inHours > 0) {
      return '${difference.inHours}h ${difference.inMinutes.remainder(60)}m';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'Expired';
    }
  }

  Widget _buildComparisonSection(Bid bid) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'bid_comparison'.tr,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildComparisonCard(
                  title: 'interest_rate'.tr,
                  value: '${bid.interestRate?.toStringAsFixed(1) ?? '0.0'}%',
                  comparison: bid.isLowestInterest ?? false ? 'lowest_rate'.tr : 'average_rate'.tr,
                  isPositive: bid.isLowestInterest ?? false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComparisonCard(
                  title: 'loan_amount'.tr,
                  value: '₹${bid.loanAmount?.toStringAsFixed(2) ?? '0.00'}',
                  comparison: bid.isHighestAmount ?? false ? 'highest_offer'.tr : 'average_offer'.tr,
                  isPositive: bid.isHighestAmount ?? false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildComparisonCard(
                  title: 'processing_fee'.tr,
                  value: '₹${bid.processingFee?.toStringAsFixed(2) ?? '0.00'}',
                  comparison: bid.isLowestFee ?? false ? 'lowest_fee'.tr : 'average_fee'.tr,
                  isPositive: bid.isLowestFee ?? false,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildComparisonCard(
                  title: 'monthly_emi'.tr,
                  value: '₹${bid.emi?.toStringAsFixed(2) ?? '0.00'}',
                  comparison: bid.isLowestEmi ?? false ? 'lowest_emi'.tr : 'average_emi'.tr,
                  isPositive: bid.isLowestEmi ?? false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard({
    required String title,
    required String value,
    required String comparison,
    required bool isPositive,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isPositive ? Colors.green : Colors.orange).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: (isPositive ? Colors.green : Colors.orange).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Get.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Get.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isPositive ? Colors.green : Colors.orange,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                isPositive ? Icons.trending_up : Icons.trending_down,
                size: 16,
                color: isPositive ? Colors.green : Colors.orange,
              ),
              const SizedBox(width: 4),
              Text(
                comparison,
                style: Get.textTheme.bodySmall?.copyWith(
                  color: isPositive ? Colors.green : Colors.orange,
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
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: controller.acceptBid,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.gold,
                foregroundColor: AppTheme.dark,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text('accept_bid'.tr),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: controller.rejectBid,
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'reject_bid'.tr,
                style: TextStyle(
                  color: Colors.red[700],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
