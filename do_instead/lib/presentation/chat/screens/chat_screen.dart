import 'package:do_instead/presentation/chat/viewmodels/chat_viewmodel.dart';
import 'package:do_instead/presentation/chat/widgets/activity_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  final _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final viewModel = ref.read(chatViewModelProvider.notifier);

    // 메시지 추가 시 스크롤
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

    return Scaffold(
      appBar: AppBar(title: const Text('Doobie Chat')),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: chatState.messages.length,
              padding: const EdgeInsets.only(bottom: 16, top: 16),
              itemBuilder: (context, index) {
                final msg = chatState.messages[index];

                // 추천 활동 카드인 경우
                if (msg.activity != null) {
                  return Column(
                    children: [
                      if (msg.text.isNotEmpty)
                         _buildMessageBubble(msg.text, false),
                      ActivityCard(
                        activity: msg.activity!,
                        onLike: () => viewModel.sendFeedback(msg.activity!, true),
                        onDislike: () => viewModel.sendFeedback(msg.activity!, false),
                      ),
                    ],
                  );
                }

                return _buildMessageBubble(msg.text, msg.isUser);
              },
            ),
          ),
          if (chatState.isLoading)
            const LinearProgressIndicator(minHeight: 2),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: '메시지를 입력하세요...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (val) {
                      viewModel.sendMessage(val);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    viewModel.sendMessage(_controller.text);
                    _controller.clear();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return ListTile(
      title: Align(
        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? Colors.blue[100] : Colors.grey[200],
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft: isUser ? const Radius.circular(12) : const Radius.circular(0),
              bottomRight: isUser ? const Radius.circular(0) : const Radius.circular(12),
            ),
          ),
          child: Text(text),
        ),
      ),
    );
  }
}
