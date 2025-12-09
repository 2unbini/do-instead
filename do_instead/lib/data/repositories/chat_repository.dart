import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:do_instead/data/models/chat_message.dart';
import 'package:do_instead/data/models/suggested_activity.dart'; // import 필요

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<QueryDocumentSnapshot>> fetchMessages({
    required String userId,
    required int limit,
    DocumentSnapshot? startAfter,
  }) async {
    var query = _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .orderBy('timestamp', descending: true) // 최신순 정렬
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    final snapshot = await query.get();
    return snapshot.docs;
  }

  Future<DocumentReference> saveLog({
    required String userId,
    required String text,
    required bool isUser,
    Map<String, dynamic>? activityJson,
  }) async {
    return await _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .add({
      'text': text,
      'isUser': isUser,
      'activity': activityJson,
      'feedbackState': 'none',
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> saveFeedback({
    required String userId,
    required String activityTitle,
    required bool isLiked,
  }) async {
    await _firestore.collection('users').doc(userId).collection('feedback').add({
      'activity': activityTitle,
      'isLiked': isLiked,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateMessageState({
    required String userId,
    required String messageId,
    required FeedbackState newState,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(messageId)
          .update({'feedbackState': newState.name}); // Enum을 문자열로 저장
    } catch (e) {
      print("❌ 상태 업데이트 실패: $e");
    }
  }

  Future<void> updateMessageOption({
    required String userId,
    required String messageId,
    required String option,
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('conversations')
          .doc(messageId)
          .update({'selectedOption': option}); // DB에 저장
    } catch (e) {
      print("❌ 옵션 업데이트 실패: $e");
    }
  }

  // 🧠 RAG 핵심: 사용자가 '좋아요' 했던 활동 내역 가져오기 (Retriever)
  Future<List<String>> fetchLikedActivities(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('feedback')
          .where('isLiked', isEqualTo: true) // 사용자가 좋아했던 것만
          .orderBy('timestamp', descending: true)
          .limit(5) // 최근 5개만 기억
          .get();

      return snapshot.docs.map((doc) => doc['activity'] as String).toList();
    } catch (e) {
      print('Memory Fetch Error: $e');
      return [];
    }
  }
}

final chatRepositoryProvider = Provider((ref) => ChatRepository());