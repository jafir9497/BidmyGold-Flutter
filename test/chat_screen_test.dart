import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:bidmygoldflutter/app/modules/chat/controllers/chat_controller.dart';
import 'package:bidmygoldflutter/app/modules/chat/screens/chat_screen.dart';

// Simple mock for testing
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

  // Implement required methods with minimal functionality for testing
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

  testWidgets('ChatScreen shows empty state message when no messages exist',
      (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    // Verify empty state message is shown
    expect(find.text('No messages yet. Start a conversation!'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.byIcon(Icons.send), findsOneWidget);
  });

  testWidgets('ChatScreen shows messages when they exist',
      (WidgetTester tester) async {
    // Add a test message
    controller.messages.add(ChatMessage(
      id: 'test-msg-1',
      senderId: 'other-user',
      content: 'Hello there!',
      timestamp: DateTime.now(),
    ));

    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    // Verify message is shown
    expect(find.text('Hello there!'), findsOneWidget);
    expect(find.text('No messages yet. Start a conversation!'), findsNothing);
  });

  testWidgets('ChatScreen can send a message', (WidgetTester tester) async {
    // Build the widget
    await tester.pumpWidget(
      const MaterialApp(
        home: ChatScreen(),
      ),
    );

    // Enter text in the input field
    await tester.enterText(find.byType(TextField), 'Test message');

    // Tap the send button
    await tester.tap(find.byIcon(Icons.send));
    await tester.pump();

    // Verify the message was added
    expect(find.text('Test message'), findsOneWidget);
    expect(find.text('No messages yet. Start a conversation!'), findsNothing);
    expect(controller.messages.length, 1);
    expect(controller.messages[0].content, 'Test message');
  });
}
