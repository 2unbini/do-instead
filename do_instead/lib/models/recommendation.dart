enum RecommendationStatus { success, failure }

class Recommendation {
  const Recommendation({
    required this.text,
    required this.status,
    required this.timestamp,
  });

  final String text;
  final RecommendationStatus status;
  final DateTime timestamp;

  // Methods for serialization, if needed later for a more robust storage
  Map<String, dynamic> toJson() => {
        'text': text,
        'status': status.index,
        'timestamp': timestamp.toIso8601String(),
      };

  factory Recommendation.fromJson(Map<String, dynamic> json) => Recommendation(
        text: json['text'],
        status: RecommendationStatus.values[json['status']],
        timestamp: DateTime.parse(json['timestamp']),
      );
}
