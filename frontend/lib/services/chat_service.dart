import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/api.dart';

class ChatMessage {
  final String role; // "user" or "assistant"
  final String content;

  ChatMessage({
    required this.role,
    required this.content,
  });

  Map<String, dynamic> toJson() => {
        'role': role,
        'content': content,
      };
}

class ChatResponse {
  final String response;
  final List<String> suggestedQuestions;

  ChatResponse({
    required this.response,
    required this.suggestedQuestions,
  });
}

class ChatService {
  Future<ChatResponse> sendMessage({
    required String landmarkName,
    required String landmarkInfo,
    required List<ChatMessage> conversationHistory,
    required String userMessage,
    String? userId,
  }) async {
    try {
      final uri = Uri.parse('${ApiConstants.baseUrl}/chat/');
      
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'landmark_name': landmarkName,
          'landmark_info': landmarkInfo,
          'conversation_history': conversationHistory.map((m) => m.toJson()).toList(),
          'user_message': userMessage,
          'user_id': userId,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ChatResponse(
          response: data['response'] as String,
          suggestedQuestions: List<String>.from(data['suggested_questions'] ?? []),
        );
      } else {
        throw Exception('Failed to get chat response: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}
