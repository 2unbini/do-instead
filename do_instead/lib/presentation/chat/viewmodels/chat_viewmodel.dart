import 'package:do_instead/data/models/chat_message.dart';
import 'package:do_instead/data/models/suggested_activity.dart';
import 'package:do_instead/data/repositories/chat_repository.dart';
import 'package:do_instead/data/services/gemini_service.dart';
import 'package:do_instead/providers/userid_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState({this.messages = const [], this.isLoading = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatViewModel extends StateNotifier<ChatState> {
  final Ref _ref;

  ChatViewModel(this._ref) : super(ChatState());

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;
    
    final userId = _ref.read(userIdProvider);
    if (userId == null) return; 

    final gemini = _ref.read(geminiServiceProvider);
    final chatRepo = _ref.read(chatRepositoryProvider);

    // 1. 사용자 메시지 UI 즉시 추가
    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMsg],
      isLoading: true,
    );

    // 2. DB 저장
    chatRepo.saveLog(userId: userId, text: text, isUser: true);

    try {
      // 3. AI 호출
      final response = await gemini.sendMessage(text);

      final aiMsg = ChatMessage(
        id: const Uuid().v4(),
        text: response.text,
        isUser: false,
        activity: response.activity,
        timestamp: DateTime.now(),
      );

      // 4. UI 업데이트
      state = state.copyWith(
        messages: [...state.messages, aiMsg],
        isLoading: false,
      );

      // 5. AI 로그 저장
      chatRepo.saveLog(
        userId: userId,
        text: response.text,
        isUser: false,
        activityJson: response.activity?.toJson(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('Chat Error: $e');
    }
  }

  void sendFeedback(SuggestedActivity activity, bool isLiked) {
    final userId = _ref.read(userIdProvider);
    if (userId == null) return;

    final chatRepo = _ref.read(chatRepositoryProvider);
    chatRepo.saveFeedback(
      userId: userId,
      activityTitle: activity.title,
      isLiked: isLiked,
    );
  }
}

final chatViewModelProvider =
    StateNotifierProvider<ChatViewModel, ChatState>((ref) => ChatViewModel(ref));
