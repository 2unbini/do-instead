import 'package:uuid/uuid.dart';

enum MessageSender {
  user,
  agent,
}

class Message {
  Message({
    required this.text,
    required this.sender,
    this.isRecommendation = false,
  }) : id = const Uuid().v4();

  final String id;
  String text;
  final MessageSender sender;
  final bool isRecommendation;
}
