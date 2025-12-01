import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:do_instead/data/models/agent_models.dart';
import 'package:do_instead/data/services/agent_service.dart';
import 'package:do_instead/data/repositories/agent_repository.dart';
import 'package:uuid/uuid.dart';
import 'package:do_instead/data/models/message.dart';

// 서비스와 리포지토리도 Provider로 관리 (의존성 주입 효과)
final agentServiceProvider = Provider((ref) => AgentService());
final agentRepositoryProvider = Provider((ref) => AgentRepository());

// 채팅 상태 관리 (메시지 리스트 + 로딩 상태)
class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;

  ChatState({required this.messages, this.isLoading = false});

  ChatState copyWith({List<ChatMessage>? messages, bool? isLoading}) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ChatNotifier extends StateNotifier<ChatState> {
  final AgentService _service;
  final AgentRepository _repository;
  final String _userId = 'test_user_id'; // 실제 앱에선 Auth Provider에서 가져옴

  ChatNotifier(this._service, this._repository) : super(ChatState(messages: []));

  Future<void> sendMessage(String rawText) async {
    final text = rawText.trim();
    if (text.isEmpty) return;

    final userMsg = ChatMessage(
      id: const Uuid().v4(),
      text: text,
      isUser: true,
      timestamp: DateTime.now(),
    );

    final aiMsg = ChatMessage(
      id: const Uuid().v4(),
      text: '',
      isUser: false,
      timestamp: DateTime.now(),
    );

    // 1. UI 즉시 업데이트 (낙관적 업데이트)
    state = state.copyWith(
      messages: [...state.messages, userMsg, aiMsg],
      isLoading: true,
    );

    // 2. 사용자 로그 저장
    _repository.saveLog(userId: _userId, text: text, isUser: true);

    final history = _mapChatMessagesToAgentHistory(state.messages);
    final buffer = StringBuffer();

    try {
      // 3. AI 스트리밍 응답 처리
      await for (final chunk in _service.getResponse(text, history)) {
        if (chunk.isEmpty) continue;
        buffer.write(chunk);
        _updateMessageText(aiMsg.id, buffer.toString());
      }

      final finalText = buffer.isEmpty
          ? '답변을 생성하지 못했어요. 잠시 후 다시 시도해 주세요.'
          : buffer.toString();

      if (buffer.isEmpty) {
        _updateMessageText(aiMsg.id, finalText);
      }

      // 4. 로딩 상태 해제 + 최종 로그 저장
      state = state.copyWith(isLoading: false);
      _repository.saveLog(userId: _userId, text: finalText, isUser: false);
    } catch (e) {
      const errorText = '오류가 발생했습니다. 잠시 후 다시 시도해 주세요.';
      _updateMessageText(aiMsg.id, errorText);
      state = state.copyWith(isLoading: false);
    }
  }

  List<Message> _mapChatMessagesToAgentHistory(List<ChatMessage> messages) {
    return messages
        .map(
          (chatMsg) => Message(
            text: chatMsg.text,
            sender: chatMsg.isUser ? MessageSender.user : MessageSender.agent,
          ),
        )
        .toList();
  }

  void _updateMessageText(String id, String newText) {
    state = state.copyWith(
      messages: state.messages
          .map(
            (msg) => msg.id == id
                ? ChatMessage(
                    id: msg.id,
                    text: newText,
                    isUser: msg.isUser,
                    activity: msg.activity,
                    timestamp: msg.timestamp,
                  )
                : msg,
          )
          .toList(),
    );
  }

  // 피드백 처리 함수
  void sendFeedback(SuggestedActivity activity, bool isLiked) {
    _repository.saveFeedback(
      userId: _userId,
      activityTitle: activity.title,
      isLiked: isLiked,
    );
    // UI에서 피드백 반영 후 토스트 메시지 등을 띄우는 로직은 UI 쪽에서 처리
  }
}

// 최종적으로 UI가 구독할 Provider
final chatProvider = StateNotifierProvider<ChatNotifier, ChatState>((ref) {
  return ChatNotifier(
    ref.watch(agentServiceProvider),
    ref.watch(agentRepositoryProvider),
  );
});