// lib/services/ai_agent_client.dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class AiAgentClient {
  // Point this to your server.py's host and port
  static const String _agentUrl = 'http://127.0.0.1:8003/chat';
  

  Future<String> sendCommand(String text) async {
    try {
      final response = await http.post(
        Uri.parse(_agentUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'message': text}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['response'] ?? "No response from agent.";
      } else {
        return "Error: ${response.statusCode}";
      }
    } catch (e) {
      return "Failed to connect to AI Agent: $e";
    }
  }
}