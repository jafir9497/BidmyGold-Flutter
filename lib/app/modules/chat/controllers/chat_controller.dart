import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:uuid/uuid.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String content;
  final DateTime timestamp;
  final String
      status; // added status field: 'sent', 'delivered', 'read', 'failed'

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.content,
    required this.timestamp,
    this.status = 'sent',
  });
}

class ChatController extends GetxController {
  // Firebase instances
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Text editing controller for the message input
  final TextEditingController messageController = TextEditingController();

  // Observable properties
  final RxString chatId = ''.obs;
  final RxString appointmentId = ''.obs;
  final RxString otherUserId = ''.obs;
  final RxString otherUserName = ''.obs;
  final RxBool isLoading = true.obs;
  final RxBool isSending = false.obs;
  final RxBool canSend = false.obs;
  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxString chatTitle = 'Chat'.obs;
  final RxBool isOnline = true.obs;
  final RxBool isTyping = false.obs;
  final RxString connectionStatus = 'online'.obs;

  // Typing timer
  var _typingTimer;
  var _typingStatusSubscription;

  // Connectivity
  final Connectivity _connectivity = Connectivity();
  var _connectivitySubscription;

  // Current user ID
  String get currentUserId => _auth.currentUser?.uid ?? '';

  // Stream subscription
  var _messagesSubscription;

  @override
  void onInit() {
    super.onInit();

    // Listen to connectivity changes
    _monitorConnectivity();

    // Listen to text changes for typing indicator
    messageController.addListener(_onTextChanged);

    if (Get.arguments != null) {
      // Set the chat ID, appointment ID, and other user ID from arguments
      if (Get.arguments['chatId'] != null) {
        chatId.value = Get.arguments['chatId'];
      }
      if (Get.arguments['appointmentId'] != null) {
        appointmentId.value = Get.arguments['appointmentId'];
      }
      if (Get.arguments['otherUserId'] != null) {
        otherUserId.value = Get.arguments['otherUserId'];
      }
      if (Get.arguments['chatTitle'] != null) {
        chatTitle.value = Get.arguments['chatTitle'];
      }

      // Initialize chat
      initChat();
    } else {
      isLoading.value = false;
    }

    // Initialize can send status
    updateCanSend();
  }

  @override
  void onClose() {
    // Dispose of controllers and subscriptions
    messageController.dispose();
    if (_typingTimer != null) {
      _typingTimer.cancel();
    }
    if (_typingStatusSubscription != null) {
      _typingStatusSubscription.cancel();
    }
    if (_messagesSubscription != null) {
      _messagesSubscription.cancel();
    }
    if (_connectivitySubscription != null) {
      _connectivitySubscription.cancel();
    }
    // Update user's online status
    _updatePresenceStatus(false);
    super.onClose();
  }

  // Monitor connectivity
  void _monitorConnectivity() {
    _connectivitySubscription =
        _connectivity.onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        connectionStatus.value = 'offline';
        isOnline.value = false;
      } else {
        connectionStatus.value = 'online';
        isOnline.value = true;
        // When coming back online, try to resend any failed messages
        _retryFailedMessages();
      }
    });
  }

  // Handle text changes for typing indicator
  void _onTextChanged() {
    if (messageController.text.isNotEmpty && !isTyping.value) {
      isTyping.value = true;
      _updateTypingStatus(true);
    }

    // Reset typing timer
    if (_typingTimer != null) {
      _typingTimer.cancel();
    }

    _typingTimer = Future.delayed(const Duration(seconds: 3), () {
      isTyping.value = false;
      _updateTypingStatus(false);
    });

    updateCanSend();
  }

  // Update typing status in Firestore
  void _updateTypingStatus(bool isTyping) {
    if (chatId.value.isEmpty) return;

    try {
      _firestore.collection('chats').doc(chatId.value).update({
        'typingUsers': isTyping
            ? FieldValue.arrayUnion([currentUserId])
            : FieldValue.arrayRemove([currentUserId])
      });
    } catch (e) {
      print('Error updating typing status: $e');
    }
  }

  // Update user's online status
  void _updatePresenceStatus(bool isOnline) {
    if (currentUserId.isEmpty) return;

    try {
      _firestore.collection('users').doc(currentUserId).update({
        'isOnline': isOnline,
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating presence status: $e');
    }
  }

  // Initialize chat
  Future<void> initChat() async {
    isLoading.value = true;

    try {
      // Update user's online status
      _updatePresenceStatus(true);

      // If no chat ID is provided, we need to create or find one
      if (chatId.value.isEmpty && otherUserId.value.isNotEmpty) {
        await findOrCreateChat();
      }

      // Fetch other user's name if not provided
      if (otherUserName.value.isEmpty && otherUserId.value.isNotEmpty) {
        await fetchOtherUserName();
      }

      // Listen for messages
      listenToMessages();

      // Listen for typing status
      listenToTypingStatus();

      isLoading.value = false;
    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        'error'.tr,
        'chat_init_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Listen to typing status changes
  void listenToTypingStatus() {
    if (chatId.value.isEmpty) return;

    _typingStatusSubscription = _firestore
        .collection('chats')
        .doc(chatId.value)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final typingUsers = List<String>.from(data['typingUsers'] ?? []);

        // Check if other user is typing
        if (typingUsers.contains(otherUserId.value)) {
          if (!chatTitle.value.contains(' is typing...')) {
            chatTitle.value = '${otherUserName.value} is typing...';
          }
        } else {
          if (chatTitle.value.contains(' is typing...')) {
            chatTitle.value = otherUserName.value;
          }
        }
      }
    });
  }

  // Find or create a chat with another user
  Future<void> findOrCreateChat() async {
    // Try to find existing chat with both users
    final existingChatQuery = await _firestore.collection('chats').where(
        'participants',
        arrayContainsAny: [currentUserId, otherUserId.value]).get();

    // Check if both users are participants in any of the chats
    for (final doc in existingChatQuery.docs) {
      final participants = List<String>.from(doc['participants'] ?? []);
      if (participants.contains(currentUserId) &&
          participants.contains(otherUserId.value)) {
        chatId.value = doc.id;
        return;
      }
    }

    // No existing chat found, create a new one
    if (chatId.value.isEmpty) {
      final newChatRef = _firestore.collection('chats').doc();
      await newChatRef.set({
        'participants': [currentUserId, otherUserId.value],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'appointmentId': appointmentId.value,
        'typingUsers': [],
      });

      chatId.value = newChatRef.id;
    }
  }

  // Fetch other user's name
  Future<void> fetchOtherUserName() async {
    try {
      // Check in users collection
      final userDoc =
          await _firestore.collection('users').doc(otherUserId.value).get();
      if (userDoc.exists && userDoc.data()?['name'] != null) {
        otherUserName.value = userDoc.data()?['name'];
        return;
      }

      // Check in pawnbrokers collection
      final pawnbrokerDoc = await _firestore
          .collection('pawnbrokers')
          .doc(otherUserId.value)
          .get();
      if (pawnbrokerDoc.exists) {
        if (pawnbrokerDoc.data()?['shopName'] != null) {
          otherUserName.value = pawnbrokerDoc.data()?['shopName'];
        } else if (pawnbrokerDoc.data()?['ownerName'] != null) {
          otherUserName.value = pawnbrokerDoc.data()?['ownerName'];
        }
        return;
      }

      // Default name if not found
      otherUserName.value = 'user'.tr;
    } catch (e) {
      otherUserName.value = 'user'.tr;
    }
  }

  // Listen to messages
  void listenToMessages() {
    if (chatId.value.isEmpty) return;

    final messagesStream = _firestore
        .collection('chats')
        .doc(chatId.value)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots();

    _messagesSubscription = messagesStream.listen((QuerySnapshot snapshot) {
      final newMessages = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;

        // Convert Firestore Timestamp to DateTime
        DateTime? timestamp;
        if (data['timestamp'] is Timestamp) {
          timestamp = (data['timestamp'] as Timestamp).toDate();
        }

        return ChatMessage(
          id: doc.id,
          senderId: data['senderId'] ?? '',
          content: data['text'] ?? '',
          timestamp: timestamp ?? DateTime.now(),
          status: data['status'] ?? 'sent',
        );
      }).toList();

      messages.value = newMessages;

      // Mark received messages as read
      _markMessagesAsRead(snapshot.docs);
    }, onError: (error) {
      print('Error listening to messages: $error');
      Get.snackbar(
        'error'.tr,
        'chat_connection_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    });
  }

  // Update whether message can be sent
  void updateCanSend() {
    canSend.value = messageController.text.trim().isNotEmpty;
  }

  // Send a message
  Future<void> sendMessage() async {
    if (chatId.value.isEmpty ||
        messageController.text.trim().isEmpty ||
        isSending.value) {
      return;
    }

    isSending.value = true;
    final messageText = messageController.text.trim();
    messageController.clear();
    updateCanSend();

    // Stop typing indicator
    isTyping.value = false;
    _updateTypingStatus(false);

    // Create a local message to show immediately
    final localMessageId = const Uuid().v4();
    final localMessage = ChatMessage(
      id: localMessageId,
      senderId: currentUserId,
      content: messageText,
      timestamp: DateTime.now(),
      status: isOnline.value ? 'sending' : 'pending',
    );

    // Add the message to the local list
    messages.insert(0, localMessage);

    // If offline, store in pending messages and return
    if (!isOnline.value) {
      isSending.value = false;
      Get.snackbar(
        'info'.tr,
        'message_will_be_sent_when_online'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Save to Firestore
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId.value)
          .collection('messages')
          .doc();

      await messageRef.set({
        'text': messageText,
        'senderId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent'
      });

      // Update the last message in the chat document
      await _firestore.collection('chats').doc(chatId.value).update({
        'lastMessage': messageText,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': currentUserId
      });

      // Send notification to the other user
      _sendMessageNotification(messageText);

      isSending.value = false;
    } catch (e) {
      // Update the message status to failed
      final index = messages.indexWhere((m) => m.id == localMessageId);
      if (index != -1) {
        final updatedMessages = [...messages];
        updatedMessages[index] = ChatMessage(
          id: localMessageId,
          senderId: currentUserId,
          content: messageText,
          timestamp: localMessage.timestamp,
          status: 'failed',
        );
        messages.assignAll(updatedMessages);
      }

      isSending.value = false;
      Get.snackbar(
        'error'.tr,
        'message_send_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Retry sending all failed messages
  void _retryFailedMessages() {
    final failedMessages = messages
        .where((m) => m.status == 'failed' || m.status == 'pending')
        .toList();

    for (var msg in failedMessages) {
      retryMessage(msg.id);
    }
  }

  // Retry sending a failed message
  Future<void> retryMessage(String messageId) async {
    final index = messages.indexWhere((m) => m.id == messageId);
    if (index == -1) return;

    // Get the failed message
    final failedMessage = messages[index];
    final messageText = failedMessage.content;

    // Update message status to sending
    final updatedMessages = [...messages];
    updatedMessages[index] = ChatMessage(
      id: failedMessage.id,
      senderId: failedMessage.senderId,
      content: failedMessage.content,
      timestamp: failedMessage.timestamp,
      status: 'sending',
    );
    messages.assignAll(updatedMessages);

    // If still offline, mark as pending again
    if (!isOnline.value) {
      final updatedMessages = [...messages];
      updatedMessages[index] = ChatMessage(
        id: failedMessage.id,
        senderId: failedMessage.senderId,
        content: failedMessage.content,
        timestamp: failedMessage.timestamp,
        status: 'pending',
      );
      messages.assignAll(updatedMessages);

      Get.snackbar(
        'info'.tr,
        'message_will_be_sent_when_online'.tr,
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    try {
      // Save to Firestore
      final messageRef = _firestore
          .collection('chats')
          .doc(chatId.value)
          .collection('messages')
          .doc();

      await messageRef.set({
        'text': messageText,
        'senderId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'sent'
      });

      // Update the last message in the chat document
      await _firestore.collection('chats').doc(chatId.value).update({
        'lastMessage': messageText,
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastSenderId': currentUserId
      });

      // Send notification to the other user
      _sendMessageNotification(messageText);

      // Remove the failed message
      messages.removeAt(index);
    } catch (e) {
      // Update the message status back to failed
      final updatedMessages = [...messages];
      updatedMessages[index] = ChatMessage(
        id: failedMessage.id,
        senderId: failedMessage.senderId,
        content: failedMessage.content,
        timestamp: failedMessage.timestamp,
        status: 'failed',
      );
      messages.assignAll(updatedMessages);

      Get.snackbar(
        'error'.tr,
        'message_send_error'.tr,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  // Mark messages as read
  Future<void> _markMessagesAsRead(List<QueryDocumentSnapshot> docs) async {
    // Find messages sent by the other user that are not read
    final unreadMessages = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['senderId'] == otherUserId.value && data['status'] != 'read';
    }).toList();

    // Update status to read
    for (final doc in unreadMessages) {
      await _firestore
          .collection('chats')
          .doc(chatId.value)
          .collection('messages')
          .doc(doc.id)
          .update({'status': 'read'});
    }
  }

  // Send notification about new message
  Future<void> _sendMessageNotification(String messageText) async {
    try {
      await _firestore.collection('notifications').add({
        'userId': otherUserId.value,
        'title': 'new_message'.tr,
        'body': 'new_message_from'.trParams({
          'sender': otherUserName.value,
          'message': messageText.length > 50
              ? '${messageText.substring(0, 47)}...'
              : messageText
        }),
        'type': 'chat',
        'data': {
          'chatId': chatId.value,
          'messageText': messageText,
          'senderId': currentUserId,
          'appointmentId': appointmentId.value,
        },
        'read': false,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Just log the error, don't need to notify the user
      print('Failed to send notification: $e');
    }
  }
}
