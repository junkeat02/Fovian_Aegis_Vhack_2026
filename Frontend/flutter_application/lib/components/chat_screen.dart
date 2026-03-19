import 'dart:math';

import "package:flutter/material.dart";
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final _chatController = InMemoryChatController();
  // 1. Setup the Typography (The actual text styles)
  final typography = ChatTypography(
    bodySmall: TextStyle(
      color: Colors.white,
      fontSize: 12,
    ),
    bodyLarge: TextStyle(
      color: Colors.white,
      fontSize: 16,
    ), // Main message text
    bodyMedium: TextStyle(
      color: Colors.white70,
      fontSize: 14,
    ), // Dates/Timestamps
    labelSmall: TextStyle(color: Colors.blueAccent, fontSize: 12), // User names
    labelMedium: TextStyle(color: Colors.blueAccent, fontSize: 14), // User names
    labelLarge: TextStyle(color: Colors.blueAccent, fontSize: 16),
  );

  // 2. Setup the Colors
  final chatColors = ChatColors(
    primary: Color(0xFF004A7C), // Your message bubble (Darker Blue)
    onPrimary: Colors.white, // Text inside YOUR bubble (Must be light!)

    surface: Color(0xFF3F37C9), // The main background of the chat
    onSurface: Colors.white, // Text for messages from OTHERS

    surfaceContainer: Color(0xFF1A1A2E), // Input field background
    surfaceContainerLow: Colors.white12, // Subtle separators
    surfaceContainerHigh: Color(0xFF4361EE), // Send button or active highlights
  );

  final BorderRadiusGeometry chatShape = BorderRadius.circular(12.0);

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return (Center(
      child: Chat(
        theme: ChatTheme(
          colors: chatColors,
          typography: typography,
          shape: chatShape,
        ),
        backgroundColor: Color.fromARGB(0, 0, 0, 0),
        currentUserId: "user1",
        resolveUser: (UserID id) async {
          return User(id: id, name: 'John Doe');
        },
        chatController: _chatController,
        onMessageSend: (text) {
          _chatController.insertMessage(
            TextMessage(
              id: "${Random().nextInt(1000) + 1}",
              authorId: "user1",
              createdAt: DateTime.now().toUtc(),
              text: text,
            ),
          );
        },
      ),
    ));
  }
}
