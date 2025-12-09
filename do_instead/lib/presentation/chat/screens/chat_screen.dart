import 'package:do_instead/presentation/chat/viewmodels/chat_viewmodel.dart';
import 'package:do_instead/presentation/chat/widgets/interactive_activity_card.dart';
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

  @override
  void initState() {
    super.initState();
    // 화면 진입 시 초기화 (대화 내역 불러오기 or 첫인사)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatViewModelProvider.notifier).initializeChat();
    });

    // 스크롤 리스너 (무한 스크롤)
    _scrollController.addListener(() {
      // 스크롤이 리스트의 끝(과거 메시지 쪽)에 도달했는지 감지
      if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
        ref.read(chatViewModelProvider.notifier).loadMoreMessages();
      }
    });
  }

    void _scrollIfNeeded(BuildContext context) {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;

    // reverse:true 이므로 pixels=0 이 시각적 바닥(최신 메시지)
    final double threshold = keyboardInset > 0 ? keyboardInset + 32 : 48;

    if (position.pixels <= threshold) {
      _scrollController.animateTo(
        0, // reverse:true에서 0이 바닥
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatViewModelProvider);
    final viewModel = ref.read(chatViewModelProvider.notifier);

        // 새 메시지가 늘었을 때만, 화면 바닥에 있을 때 자동 스크롤
    ref.listen(chatViewModelProvider, (previous, next) {
      if (next.messages.length > (previous?.messages.length ?? 0)) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollIfNeeded(context);
        });
      }
    });

    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              reverse: true,
              controller: _scrollController,
              itemCount: chatState.messages.length + (chatState.isLoadingMore ? 1 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              itemBuilder: (context, index) {
                if (index == chatState.messages.length) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(8.0),
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ));
                }

                final msg = chatState.messages[index];

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (msg.text.isNotEmpty)
                      _buildMessageBubble(msg.text, msg.isUser),
                    
                    if (msg.activity != null)
                      InteractiveActivityCard(
                        activity: msg.activity!,
                        feedbackState: msg.feedbackState,
                        selectedOption: msg.selectedOption,
                        onStart: () => viewModel.startActivity(msg.id),
                        onComplete: () => viewModel.completeActivity(msg.id, msg.activity!),
                        onRetry: (preference) => viewModel.requestAlternative(msg.id, msg.activity!, preference),
                      ),
                  ],
                );
              },
            ),
          ),
          if (chatState.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(minHeight: 2),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: '메시지 입력...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24)),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    ),
                    onSubmitted: (val) {
                      viewModel.sendMessage(val);
                      _controller.clear();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: Colors.blueAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: () {
                      viewModel.sendMessage(_controller.text);
                      _controller.clear();
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(String text, bool isUser) {
    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isUser ? Colors.blueAccent : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: isUser ? const Radius.circular(16) : const Radius.circular(2),
            bottomRight: isUser ? const Radius.circular(2) : const Radius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(color: isUser ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}