import 'package:do_instead/data/models/suggested_activity.dart';

enum FeedbackState { none, liked, disliked, inProgress, completed, retrying }

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final SuggestedActivity? activity;
  final DateTime timestamp;
  final FeedbackState feedbackState;
  final String? selectedOption;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.activity,
    required this.timestamp,
    this.feedbackState = FeedbackState.none,
    this.selectedOption,
  });

  // 상태 변경을 위한 copyWith
  ChatMessage copyWith({
    String? id,
    String? text,
    bool? isUser,
    SuggestedActivity? activity,
    DateTime? timestamp,
    FeedbackState? feedbackState,
    String? selectedOption,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      text: text ?? this.text,
      isUser: isUser ?? this.isUser,
      activity: activity ?? this.activity,
      timestamp: timestamp ?? this.timestamp,
      feedbackState: feedbackState ?? this.feedbackState,
      selectedOption: selectedOption ?? this.selectedOption
    );
  }
}
