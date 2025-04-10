import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/loan_monitoring_controller.dart';
import '../widgets/admin_drawer.dart';
import 'package:intl/intl.dart';
import '../../../data/models/loan_request_model.dart';

class LoanMonitoringScreen extends GetView<LoanMonitoringController> {
  const LoanMonitoringScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('loan_monitoring_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'refresh'.tr,
            onPressed: () =>
                controller.fetchInitialLoanRequests(isRefresh: true),
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Column(
        children: [
          _buildStatsCard(),
          _buildFilterAndSearch(),
          Expanded(child: _buildLoanRequestList()),
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Card(
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('overview_stats_title'.tr,
                    style: Get.textTheme.titleLarge),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildStatItem('total_requests_label'.tr,
                        controller.totalRequestCount.value.toString()),
                    _buildStatItem(
                        'total_amount_label'.tr,
                        NumberFormat.currency(locale: 'en_IN', symbol: '₹')
                            .format(controller.totalRequestedAmount.value)),
                  ],
                ),
                // Add more stats rows as needed
              ],
            )),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: Get.textTheme.bodySmall),
        const SizedBox(height: 2),
        Text(value,
            style: Get.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildFilterAndSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: controller.setSearchQuery,
              decoration: InputDecoration(
                hintText: 'loan_search_hint'.tr,
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0)),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                isDense: true,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _buildStatusFilterDropdown(),
        ],
      ),
    );
  }

  Widget _buildStatusFilterDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8.0),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Obx(() => DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: controller.selectedStatusFilter.value,
              onChanged: (String? newValue) {
                if (newValue != null) {
                  controller.setStatusFilter(newValue);
                }
              },
              items: <String>[
                'all', 'pending', 'active', 'completed', 'rejected',
                'cancelled' // Add relevant statuses
              ].map<DropdownMenuItem<String>>((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text('loan_status_${value}'.tr),
                );
              }).toList(),
              style: Get.textTheme.bodyMedium,
              icon: Icon(Icons.filter_list, color: Get.theme.primaryColor),
              isDense: true,
            ),
          )),
    );
  }

  Widget _buildLoanRequestList() {
    final scrollController = ScrollController();

    void _scrollListener() {
      if (scrollController.position.extentAfter < 500 &&
          !controller.isLoadingMore.value &&
          controller.hasMoreData.value) {
        controller.loadMoreLoanRequests();
      }
    }

    scrollController.addListener(_scrollListener);

    // Dispose listener
    // Get.find<LoanMonitoringController>().addOnClose(() => scrollController.removeListener(_scrollListener));
    // Note: Proper disposal would ideally be in the controller's onClose or using Getx's features

    return Obx(() {
      if (controller.isLoading.value && controller.allLoanRequests.isEmpty) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.filteredLoanRequests.isEmpty &&
          !controller.isLoading.value) {
        return Center(
          child: Text(
            controller.searchQuery.isNotEmpty ||
                    controller.selectedStatusFilter.value != 'all'
                ? 'loan_search_no_match'.tr
                : 'loan_search_no_requests'.tr,
            style: Get.textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
          ),
        );
      }
      return RefreshIndicator(
        onRefresh: () => controller.fetchInitialLoanRequests(isRefresh: true),
        child: ListView.builder(
          controller: scrollController,
          itemCount: controller.filteredLoanRequests.length +
              (controller.isLoadingMore.value ? 1 : 0),
          itemBuilder: (context, index) {
            if (index == controller.filteredLoanRequests.length) {
              return const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Center(child: CircularProgressIndicator()),
              );
            }
            final request = controller.filteredLoanRequests[index];
            return _buildLoanRequestItem(request);
          },
        ),
      );
    });
  }

  Widget _buildLoanRequestItem(LoanRequestModel request) {
    final currencyFormat = NumberFormat.currency(locale: 'en_IN', symbol: '₹');
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    final createdDate = dateFormat.format(request.createdAt.toDate());
    final statusColor = _getStatusColor(request.status);
    final unknownText = 'unknown'.tr;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: ListTile(
        // leading: CircleAvatar(child: Icon(Icons.receipt_long)), // Optional icon
        title: Text('${'req_id_label'.tr}: ${request.id}',
            style: Get.textTheme.labelSmall),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${'user_id_label'.tr}: ${request.userId ?? unknownText}'),
            Text(
                '${'amount_label'.tr}: ${currencyFormat.format(request.loanAmount)}'),
            Text(
                '${'type_label'.tr}: ${request.jewelType} (${request.jewelWeight}g, ${request.jewelPurity})'),
            Text('${'created_label'.tr}: $createdDate'),
            Row(
              children: [
                Text('${'status_label'.tr}: '),
                Text(
                  'loan_status_${request.status}'.tr.toUpperCase(),
                  style: TextStyle(
                      color: statusColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ],
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => controller.viewLoanRequestDetails(request.id),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'active': // Assuming 'active' means approved/ongoing
      case 'approved':
        return Colors.blue;
      case 'completed':
        return Colors.green;
      case 'rejected':
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
