import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveLog({
    required String userId,
    required String text,
    required bool isUser,
    Map<String, dynamic>? activityJson,
  }) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('conversations')
        .add({
      'text': text,
      'isUser': isUser,
      'activity': activityJson,
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
}

final chatRepositoryProvider = Provider((ref) => ChatRepository());