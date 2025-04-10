import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/notification_model.dart';
import '../controllers/notifications_controller.dart';

class NotificationsScreen extends GetView<NotificationsController> {
  const NotificationsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          // Optional: Add filtering/sorting later
          Obx(() => controller.unreadCount.value > 0
              ? TextButton(
                  onPressed: controller.markAllAsRead,
                  child: const Text('Mark All Read'),
                )
              : const SizedBox.shrink()),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Notifications',
            onPressed: () => controller.fetchNotifications(isRefresh: true),
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
        if (controller.notifications.isEmpty) {
          return const Center(
              child: Padding(
            padding: EdgeInsets.all(20.0),
            child: Text('You have no notifications.',
                style: TextStyle(color: Colors.grey)),
          ));
        }
        return ListView.separated(
          itemCount: controller.notifications.length,
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];
            return _buildNotificationItem(notification);
          },
          separatorBuilder: (context, index) => const Divider(height: 0),
        );
      }),
    );
  }

  Widget _buildNotificationItem(NotificationModel notification) {
    final bool isRead = notification.read;
    final fontWeight = isRead ? FontWeight.normal : FontWeight.bold;
    final tileColor = isRead ? null : Get.theme.primaryColor.withOpacity(0.05);
    final textColor = isRead ? Colors.grey[600] : null;

    IconData leadingIcon;
    switch (notification.data?['type']) {
      case 'appointment':
        leadingIcon = Icons.event_available;
        break;
      case 'bid':
        leadingIcon = Icons.gavel;
        break;
      // Add more types as needed
      default:
        leadingIcon = Icons.notifications;
    }

    return ListTile(
      tileColor: tileColor,
      leading: CircleAvatar(
        backgroundColor: isRead ? Colors.grey.shade300 : Get.theme.primaryColor,
        child: Icon(leadingIcon,
            color: isRead ? Colors.grey.shade700 : Colors.white, size: 20),
      ),
      title: Text(
        notification.title,
        style: TextStyle(fontWeight: fontWeight),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            notification.body,
            style: TextStyle(color: textColor),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            controller.formatTimestamp(notification.createdAt),
            style: Get.textTheme.labelSmall?.copyWith(color: Colors.grey[500]),
          ),
        ],
      ),
      trailing: !isRead
          ? Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                  color: Get.theme.primaryColor, shape: BoxShape.circle),
            )
          : null,
      onTap: () => controller.handleNotificationTap(notification),
    );
  }
}
