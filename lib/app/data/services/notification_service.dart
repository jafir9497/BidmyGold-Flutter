import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../routes/app_pages.dart';

class NotificationService extends GetxService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  // Observable to track if notification permissions are granted
  final RxBool notificationsEnabled = false.obs;

  // Initialize the notification service
  Future<NotificationService> init() async {
    try {
      // Request notification permissions
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
      );

      notificationsEnabled.value =
          settings.authorizationStatus == AuthorizationStatus.authorized;

      // Configure local notifications
      await _initLocalNotifications();

      // Configure FCM handlers
      _configureMessageHandlers();

      // Get FCM token and save it to Firestore
      if (_auth.currentUser != null) {
        await _saveTokenToFirestore();
      }

      // Listen for auth changes to update the token
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          _saveTokenToFirestore();
        }
      });

      return this;
    } catch (e) {
      print('Error initializing notification service: $e');
      return this;
    }
  }

  // Initialize local notifications
  Future<void> _initLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTapped,
    );

    // Create notification channels for Android
    if (Platform.isAndroid) {
      await _createNotificationChannels();
    }
  }

  // Create notification channels for Android
  Future<void> _createNotificationChannels() async {
    const AndroidNotificationChannel loanRequestsChannel =
        AndroidNotificationChannel(
      'loan_requests_channel', // id
      'Loan Requests', // title
      description: 'Notifications for new loan requests', // description
      importance: Importance.high,
    );

    const AndroidNotificationChannel bidsChannel = AndroidNotificationChannel(
      'bids_channel', // id
      'Bid Notifications', // title
      description: 'Notifications for new bids on loan requests', // description
      importance: Importance.high,
    );

    const AndroidNotificationChannel appointmentsChannel =
        AndroidNotificationChannel(
      'appointments_channel', // id
      'Appointments', // title
      description: 'Appointment reminders', // description
      importance: Importance.high,
    );

    const AndroidNotificationChannel chatChannel = AndroidNotificationChannel(
      'chat_channel', // id
      'Chat Messages', // title
      description: 'Notifications for new chat messages', // description
      importance: Importance.high,
    );

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(loanRequestsChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(bidsChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(appointmentsChannel);

    await _localNotifications
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(chatChannel);
  }

  // Configure FCM message handlers
  void _configureMessageHandlers() {
    // Handle messages when the app is in the foreground
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle when the user taps on a notification that opened the app
    FirebaseMessaging.onMessageOpenedApp.listen(_handleNotificationOpenedApp);

    // Handle initial message (app opened from terminated state)
    _messaging.getInitialMessage().then((message) {
      if (message != null) {
        _handleInitialMessage(message);
      }
    });
  }

  // Handle foreground messages by showing a local notification
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    print('Foreground message received: ${message.data}');

    // Get notification details
    final notification = message.notification;
    final data = message.data;
    final androidNotification = notification?.android;

    // Show a local notification
    if (notification != null) {
      String channelId = 'default_channel';

      // Determine the correct channel based on notification type
      if (data.containsKey('type')) {
        final type = data['type'];
        if (type == 'loan_request') {
          channelId = 'loan_requests_channel';
        } else if (type == 'bid') {
          channelId = 'bids_channel';
        } else if (type == 'appointment') {
          channelId = 'appointments_channel';
        } else if (type == 'chat') {
          channelId = 'chat_channel';
        }
      }

      // Create notification details
      final androidDetails = AndroidNotificationDetails(
        channelId,
        channelId.replaceAll('_', ' ').capitalize!,
        importance: Importance.high,
        priority: Priority.high,
        icon: androidNotification?.smallIcon ?? '@mipmap/ic_launcher',
      );

      const iosDetails = DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: iosDetails,
      );

      // Show the notification
      await _localNotifications.show(
        message.hashCode,
        notification.title,
        notification.body,
        platformDetails,
        payload: jsonEncode(data),
      );
    }
  }

  // Handle when user taps on a notification that opened the app
  void _handleNotificationOpenedApp(RemoteMessage message) {
    print('Notification opened app: ${message.data}');
    _navigateBasedOnNotification(message.data);
  }

  // Handle when the app is opened from a terminated state via notification
  void _handleInitialMessage(RemoteMessage message) {
    print('Initial message: ${message.data}');
    _navigateBasedOnNotification(message.data);
  }

  // Handle when user taps on a local notification
  void _onNotificationTapped(NotificationResponse response) {
    if (response.payload != null) {
      try {
        final data = jsonDecode(response.payload!) as Map<String, dynamic>;
        _navigateBasedOnNotification(data);
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  // Navigate based on the notification data
  void _navigateBasedOnNotification(Map<String, dynamic> data) {
    if (data.containsKey('type')) {
      final type = data['type'];

      switch (type) {
        case 'loan_request':
          if (data.containsKey('loan_request_id')) {
            Get.toNamed(
              Routes.PAWNBROKER_LOAN_REQUEST_DETAILS,
              arguments: {'loanRequestId': data['loan_request_id']},
            );
          }
          break;

        case 'bid':
          if (data.containsKey('loan_request_id')) {
            // For users, navigate to bids view
            Get.toNamed(
              Routes.LOAN_REQUEST_BIDS,
              arguments: {'loanRequestId': data['loan_request_id']},
            );
          }
          break;

        case 'bid_accepted':
          if (data.containsKey('loan_request_id')) {
            // For pawnbrokers, navigate to appointment scheduling
            Get.toNamed(
              Routes.APPOINTMENT_SCHEDULING,
              arguments: {
                'loanRequestId': data['loan_request_id'],
                'bidId': data['bid_id'],
              },
            );
          }
          break;

        case 'appointment':
          if (data.containsKey('appointment_id')) {
            Get.toNamed(
              Routes.APPOINTMENT_DETAILS,
              arguments: {'appointmentId': data['appointment_id']},
            );
          }
          break;

        case 'chat':
          if (data.containsKey('chat_id')) {
            Get.toNamed(
              Routes.CHAT,
              arguments: {'chatId': data['chat_id']},
            );
          }
          break;
      }
    }
  }

  // Save FCM token to Firestore for the current user
  Future<void> _saveTokenToFirestore() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      final token = await _messaging.getToken();
      if (token == null) return;

      // Determine user type (pawnbroker or user)
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final pawnbrokerDoc =
          await _firestore.collection('pawnbrokers').doc(user.uid).get();

      String userType = 'unknown';
      String collectionPath = '';

      if (userDoc.exists) {
        userType = 'user';
        collectionPath = 'users';
      } else if (pawnbrokerDoc.exists) {
        userType = 'pawnbroker';
        collectionPath = 'pawnbrokers';
      } else {
        // New user, don't save token yet
        return;
      }

      // Save the token with device info and timestamp
      await _firestore.collection(collectionPath).doc(user.uid).update({
        'fcmTokens': FieldValue.arrayUnion([
          {
            'token': token,
            'device': Platform.isAndroid ? 'android' : 'ios',
            'createdAt': FieldValue.serverTimestamp(),
          }
        ]),
      });

      print('FCM Token saved to Firestore for $userType: $token');
    } catch (e) {
      print('Error saving FCM token: $e');
    }
  }

  // Subscribe to topic based on user type
  Future<void> subscribeToTopics() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Determine user type
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final pawnbrokerDoc =
          await _firestore.collection('pawnbrokers').doc(user.uid).get();

      if (userDoc.exists) {
        // Subscribe to user-specific topics
        await _messaging.subscribeToTopic('users');

        // If the user has active loan requests, subscribe to that topic
        if (userDoc.data()?['hasActiveLoanRequest'] == true) {
          await _messaging.subscribeToTopic('users_with_loan_requests');
        }
      } else if (pawnbrokerDoc.exists) {
        // Subscribe to pawnbroker-specific topics
        await _messaging.subscribeToTopic('pawnbrokers');

        // Get pawnbroker location data to subscribe to area-specific topics
        final pawnbrokerData = pawnbrokerDoc.data();
        if (pawnbrokerData != null && pawnbrokerData.containsKey('pinCode')) {
          final pinCode = pawnbrokerData['pinCode'];
          await _messaging.subscribeToTopic('area_$pinCode');
        }
      }
    } catch (e) {
      print('Error subscribing to topics: $e');
    }
  }

  // Unsubscribe from topics
  Future<void> unsubscribeFromTopics() async {
    try {
      await _messaging.unsubscribeFromTopic('users');
      await _messaging.unsubscribeFromTopic('users_with_loan_requests');
      await _messaging.unsubscribeFromTopic('pawnbrokers');

      // Get user data to unsubscribe from area-specific topics
      final user = _auth.currentUser;
      if (user != null) {
        final pawnbrokerDoc =
            await _firestore.collection('pawnbrokers').doc(user.uid).get();
        final pawnbrokerData = pawnbrokerDoc.data();
        if (pawnbrokerData != null && pawnbrokerData.containsKey('pinCode')) {
          final pinCode = pawnbrokerData['pinCode'];
          await _messaging.unsubscribeFromTopic('area_$pinCode');
        }
      }
    } catch (e) {
      print('Error unsubscribing from topics: $e');
    }
  }

  // Send a test notification (for development purposes)
  Future<void> sendTestNotification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) return;

      // Create a test notification document in Firestore to trigger a Cloud Function
      await _firestore.collection('test_notifications').add({
        'userId': user.uid,
        'title': 'Test Notification',
        'body': 'This is a test notification.',
        'data': {
          'type': 'test',
        },
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('Test notification request sent');
    } catch (e) {
      print('Error sending test notification: $e');
    }
  }

  // Send a notification to a specific user
  Future<void> sendNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    try {
      // Create a new notification document in Firestore
      await _firestore.collection('notifications').add({
        'userId': userId,
        'title': title,
        'body': body,
        'data': data ?? {},
        'read': false,
        'createdAt': FieldValue.serverTimestamp(),
        'sender': _auth.currentUser?.uid,
      });

      // The actual FCM push notification will be handled by a Cloud Function
      // that listens to the notifications collection and sends the FCM message
      print('Notification request added to Firestore for user $userId');
    } catch (e) {
      print('Error sending notification: $e');
    }
  }

  // Send a bid accepted notification
  Future<void> sendBidAcceptedNotification(String bidId) async {
    try {
      final bid = await _firestore.collection('bids').doc(bidId).get();
      final bidData = bid.data();
      if (bidData == null) return;

      final pawnbrokerUid = bidData['pawnbrokerUid'];
      if (pawnbrokerUid == null) return;

      await sendNotification(
        userId: pawnbrokerUid,
        title: 'bid_accepted_title'.tr,
        body: 'bid_accepted_body'.tr,
        data: {
          'type': 'bid_accepted',
          'bid_id': bidId,
        },
      );
    } catch (e) {
      print('Error sending bid accepted notification: $e');
    }
  }

  // Send a bid rejected notification
  Future<void> sendBidRejectedNotification(String bidId) async {
    try {
      final bid = await _firestore.collection('bids').doc(bidId).get();
      final bidData = bid.data();
      if (bidData == null) return;

      final pawnbrokerUid = bidData['pawnbrokerUid'];
      if (pawnbrokerUid == null) return;

      await sendNotification(
        userId: pawnbrokerUid,
        title: 'bid_rejected_title'.tr,
        body: 'bid_rejected_body'.tr,
        data: {
          'type': 'bid_rejected',
          'bid_id': bidId,
        },
      );
    } catch (e) {
      print('Error sending bid rejected notification: $e');
    }
  }
}
