class SuggestedActivity {
  final String title;
  final String type; // 예: physical, mindfulness
  final int durationMinutes;

  SuggestedActivity({
    required this.title,
    required this.type,
    required this.durationMinutes,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'type': type,
        'duration': durationMinutes, // JSON 키 매칭 주의
      };

  factory SuggestedActivity.fromJson(Map<String, dynamic> json) {
    return SuggestedActivity(
      title: json['title'] ?? '활동',
      type: json['type'] ?? 'general',
      durationMinutes: json['duration'] ?? 5,
    );
  }
}