import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/pawnbroker/dashboard/controllers/pawnbroker_dashboard_controller.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart';

class PawnbrokerDashboardScreen extends GetView<PawnbrokerDashboardController> {
  const PawnbrokerDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshData,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildProfileSection(),
              const SizedBox(height: 24),
              _buildLoanRequestsSection(),
              const SizedBox(height: 24),
              _buildBidsHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileSection() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      return Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          controller.shopName.value,
                          style: Get.textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          controller.ownerName.value,
                          style: Get.textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                  _buildVerificationBadge(controller.verificationStatus.value),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                controller.address.value,
                style: Get.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),

              // Status specific content based on verification status
              _buildVerificationContent(),

              const SizedBox(height: 16),

              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to edit profile
                      },
                      icon: const Icon(Icons.edit),
                      label: Text('edit_profile'.tr),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (controller.verificationStatus.value != 'verified')
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          // Navigate to verification documents reupload
                        },
                        icon: const Icon(Icons.upload_file),
                        label: Text(
                          controller.verificationStatus.value == 'rejected'
                              ? 'resubmit_documents'.tr
                              : 'update_documents'.tr,
                        ),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          backgroundColor:
                              controller.verificationStatus.value == 'rejected'
                                  ? Colors.red
                                  : null,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildVerificationBadge(String status) {
    Color color;
    IconData icon;
    String text;

    switch (status) {
      case 'verified':
        color = Colors.green;
        icon = Icons.verified;
        text = 'verified'.tr;
        break;
      case 'rejected':
        color = Colors.red;
        icon = Icons.cancel;
        text = 'rejected'.tr;
        break;
      case 'pending':
      default:
        color = Colors.orange;
        icon = Icons.pending;
        text = 'pending'.tr;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
                color: color, fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationContent() {
    switch (controller.verificationStatus.value) {
      case 'verified':
        return _buildVerifiedContent();
      case 'rejected':
        return _buildRejectedContent();
      case 'pending':
      default:
        return _buildPendingContent();
    }
  }

  Widget _buildVerifiedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Your shop has been verified. You can now view loan requests and submit bids.',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ElevatedButton.icon(
          onPressed: () => Get.toNamed(Routes.PAWNBROKER_QR_SCANNER),
          icon: const Icon(Icons.qr_code_scanner),
          label: const Text('Scan User QR Code'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.teal,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 45),
          ),
        ),
      ],
    );
  }

  Widget _buildRejectedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Your shop verification was rejected. Please check the issues below and resubmit your documents.',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Text(
            controller.rejectionReason.value.isNotEmpty
                ? controller.rejectionReason.value
                : 'The submitted documents need further verification. Please ensure all uploaded documents are clear, current, and valid.',
            style: TextStyle(color: Colors.red[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildPendingContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        Row(
          children: [
            Icon(Icons.access_time, color: Colors.orange[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Your shop verification is in progress. This typically takes 24-48 hours to complete.',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LinearProgressIndicator(
          value: null, // Indeterminate
          backgroundColor: Colors.orange[100],
          valueColor: AlwaysStoppedAnimation<Color>(Colors.orange[700]!),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'We\'ll notify you once the verification is complete',
            style: TextStyle(
              color: Colors.orange[700],
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoanRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'nearby_loan_requests'.tr,
              style: Get.textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // Navigate to all loan requests
              },
              child: Text('view_all'.tr),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoadingRequests.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.loanRequests.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.search_off,
                          size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'no_loan_requests_found'.tr,
                        style: Get.textTheme.titleMedium
                            ?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.loanRequests.length,
            itemBuilder: (context, index) {
              final request = controller.loanRequests[index];
              return _buildLoanRequestCard(request);
            },
          );
        }),
      ],
    );
  }

  Widget _buildLoanRequestCard(Map<String, dynamic> request) {
    final currencyFormat =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final timestamp = request['createdAt'] as Timestamp;
    final date = timestamp.toDate();
    final formattedDate = DateFormat('dd MMM yyyy').format(date);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  request['jewelType'] ?? 'Unknown Jewel',
                  style: Get.textTheme.titleMedium,
                ),
                Text(
                  formattedDate,
                  style: Get.textTheme.bodySmall,
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'weight'.tr + ': ${request['jewelWeight']} g',
                      style: Get.textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'requested_amount'.tr +
                          ': ' +
                          currencyFormat.format(request['requestedAmount']),
                      style: Get.textTheme.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const Spacer(),
                _buildPhotoCount(request['photos'] as List),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton(
                  onPressed: () =>
                      controller.viewLoanRequestDetails(request['id']),
                  child: Text('view_details'.tr),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => controller.submitBid(request['id']),
                  child: Text('place_bid'.tr),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotoCount(List photos) {
    return Row(
      children: [
        const Icon(Icons.photo_library, size: 16, color: Colors.grey),
        const SizedBox(width: 4),
        Text(
          '${photos.length} ${'photos'.tr}',
          style: const TextStyle(color: Colors.grey),
        ),
      ],
    );
  }

  Widget _buildBidsHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'my_bids'.tr,
              style: Get.textTheme.titleLarge,
            ),
            TextButton(
              onPressed: () {
                // Navigate to all bids history
              },
              child: Text('view_all'.tr),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Obx(() {
          if (controller.isLoadingBids.value) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (controller.bidsHistory.isEmpty) {
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    children: [
                      const Icon(Icons.history, size: 48, color: Colors.grey),
                      const SizedBox(height: 16),
                      Text(
                        'no_bids_yet'.tr,
                        style: Get.textTheme.titleMedium
                            ?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            );
          }

          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: controller.bidsHistory.length > 3
                ? 3
                : controller.bidsHistory.length,
            itemBuilder: (context, index) {
              final bid = controller.bidsHistory[index];
              return _buildBidCard(bid);
            },
          );
        }),
      ],
    );
  }

  Widget _buildBidCard(Map<String, dynamic> bid) {
    final currencyFormat =
        NumberFormat.currency(locale: 'en_IN', symbol: '₹', decimalDigits: 0);
    final timestamp = bid['createdAt'] as Timestamp;
    final date = timestamp.toDate();
    final formattedDate = DateFormat('dd MMM yyyy').format(date);

    // Determine status color and icon
    Color statusColor;
    IconData statusIcon;

    switch (bid['status']) {
      case 'accepted':
        statusColor = Colors.green;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = Colors.red;
        statusIcon = Icons.cancel;
        break;
      case 'pending':
      default:
        statusColor = Colors.orange;
        statusIcon = Icons.pending;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: () => controller.viewBidDetails(bid['id']),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    currencyFormat.format(bid['offeredAmount']),
                    style: Get.textTheme.titleMedium,
                  ),
                  Row(
                    children: [
                      Icon(statusIcon, size: 16, color: statusColor),
                      const SizedBox(width: 4),
                      Text(
                        bid['status'].tr,
                        style: TextStyle(color: statusColor),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'interest_rate'.tr + ': ${bid['interestRate']}%',
                    style: Get.textTheme.bodyMedium,
                  ),
                  Text(
                    formattedDate,
                    style: Get.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
