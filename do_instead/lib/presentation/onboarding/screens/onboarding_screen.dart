import 'package:do_instead/presentation/onboarding/viewmodels/onboarding_viewmodel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode(); // ✅ 키보드 제어용 노드

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  // 화면 맨 아래로 스크롤 (Standard List이므로 maxScrollExtent가 바닥)
  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

    void _scrollIfNeeded(BuildContext context) {
    if (!_scrollController.hasClients) return;

    final position = _scrollController.position;
    final keyboardInset = MediaQuery.of(context).viewInsets.bottom;
    final remaining = position.maxScrollExtent - position.pixels;

    // 키보드가 올라와 있으면 키보드 높이만큼, 아니면 기본 여유값(48)만큼만 남았을 때 스크롤
    final double threshold = keyboardInset > 0 ? keyboardInset + 32 : 48;

    if (remaining <= threshold) {
      _scrollController.animateTo(
        position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(onboardingViewModelProvider);
    final viewModel = ref.read(onboardingViewModelProvider.notifier);
    
        // ✅ 스크롤 및 키보드 자동화 로직
    ref.listen(onboardingViewModelProvider, (previous, next) {
      // 1. 메시지가 늘어났을 때만 실행
      if (next.messages.length > (previous?.messages.length ?? 0)) {
        // 2. 새 버블이 키보드에 가려지거나 거의 바닥일 때만 스크롤
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollIfNeeded(context);
        });

        // 3. AI가 말한 뒤(사용자 차례) 키보드 자동 활성화
        if (next.messages.isNotEmpty && !next.messages.last.isUser) {
          Future.delayed(const Duration(milliseconds: 600), () {
            // 온보딩이 끝나지 않았고 화면이 살아있다면
            if (mounted && !next.isCompleted) {
              _focusNode.requestFocus();
            }
          });
        }
      }
    });

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("시작하기"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // 1. 채팅 영역
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: state.messages.length,
              itemBuilder: (context, index) {
                final msg = state.messages[index];
                return _buildChatBubble(msg);
              },
            ),
          ),

          // 2. 로딩 인디케이터 (메시지 생성 중)
          if (state.isLoading)
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: LinearProgressIndicator(minHeight: 2), // 얇은 로딩바 추천
            ),

          // 3. 입력창 영역
          Container(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                )
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    focusNode: _focusNode, // ✅ FocusNode 연결
                    // 로딩 중이거나 완료되었으면 입력 막기
                    enabled: !state.isLoading && !state.isCompleted,
                    textInputAction: TextInputAction.send, // 키보드 엔터 키 모양 변경
                    decoration: InputDecoration(
                      hintText: "답변을 입력하세요...",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        viewModel.handleUserInput(value);
                        _controller.clear();
                        // 전송 후에도 포커스 유지 (연속 대화 느낌)
                        _focusNode.requestFocus();
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: state.isLoading || state.isCompleted 
                      ? Colors.grey 
                      : Colors.blueAccent,
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: state.isLoading || state.isCompleted
                        ? null
                        : () {
                            if (_controller.text.trim().isNotEmpty) {
                              viewModel.handleUserInput(_controller.text);
                              _controller.clear();
                              _focusNode.requestFocus();
                            }
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

  Widget _buildChatBubble(OnboardingMessage msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: msg.isUser ? Colors.blueAccent : Colors.grey[200],
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: msg.isUser ? const Radius.circular(16) : Radius.zero,
            bottomRight: msg.isUser ? Radius.zero : const Radius.circular(16),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: msg.isUser ? Colors.white : Colors.black87,
            fontSize: 15,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}