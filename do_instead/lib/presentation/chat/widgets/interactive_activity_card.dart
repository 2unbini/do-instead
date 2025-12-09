import 'package:do_instead/data/models/suggested_activity.dart';
import 'package:do_instead/data/models/chat_message.dart'; // FeedbackState 사용
import 'package:flutter/material.dart';

class InteractiveActivityCard extends StatelessWidget {
  final SuggestedActivity activity;
  final FeedbackState feedbackState;
  final String? selectedOption;
  final VoidCallback onStart;
  final VoidCallback onComplete;
  final Function(String) onRetry; // "easier", "indoor", "short"

  const InteractiveActivityCard({
    super.key,
    required this.activity,
    required this.feedbackState,
    required this.selectedOption,
    required this.onComplete,
    required this.onRetry,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = feedbackState == FeedbackState.completed;
    final isInProgress = feedbackState == FeedbackState.inProgress;
    final isRetrying = feedbackState == FeedbackState.retrying;
    final hasSelectedOption = selectedOption != null;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isCompleted ? Colors.green[50] : Colors.white,
        border: Border.all(
          color: isCompleted
              ? Colors.green
              : Colors.blueAccent.withOpacity(0.3),
          width: isCompleted ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 헤더
          Row(
            children: [
              Icon(
                isCompleted ? Icons.check_circle : Icons.flash_on,
                color: isCompleted ? Colors.green : Colors.amber,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                isCompleted ? '미션 완료!' : 'Doobie의 제안',
                style: TextStyle(
                  color: isCompleted ? Colors.green[800] : Colors.grey[600],
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 활동 내용
          Text(
            activity.title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            '${activity.durationMinutes}분 • ${activity.type}',
            style: TextStyle(color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),

          // 액션 버튼 영역 (상태에 따라 다르게 표시)
          if (isCompleted)
            const Center(
              child: Text(
                "멋져요! 해내셨군요 🎉",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          else if (isRetrying)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else if (hasSelectedOption)
            Center(
              child: Text(
                "다른 제안을 요청했어요 💬",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            )
        else if (isInProgress) // ✅ 진행 중 상태 UI
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          "${activity.durationMinutes}분 동안 집중해보세요!",
                          style: TextStyle(color: Colors.blue[800], fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: onComplete, // 누르면 완료 처리
                  icon: const Icon(Icons.check),
                  label: const Text("다 했어요!"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 1. 완료 버튼
                ElevatedButton(
                  onPressed: onComplete,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text('지금 바로 시작하기 🚀'),
                ),
                const SizedBox(height: 12),

                // 2. 대안 선택 (칩 형태)
                const Text(
                  "지금은 좀 힘든가요?",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    _buildOptionChip('더 쉬운 거 🧘', 'easier'),
                    _buildOptionChip('집에서 🏠', 'indoor'),
                    _buildOptionChip('짧게 5분만 ⏱️', 'short'),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildOptionChip(String label, String value) {
    return ActionChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      backgroundColor: Colors.grey[100],
      onPressed: () => onRetry(value),
    );
  }
}
