import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/chat_controller.dart';

class ChatScreen extends GetView<ChatController> {
  const ChatScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.chatTitle.value)),
        elevation: 0,
        actions: [
          // Online status indicator
          Obx(() => Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Center(
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: controller.connectionStatus.value == 'online'
                          ? Colors.green
                          : Colors.grey,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ))
        ],
      ),
      body: Column(
        children: [
          // Connection status banner (shown when offline)
          Obx(() => controller.connectionStatus.value == 'offline'
              ? Container(
                  width: double.infinity,
                  color: Colors.red.shade100,
                  padding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 16.0),
                  child: Row(
                    children: [
                      const Icon(Icons.cloud_off, size: 16, color: Colors.red),
                      const SizedBox(width: 8),
                      Text(
                        'offline_message'.tr,
                        style: TextStyle(
                          color: Colors.red.shade800,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink()),

          // Chat messages
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.messages.isEmpty) {
                return Center(
                  child: Text(
                    'no_messages_yet'.tr,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                );
              }

              return ListView.builder(
                reverse: true,
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 15),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  final message = controller.messages[index];
                  return _buildMessageItem(message, context);
                },
              );
            }),
          ),

          // Typing indicator
          Obx(() => controller.isTyping.value
              ? Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      vertical: 8.0, horizontal: 16.0),
                  child: Text(
                    'typing'.tr,
                    style: const TextStyle(
                      color: Colors.grey,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                )
              : const SizedBox.shrink()),

          // Message input
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 3,
                  offset: const Offset(0, -1),
                ),
              ],
            ),
            child: Row(
              children: [
                // Text input
                Expanded(
                  child: TextField(
                    controller: controller.messageController,
                    decoration: InputDecoration(
                      hintText: 'type_a_message'.tr,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24.0),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                    ),
                    maxLines: null,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => controller.sendMessage(),
                  ),
                ),
                // Send button
                Obx(() => IconButton(
                      icon: const Icon(Icons.send, color: Colors.blue),
                      onPressed: controller.canSend.value
                          ? controller.sendMessage
                          : null,
                      color: controller.canSend.value
                          ? Colors.blue
                          : Colors.grey[400],
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageItem(ChatMessage message, BuildContext context) {
    final isMe = message.senderId == controller.currentUserId;
    final timeString = DateFormat.Hm().format(message.timestamp);

    // Determine message status icon
    Widget? statusIcon;
    if (isMe) {
      switch (message.status) {
        case 'pending':
          statusIcon =
              const Icon(Icons.access_time, size: 12, color: Colors.orange);
          break;
        case 'sending':
          statusIcon = const SizedBox(
            width: 12,
            height: 12,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
            ),
          );
          break;
        case 'sent':
          statusIcon = const Icon(Icons.check, size: 12, color: Colors.grey);
          break;
        case 'delivered':
          statusIcon = const Icon(Icons.done_all, size: 12, color: Colors.grey);
          break;
        case 'read':
          statusIcon = const Icon(Icons.done_all, size: 12, color: Colors.blue);
          break;
        case 'failed':
          statusIcon =
              const Icon(Icons.error_outline, size: 12, color: Colors.red);
          break;
      }
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isMe)
            const CircleAvatar(
              radius: 16,
              child: Icon(Icons.person, size: 20),
            ),
          const SizedBox(width: 8),
          Flexible(
            child: InkWell(
              // Allow retry on failed messages
              onTap: message.status == 'failed'
                  ? () => controller.retryMessage(message.id)
                  : null,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: message.status == 'failed'
                      ? Colors.red[50]
                      : isMe
                          ? Colors.blue[100]
                          : Colors.grey[200],
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      message.content,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          timeString,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        if (statusIcon != null) ...[
                          const SizedBox(width: 4),
                          statusIcon,
                        ],
                        if (message.status == 'failed') ...[
                          const SizedBox(width: 4),
                          Text(
                            'tap_to_retry'.tr,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.red[400],
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (isMe)
            const CircleAvatar(
              radius: 16,
              backgroundColor: Colors.blue,
              child: Icon(Icons.person, size: 20, color: Colors.white),
            ),
        ],
      ),
    );
  }
}
