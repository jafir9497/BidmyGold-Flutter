import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/admin_logs_controller.dart';
import '../widgets/admin_drawer.dart';
import '../models/activity_log.dart';
import '../models/admin_log_entry.dart';

class AdminLogsScreen extends GetView<AdminLogsController> {
  const AdminLogsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Define local function that wraps the void call in a Future
    Future<void> handleRefresh() async {
      controller.refreshLogs(); // Call the void function
      // Return a completed Future<void> to satisfy RefreshIndicator
      return Future.value();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('admin_logs_title'.tr),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'refresh'.tr,
            onPressed: controller.refreshLogs,
          ),
          IconButton(
            icon: const Icon(Icons.filter_alt),
            tooltip: 'filter_logs_tooltip'.tr,
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      drawer: const AdminDrawer(),
      body: Obx(() {
        if (controller.isInitialLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.logs.isEmpty) {
          return Center(
            child: Text(
              'no_admin_logs_found'.tr,
              style: const TextStyle(fontSize: 16, color: Colors.grey),
            ),
          );
        }
        return RefreshIndicator(
          // Pass the local function reference
          onRefresh: handleRefresh,
          child: NotificationListener<ScrollNotification>(
            onNotification: (ScrollNotification scrollInfo) {
              if (!controller.isLoading.value &&
                  scrollInfo.metrics.pixels >=
                      scrollInfo.metrics.maxScrollExtent * 0.8 &&
                  controller.hasMoreData.value) {
                controller.loadMoreLogs();
              }
              return false;
            },
            child: ListView.separated(
              padding: const EdgeInsets.only(bottom: 80.0),
              itemCount: controller.logs.length +
                  (controller.isLoadingMore.value ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == controller.logs.length) {
                  return controller.isLoadingMore.value
                      ? const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20.0),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox.shrink();
                }
                final log = controller.logs[index];
                return _buildLogListItem(log);
              },
              separatorBuilder: (context, index) => const Divider(height: 1),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: TextField(
        decoration: InputDecoration(
          hintText: 'admin_logs_search_hint'.tr,
          prefixIcon: const Icon(Icons.search),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 0.0),
        ),
        onChanged: controller.setSearchQuery,
      ),
    );
  }

  Widget _buildLogListItem(AdminLogEntry log) {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm:ss a');
    final logTime = log.timestamp != null
        ? dateFormat.format(log.timestamp.toDate())
        : 'not_available'.tr;
    final unknownAction = 'unknown_action'.tr;
    final unknownAdmin = 'unknown_admin'.tr;

    return ListTile(
      title: Text(log.action ?? unknownAction),
      subtitle: Text(
          '${'log_by_label'.tr}: ${log.adminName ?? unknownAdmin} (${log.adminId ?? "?"})\n${'log_at_label'.tr}: $logTime'),
      isThreeLine: true,
      dense: true,
      leading: const Icon(Icons.history, color: Colors.grey),
    );
  }

  void _showFilterDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('filter_logs_dialog_title'.tr),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'filter_by_admin_id_label'.tr,
                border: const OutlineInputBorder(),
              ),
              onChanged: (value) {
                controller.setAdminFilter(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              controller.clearFilters();
              Navigator.of(context).pop();
            },
            child: Text('clear_filters_button'.tr),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('apply_button'.tr),
          ),
        ],
      ),
    );
  }
}
