import 'package:cloud_firestore/cloud_firestore.dart';

class AgentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 1. 대화 로그 저장
  Future<void> saveLog({
    required String userId,
    required String text,
    required bool isUser,
    Map<String, dynamic>? activityJson,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .add({
        'text': text,
        'isUser': isUser,
        'activity': activityJson, // 추천 활동이 있다면 저장
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('❌ Log Save Error: $e');
    }
  }

  // 2. 피드백 저장 (좋아요/싫어요) -> 나중에 AI 개인화에 쓰임
  Future<void> saveFeedback({
    required String userId,
    required String activityTitle,
    required bool isLiked,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).collection('feedback').add({
        'activity': activityTitle,
        'isLiked': isLiked,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('✅ Feedback saved: $activityTitle -> ${isLiked ? "Like" : "Dislike"}');
    } catch (e) {
      print('❌ Feedback Save Error: $e');
    }
  }
}