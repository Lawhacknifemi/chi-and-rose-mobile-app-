import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_app/composition_root/repositories/health_repository.dart';

part 'ai_chat_provider.g.dart';

class AiChatMessage {
  final String content;
  final bool isUser;
  final DateTime timestamp;

  AiChatMessage({
    required this.content,
    required this.isUser,
    required this.timestamp,
  });

  Map<String, String> toMap() {
    return {
      'role': isUser ? 'user' : 'model',
      'content': content,
    };
  }
}

@riverpod
class AiChat extends _$AiChat {
  @override
  List<AiChatMessage> build() {
    return [];
  }

  Future<void> sendMessage(String text) async {
    final userMessage = AiChatMessage(
      content: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    // Update state to show user message immediately
    state = [...state, userMessage];

    try {
      final repository = ref.read(healthRepositoryProvider);
      
      // Convert history for the API
      final messages = state.map((m) => m.toMap()).toList();
      
      final response = await repository.chat(messages);
      
      final aiMessage = AiChatMessage(
        content: response,
        isUser: false,
        timestamp: DateTime.now(),
      );
      
      state = [...state, aiMessage];
    } catch (e) {
      final errorMessage = AiChatMessage(
        content: "Sorry, I'm having trouble connecting. Could you please try again?",
        isUser: false,
        timestamp: DateTime.now(),
      );
      state = [...state, errorMessage];
    }
  }

  Future<void> loadIntro() async {
    // Only load intro if the chat is empty
    if (state.isNotEmpty) return;

    try {
      final repository = ref.read(healthRepositoryProvider);
      final response = await repository.getIntro();
      
      if (response.isNotEmpty) {
        final introMessage = AiChatMessage(
          content: response,
          isUser: false,
          timestamp: DateTime.now(),
        );
        state = [introMessage];
      }
    } catch (e) {
      debugPrint('Error loading AI intro: $e');
    }
  }

  void clearChat() {
    state = [];
  }
}
