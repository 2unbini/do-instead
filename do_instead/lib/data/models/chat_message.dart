import 'package:do_instead/data/models/suggested_activity.dart';

class ChatMessage {
  final String id;
  final String text;
  final bool isUser;
  final SuggestedActivity? activity;
  final DateTime timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.isUser,
    this.activity,
    required this.timestamp,
  });
}