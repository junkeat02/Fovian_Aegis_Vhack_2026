import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_application/services/ai_agent_client.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => ChatScreenState();
}

class ChatScreenState extends State<ChatScreen> {
  final AiAgentClient _aiClient = AiAgentClient();
  final _chatController = InMemoryChatController();

  // Unique ID for the temporary loading message
  static const String _loadingMessageId = "ai_loading_status";

  final typography = const ChatTypography(
    bodySmall: TextStyle(color: Colors.white, fontSize: 12),
    bodyLarge: TextStyle(color: Colors.white, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.white70, fontSize: 14),
    labelSmall: TextStyle(color: Colors.blueAccent, fontSize: 12),
    labelMedium: TextStyle(color: Colors.blueAccent, fontSize: 14),
    labelLarge: TextStyle(color: Colors.blueAccent, fontSize: 16),
  );

  final chatColors = const ChatColors(
    primary: Color(0xFF004A7C),
    onPrimary: Colors.white,
    surface: Color(0xFF3F37C9),
    onSurface: Colors.white,
    surfaceContainer: Color(0xFF1A1A2E),
    surfaceContainerLow: Colors.white12,
    surfaceContainerHigh: Color(0xFF4361EE),
  );

  @override
  void dispose() {
    _chatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Chat(
        theme: ChatTheme(
          colors: chatColors,
          typography: typography,
          shape: BorderRadius.circular(12.0),
        ),
        backgroundColor: Colors.transparent,
        currentUserId: "user1",
        resolveUser: (UserID id) async {
          if (id == 'agent_aegis')
            return const User(id: 'agent_aegis', name: 'Aegis AI');
          return const User(id: 'user1', name: 'Commander');
        },
        chatController: _chatController,
        onMessageSend: (text) async {
          // 1. Create the User Message
          final userMsg = TextMessage(
            id: "user_${DateTime.now().millisecondsSinceEpoch}",
            authorId: "user1",
            createdAt: DateTime.now().toUtc(),
            text: text,
          );
          _chatController.insertMessage(userMsg);

          // 2. Create and Insert the "Thinking" Placeholder
          final loadingMsg = TextMessage(
            id: _loadingMessageId,
            authorId: "agent_aegis",
            createdAt: DateTime.now().toUtc(),
            text: "Aegis is analyzing command...",
          );
          _chatController.insertMessage(loadingMsg);

          try {
            final String aiResponse = await _aiClient.sendCommand(text);

            // 3. REMOVE the placeholder (Using the object, not just ID)
            await _chatController.removeMessage(loadingMsg);

            // 4. Insert the real AI Response
            _chatController.insertMessage(
              TextMessage(
                id: "ai_${DateTime.now().millisecondsSinceEpoch}",
                authorId: "agent_aegis",
                createdAt: DateTime.now().toUtc(),
                text: aiResponse,
              ),
            );
          } catch (e) {
            // Cleanup if things go wrong
            await _chatController.removeMessage(loadingMsg);
            // ... insert error message ...
          }
        },
      ),
    );
  }
}
