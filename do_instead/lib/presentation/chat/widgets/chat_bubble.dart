import 'package:do_instead/data/models/message.dart';
import 'package:flutter/material.dart';

class ChatBubble extends StatefulWidget {
  const ChatBubble({
    super.key,
    required this.message,
    this.onFeedback,
  });

  final Message message;
  final Function(String messageId, bool success)? onFeedback;

  @override
  State<ChatBubble> createState() => _ChatBubbleState();
}

class _ChatBubbleState extends State<ChatBubble> {
  bool _feedbackGiven = false;

  @override
  Widget build(BuildContext context) {
    final isUser = widget.message.sender == MessageSender.user;
    final theme = Theme.of(context);
    final bubbleColor = isUser
        ? theme.colorScheme.primaryContainer
        : theme.colorScheme.secondaryContainer;
    final textColor = isUser
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSecondaryContainer;

    return Column(
      crossAxisAlignment:
          isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.7,
          ),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          decoration: BoxDecoration(
            color: bubbleColor,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(
            widget.message.text,
            style: TextStyle(color: textColor),
          ),
        ),
        if (widget.message.isRecommendation && !_feedbackGiven)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.check, color: Colors.green),
                  label: const Text('I did it!'),
                  onPressed: () {
                    widget.onFeedback?.call(widget.message.id, true);
                    setState(() {
                      _feedbackGiven = true;
                    });
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.close, color: Colors.red),
                  label: const Text('I couldn\'t'),
                  onPressed: () {
                    widget.onFeedback?.call(widget.message.id, false);
                    setState(() {
                      _feedbackGiven = true;
                    });
                  },
                ),
              ],
            ),
          )
      ],
    );
  }
}
