import 'package:do_instead/features/chat/widgets/chat_bubble.dart';
import 'package:do_instead/models/message.dart';
import 'package:do_instead/models/recommendation.dart';
import 'package:do_instead/services/agent_service.dart';
import 'package:do_instead/services/storage_service.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final AgentService _agentService = AgentService();
  final StorageService _storageService = StorageService();
  final List<Message> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      Message(text: 'Hello! How can I help you today?', sender: MessageSender.agent),
    );
  }

  void _handleSendPressed() async {
    final text = _textController.text;
    if (text.isEmpty || _isLoading) return;

    _textController.clear();
    final userMessage = Message(text: text, sender: MessageSender.user);

    setState(() {
      _messages.add(userMessage);
      _isLoading = true;
    });

    final agentMessage = await _agentService.getResponse(text);

    setState(() {
      _messages.add(agentMessage);
      _isLoading = false;
    });
  }

  void _handleFeedback(String messageId, bool success) {
    final message = _messages.firstWhere((m) => m.id == messageId);

    final recommendation = Recommendation(
      text: message.text,
      status: success ? RecommendationStatus.success : RecommendationStatus.failure,
      timestamp: DateTime.now(),
    );
    _storageService.saveRecommendation(recommendation);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(success ? 'Great job! I\'ve noted your success.' : 'No worries. I\'ve noted that.'),
        backgroundColor: success ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Agent'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              reverse: true,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[_messages.length - 1 - index];
                return ChatBubble(
                  message: message,
                  onFeedback: _handleFeedback,
                );
              },
            ),
          ),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(),
            ),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            offset: const Offset(0, -1),
            blurRadius: 2,
            color: const Color.fromRGBO(0, 0, 0, 0.05),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: const InputDecoration.collapsed(
                  hintText: 'Send a message...',
                ),
                onSubmitted: (_) => _handleSendPressed(),
                enabled: !_isLoading,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _isLoading ? null : _handleSendPressed,
            ),
          ],
        ),
      ),
    );
  }
}
