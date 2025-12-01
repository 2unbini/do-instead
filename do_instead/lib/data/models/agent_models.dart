class SuggestedActivity {
  final String title;
  final String type; // ex: 'physical', 'mindfulness'
  final int durationMinutes;

  SuggestedActivity({
    required this.title,
    required this.type,
    required this.durationMinutes,
  });

  factory SuggestedActivity.fromJson(Map<String, dynamic> json) {
    return SuggestedActivity(
      title: json['title'] ?? '활동',
      type: json['type'] ?? 'general',
      durationMinutes: json['duration'] ?? 5,
    );
  }
}

class AgentResponse {
  final String text;
  final SuggestedActivity? activity;

  AgentResponse({required this.text, this.activity});

  factory AgentResponse.fromJson(Map<String, dynamic> json) {
    return AgentResponse(
      text: json['text'] ?? '',
      activity: json['suggested_activity'] != null
          ? SuggestedActivity.fromJson(json['suggested_activity'])
          : null,
    );
  }
}

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final SuggestedActivity? activity; // 추천 활동이 포함된 메시지일 경우
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.activity,
    required this.timestamp,
  });
}