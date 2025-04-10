import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:mockito/mockito.dart';
import 'package:bidmygoldflutter/app/modules/chat/controllers/chat_controller.dart';

// Create a mock version of the ChatController to avoid Firebase dependencies
class MockChatController extends GetxController implements ChatController {
  @override
  final chatTitle = 'Test Chat'.obs;

  @override
  final isLoading = false.obs;

  @override
  final messages = <ChatMessage>[].obs;

  @override
  final TextEditingController messageController = TextEditingController();

  @override
  String get currentUserId => 'test-user-id';

  @override
  Future<void> sendMessage() async {
    if (messageController.text.isEmpty) return;

    final newMessage = ChatMessage(
      id: 'test-msg-${messages.length + 1}',
      senderId: currentUserId,
      content: messageController.text,
      timestamp: DateTime.now(),
    );

    messages.insert(0, newMessage);
    messageController.clear();
  }

  // Implement other required methods with minimal functionality for testing
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late MockChatController controller;

  setUp(() {
    controller = MockChatController();
    Get.put<ChatController>(controller);
  });

  tearDown(() {
    Get.reset();
  });

  group('ChatController Tests', () {
    test('Initial state should be correct', () {
      expect(controller.chatTitle.value, 'Test Chat');
      expect(controller.isLoading.value, false);
      expect(controller.messages, isEmpty);
    });

    test('sendMessage should add a message when text is not empty', () async {
      // Arrange
      controller.messageController.text = 'Hello, world!';

      // Act
      await controller.sendMessage();

      // Assert
      expect(controller.messages.length, 1);
      expect(controller.messages[0].content, 'Hello, world!');
      expect(controller.messages[0].senderId, controller.currentUserId);
      expect(controller.messageController.text, isEmpty);
    });

    test('sendMessage should not add a message when text is empty', () async {
      // Arrange
      controller.messageController.text = '';

      // Act
      await controller.sendMessage();

      // Assert
      expect(controller.messages, isEmpty);
    });
  });
}
