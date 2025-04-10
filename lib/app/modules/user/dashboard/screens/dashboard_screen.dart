import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/user/dashboard/controllers/dashboard_controller.dart';
import 'package:bidmygoldflutter/app/routes/app_pages.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DashboardScreen extends GetView<DashboardController> {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('dashboard'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            tooltip: 'Notifications',
            onPressed: () => Get.toNamed(Routes.NOTIFICATIONS),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: controller.refreshData,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: controller.signOut,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: controller.refreshData,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // User Profile Section
                _buildProfileSection(),
                const SizedBox(height: 24),

                // KYC Status Section
                _buildKycStatusSection(),
                const SizedBox(height: 24),

                // Loan Requests Section
                _buildLoanRequestsSection(),

                // EMI Payment Section Card
                _buildEmiPaymentCard(),
                const SizedBox(height: 16),

                // Payment History Section Card
                _buildPaymentHistoryCard(),
                const SizedBox(height: 16),

                // Send Feedback Button
                Center(
                  child: TextButton(
                    onPressed: () => Get.toNamed(Routes.FEEDBACK),
                    child: const Text('Send App Feedback'),
                  ),
                ),
                const SizedBox(height: 20),

                // Placeholder for other dashboard items (e.g., Recent Activity)
                // ...
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: controller.createNewLoanRequest,
        child: const Icon(Icons.add),
        tooltip: 'new_loan_request'.tr,
      ),
    );
  }

  Widget _buildProfileSection() {
    return Obx(() => Card(
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
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.grey[200],
                      child: Icon(
                        Icons.person,
                        size: 30,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            controller.userName.value.isNotEmpty
                                ? controller.userName.value
                                : 'user'.tr,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            controller.userPhone.value.isNotEmpty
                                ? controller.userPhone.value
                                : '',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                          if (controller.userEmail.value.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              controller.userEmail.value,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Navigate to profile edit screen
                        // TODO: Implement profile edit screen
                        Get.toNamed(Routes.USER_DETAILS);
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ));
  }

  Widget _buildKycStatusSection() {
    return Obx(() {
      Color statusColor;
      IconData statusIcon;
      String statusText;
      String actionText;

      // Determine status display elements
      switch (controller.kycStatus.value) {
        case 'verified':
          statusColor = Colors.green;
          statusIcon = Icons.verified_user;
          statusText = 'kyc_verified'.tr;
          actionText = ''; // No action needed
          break;
        case 'rejected':
          statusColor = Colors.red;
          statusIcon = Icons.cancel;
          statusText = 'kyc_rejected'.tr;
          actionText = 'resubmit_kyc'.tr;
          break;
        case 'pending':
        default:
          statusColor = Colors.orange;
          statusIcon = Icons.pending;
          statusText = 'kyc_pending'.tr;
          actionText = 'update_kyc'.tr;
          break;
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
                  Text(
                    'kyc_status'.tr,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: statusColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          statusIcon,
                          color: statusColor,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Status specific content
              if (controller.kycStatus.value == 'verified')
                _buildVerifiedContent()
              else if (controller.kycStatus.value == 'rejected')
                _buildRejectedContent()
              else
                _buildPendingContent(),

              const SizedBox(height: 16),

              // Action button if needed
              if (controller.kycStatus.value != 'verified')
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Get.toNamed(Routes.KYC_UPLOAD);
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(actionText),
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildVerifiedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Your identity and address have been verified. You can now request loans and receive bids from pawnbrokers.',
                style: TextStyle(color: Colors.grey[700]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        // QR Code placeholder (to be implemented)
        Container(
          alignment: Alignment.center,
          child: Column(
            children: [
              Icon(Icons.qr_code, size: 80, color: Colors.grey[600]),
              const SizedBox(height: 8),
              Text(
                'Your Verification QR Code',
                style: TextStyle(
                    color: Colors.grey[600], fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRejectedContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.error, color: Colors.red, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Your KYC verification was rejected. Please check the following issues and resubmit your documents.',
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
            controller.kycRejectionReason.value.isNotEmpty
                ? controller.kycRejectionReason.value
                : 'The submitted documents were not clear or valid. Please ensure all uploaded documents are clear, current, and match your profile details.',
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
        Row(
          children: [
            Icon(Icons.access_time, color: Colors.orange[700], size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Your KYC verification is in progress. This typically takes 24-48 hours to complete.',
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
    return Obx(() {
      if (controller.isLoadingRequests.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.hasError.value) {
        return Center(
          child: Column(
            children: [
              Text(controller.errorMessage.value),
              ElevatedButton(
                onPressed: controller.loadLoanRequests,
                child: Text('retry'.tr),
              ),
            ],
          ),
        );
      }

      if (controller.loanRequests.isEmpty) {
        return _buildEmptyLoanRequests();
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'loan_requests'.tr,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...controller.loanRequests
              .map((request) => _buildLoanRequestCard(request)),
        ],
      );
    });
  }

  Widget _buildEmptyLoanRequests() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment_outlined,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'no_loan_requests'.tr,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'create_first_loan_request'.tr,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: controller.createNewLoanRequest,
            icon: const Icon(Icons.add),
            label: Text('new_loan_request'.tr),
          ),
        ],
      ),
    );
  }

  Widget _buildLoanRequestCard(Map<String, dynamic> request) {
    // Get status
    final status = request['status'] as String? ?? 'pending';
    final Color statusColor = _getStatusColor(status);
    final createdAt = (request['createdAt'] as Timestamp?)?.toDate();
    final formattedDate = createdAt != null
        ? DateFormat('MMM dd, yyyy').format(createdAt)
        : 'Unknown date';

    // Get loan amount
    final loanAmount = request['loanAmount'] as num? ?? 0;
    final formattedAmount = NumberFormat.currency(
      symbol: '₹',
      locale: 'en_IN',
      decimalDigits: 0,
    ).format(loanAmount);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => controller.viewLoanRequest(request['id'] as String),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Jewel type
                  Text(
                    request['jewelType'] as String? ?? 'Unknown jewel',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  // Status chip
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: statusColor, width: 1),
                    ),
                    child: Text(
                      _getStatusText(status),
                      style: TextStyle(
                        color: statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Loan amount and date
              Row(
                children: [
                  RichText(
                    text: TextSpan(
                      style: DefaultTextStyle.of(Get.context!).style,
                      children: [
                        TextSpan(
                          text: '${request['jewelWeight']}g ',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: request['jewelPurity'] as String? ?? '',
                          style: TextStyle(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Text(
                    formattedAmount,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                formattedDate,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 8),
              if (status == 'approved' || status == 'pending') ...[
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (status == 'approved')
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Navigate to bid details screen
                        },
                        icon: const Icon(Icons.visibility),
                        label: Text('view_bids'.tr),
                      ),
                    if (status == 'pending')
                      TextButton.icon(
                        onPressed: () {
                          // TODO: Implement cancel functionality
                        },
                        icon: const Icon(Icons.cancel),
                        label: Text('cancel_request'.tr),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'approved':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      case 'pending':
      default:
        return Colors.orange;
    }
  }

  String _getStatusText(String status) {
    switch (status) {
      case 'approved':
        return 'status_approved'.tr;
      case 'rejected':
        return 'status_rejected'.tr;
      case 'cancelled':
        return 'status_cancelled'.tr;
      case 'pending':
      default:
        return 'status_pending'.tr;
    }
  }

  // Card for navigating to EMI Payments
  Widget _buildEmiPaymentCard() {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.EMI_PAYMENT),
        borderRadius: BorderRadius.circular(8.0), // Match Card shape
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.payment, size: 30, color: Get.theme.primaryColor),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('EMI Payments',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('View your loan schedule and pay EMIs',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  // Card for navigating to Payment History
  Widget _buildPaymentHistoryCard() {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => Get.toNamed(Routes.PAYMENT_HISTORY),
        borderRadius: BorderRadius.circular(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(Icons.history, size: 30, color: Get.theme.primaryColor),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Payment History',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('View your past payment attempts',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}
