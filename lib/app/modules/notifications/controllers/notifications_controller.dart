import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../data/models/notification_model.dart';
import '../../../routes/app_pages.dart'; // For navigation

class NotificationsController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final RxBool isLoading = true.obs;
  final RxList<NotificationModel> notifications = <NotificationModel>[].obs;
  final RxString errorMessage = ''.obs;
  final RxInt unreadCount = 0.obs;

  User? get currentUser => _auth.currentUser;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> fetchNotifications({bool isRefresh = false}) async {
    isLoading.value = true;
    errorMessage.value = '';
    if (isRefresh) {
      notifications.clear();
    }

    if (currentUser == null) {
      errorMessage.value = 'User not authenticated.';
      isLoading.value = false;
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: currentUser!.uid)
          .orderBy('createdAt', descending: true)
          .limit(50) // Limit initial fetch, consider pagination later
          .get();

      final fetchedNotifications = querySnapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();

      notifications.assignAll(fetchedNotifications);
      _updateUnreadCount();

      if (notifications.isEmpty) {
        print('No notifications found for user ${currentUser!.uid}');
      }
    } catch (e) {
      print('Error fetching notifications: $e');
      errorMessage.value = 'Failed to load notifications: ${e.toString()}';
    } finally {
      isLoading.value = false;
    }
  }

  void _updateUnreadCount() {
    unreadCount.value = notifications.where((n) => !n.read).length;
  }

  Future<void> markAsRead(NotificationModel notification) async {
    if (notification.read) return; // Already read

    try {
      await _firestore
          .collection('notifications')
          .doc(notification.id)
          .update({'read': true});

      // Update local state immediately for better UX
      final index = notifications.indexWhere((n) => n.id == notification.id);
      if (index != -1) {
        notifications[index] = notification.copyWith(read: true);
        notifications.refresh(); // Notify listeners
        _updateUnreadCount();
      }
    } catch (e) {
      print('Error marking notification as read: $e');
      Get.snackbar('Error', 'Could not mark notification as read.');
    }
  }

  Future<void> markAllAsRead() async {
    if (unreadCount.value == 0) return;

    final unreadIds =
        notifications.where((n) => !n.read).map((n) => n.id).toList();
    if (unreadIds.isEmpty) return;

    // Show loading indicator maybe?
    // isLoading.value = true; // Or a specific loading state

    try {
      // Use a batched write for efficiency
      WriteBatch batch = _firestore.batch();
      for (String id in unreadIds) {
        batch.update(
            _firestore.collection('notifications').doc(id), {'read': true});
      }
      await batch.commit();

      // Update local state
      for (int i = 0; i < notifications.length; i++) {
        if (unreadIds.contains(notifications[i].id)) {
          notifications[i] = notifications[i].copyWith(read: true);
        }
      }
      notifications.refresh();
      _updateUnreadCount();
    } catch (e) {
      print('Error marking all notifications as read: $e');
      Get.snackbar('Error', 'Could not mark all notifications as read.');
    } finally {
      // isLoading.value = false;
    }
  }

  void handleNotificationTap(NotificationModel notification) {
    print(
        "Notification tapped: ${notification.id}, Data: ${notification.data}");
    // Mark as read when tapped
    markAsRead(notification);

    // Navigate based on data
    if (notification.data != null) {
      final type = notification.data!['type'];
      final id = notification.data!['id'] ??
          notification
              .data!['appointment_id']; // Handle potential key difference

      if (type == 'appointment' && id != null) {
        Get.toNamed(Routes.APPOINTMENT_DETAILS,
            arguments: {'appointmentId': id});
      } else if (type == 'bid' && id != null) {
        // TODO: Navigate to Bid Details or Loan Request Bids screen
        // Get.toNamed(Routes.BID_DETAILS, arguments: { 'bidId': id });
        print('Navigate to Bid/Loan Request related to ID: $id');
      } else {
        print('Unknown notification type or missing ID in data');
      }
    } else {
      print('No navigation data found in notification.');
    }
  }

  // Helper for formatting dates
  String formatTimestamp(Timestamp timestamp) {
    return DateFormat('dd MMM yyyy, hh:mm a').format(timestamp.toDate());
  }
}
