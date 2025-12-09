import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_instead/data/models/chat_message.dart';
import 'package:do_instead/data/models/suggested_activity.dart'; // import 확인
import 'package:do_instead/data/models/user_model.dart';
import 'package:do_instead/data/repositories/chat_repository.dart';
import 'package:do_instead/data/services/gemini_service.dart';
import 'package:do_instead/providers/userid_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatState {
  final List<ChatMessage> messages;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;

  final DocumentSnapshot? lastDoc;

  ChatState({
    this.messages = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.lastDoc,
  });

  ChatState copyWith({
    List<ChatMessage>? messages,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    DocumentSnapshot? lastDoc,
  }) {
    return ChatState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      lastDoc: lastDoc ?? this.lastDoc, // null을 명시적으로 전달할 경우 고려 필요하지만 여기선 간단히
    );
  }
}

class ChatViewModel extends StateNotifier<ChatState> {
  final Ref _ref;
  static const int _limit = 20;

  ChatViewModel(this._ref) : super(ChatState());

Future<void> initializeChat() async {
    final userId = _ref.read(userIdProvider);
    if (userId == null) return;

    if (state.messages.isNotEmpty) return;

    state = state.copyWith(isLoading: true);

    try {
      final repo = _ref.read(chatRepositoryProvider);
      final docs = await repo.fetchMessages(userId: userId, limit: _limit);
      
      final messages = _mapDocsToMessages(docs);

      state = state.copyWith(
        messages: messages,
        isLoading: false,
        hasMore: docs.length == _limit,
        lastDoc: docs.isNotEmpty ? docs.last : null,
      );
      
      if (docs.isEmpty) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
            
        if (userDoc.exists) {
          final userProfile = UserProfile.fromMap(userDoc.data()!, userDoc.id);
          await _handleInteraction(() async {
            final gemini = _ref.read(geminiServiceProvider);
            return await gemini.generateWelcomeMessage(userProfile);
          });
        }
      }
    } catch (e) {
      print("Init Chat Error: $e");
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> loadMoreMessages() async {
    if (state.isLoadingMore || !state.hasMore) return;

    final userId = _ref.read(userIdProvider);
    if (userId == null) return;

    state = state.copyWith(isLoadingMore: true);

    try {
      final repo = _ref.read(chatRepositoryProvider);
      final docs = await repo.fetchMessages(
        userId: userId, 
        limit: _limit, 
        startAfter: state.lastDoc,
      );

      final newMessages = _mapDocsToMessages(docs);

      state = state.copyWith(
        messages: [...state.messages, ...newMessages], // 기존 목록 뒤에 추가
        isLoadingMore: false,
        hasMore: docs.length == _limit,
        lastDoc: docs.isNotEmpty ? docs.last : state.lastDoc,
      );
    } catch (e) {
      print("Load More Error: $e");
      state = state.copyWith(isLoadingMore: false);
    }
  }

List<ChatMessage> _mapDocsToMessages(List<QueryDocumentSnapshot> docs) {
    return docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      
      SuggestedActivity? activity;
      if (data['activity'] != null) {
        activity = SuggestedActivity.fromJson(data['activity']);
      }

      // DB에 저장된 상태 문자열을 Enum으로 변환 (저장이 안 되어있으면 none)
      FeedbackState feedbackState = FeedbackState.none;
      if (data['feedbackState'] != null) {
        final stateStr = data['feedbackState'] as String;
        feedbackState = FeedbackState.values.firstWhere(
          (e) => e.name == stateStr, 
          orElse: () => FeedbackState.none
        );
      }

      return ChatMessage(
        id: doc.id,
        text: data['text'] ?? '',
        isUser: data['isUser'] ?? true,
        activity: activity,
        timestamp: (data['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
        feedbackState: feedbackState,
        selectedOption: data['selectedOption'],
      );
    }).toList();
  }

  Future<List<String>> _retrieveMemory() async {
    final userId = _ref.read(userIdProvider);
    if (userId == null) return [];
    return await _ref.read(chatRepositoryProvider).fetchLikedActivities(userId);
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    final memory = await _retrieveMemory();

    await _handleInteraction(() async {
      final gemini = _ref.read(geminiServiceProvider);
      return await gemini.sendMessage(text, memory: memory);
    }, userText: text);
  }
  
Future<void> requestAlternative(
    String messageId,
    SuggestedActivity oldActivity,
    String preference,
  ) async {
    final userId = _ref.read(userIdProvider);
    if (userId == null) return;

    state = state.copyWith(
      messages: state.messages.map((msg) {
        if (msg.id == messageId) {
          return msg.copyWith(
            feedbackState: FeedbackState.retrying,
            selectedOption: preference,
          );
        }
        return msg;
      }).toList(),
    );

    // 2. DB 영구 저장: 앱 껐다 켜도 기억하도록
    _ref.read(chatRepositoryProvider).updateMessageOption(
      userId: userId, 
      messageId: messageId, 
      option: preference
    );

    // 3. AI 호출 (기존 로직)
    final memory = await _retrieveMemory();

    await _handleInteraction(() async {
      final gemini = _ref.read(geminiServiceProvider);
      return await gemini.regenerateSuggestion(
        lastActivity: oldActivity.title,
        feedbackType: preference,
        memory: memory,
      );
    });

    // 4. 로딩 종료 처리
    _updateMessageState(messageId, FeedbackState.disliked);
  }

Future<void> startActivity(String messageId) async {
    final userId = _ref.read(userIdProvider);
    if (userId == null) return;

    // UI 업데이트
    _updateMessageState(messageId, FeedbackState.inProgress);

    // DB 업데이트
    _ref.read(chatRepositoryProvider).updateMessageState(
      userId: userId, 
      messageId: messageId, 
      newState: FeedbackState.inProgress
    );
  }

Future<void> completeActivity(String messageId, SuggestedActivity activity) async {
    final userId = _ref.read(userIdProvider);
    if (userId == null) return;

    _updateMessageState(messageId, FeedbackState.completed);
    
    _ref.read(chatRepositoryProvider).updateMessageState(
      userId: userId, 
      messageId: messageId, 
      newState: FeedbackState.completed
    );

    // 칭찬 메시지 생성
    await _handleInteraction(() async {
      final gemini = _ref.read(geminiServiceProvider);
      return await gemini.celebrateCompletion(activity.title);
    });
  }

  void _updateMessageState(String messageId, FeedbackState newState) {
    state = state.copyWith(
      messages: state.messages.map((msg) {
        if (msg.id == messageId) {
          return msg.copyWith(feedbackState: newState);
        }
        return msg;
      }).toList(),
    );
  }

  Future<void> _handleInteraction(Future<dynamic> Function() aiCall, {String? userText}) async {
    final userId = _ref.read(userIdProvider);
    if (userId == null) return;
    final chatRepo = _ref.read(chatRepositoryProvider);

    // 사용자 메시지 처리
    if (userText != null) {
      // 1. DB에 먼저 저장해서 ID 확보 (await)
      final docRef = await chatRepo.saveLog(
        userId: userId,
        text: userText,
        isUser: true,
      );

      final userMsg = ChatMessage(
        id: docRef.id, // ✅ 실제 Firestore ID 사용
        text: userText,
        isUser: true,
        timestamp: DateTime.now(),
      );
      
      state = state.copyWith(
        messages: [userMsg, ...state.messages],
        isLoading: true,
      );
    } else {
      state = state.copyWith(isLoading: true);
    }

    try {
      final response = await aiCall();

      // AI 메시지 처리
      // 1. DB에 먼저 저장해서 ID 확보
      final docRef = await chatRepo.saveLog(
        userId: userId,
        text: response.text,
        isUser: false,
        activityJson: response.activity?.toJson(),
      );

      // 2. 확보된 ID로 메시지 생성
      final aiMsg = ChatMessage(
        id: docRef.id, // ✅ 실제 Firestore ID 사용
        text: response.text,
        isUser: false,
        activity: response.activity,
        timestamp: DateTime.now(),
      );

      state = state.copyWith(
        messages: [aiMsg, ...state.messages],
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
      print('Chat Error: $e');
    }
  }
}

final chatViewModelProvider = StateNotifierProvider<ChatViewModel, ChatState>(
  (ref) => ChatViewModel(ref),
);
