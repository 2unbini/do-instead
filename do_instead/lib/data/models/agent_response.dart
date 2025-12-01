import 'package:do_instead/data/models/suggested_activity.dart';

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