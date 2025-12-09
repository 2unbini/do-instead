import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_instead/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // UserProfile 객체를 받아 저장하도록 수정
  Future<void> saveUser(UserProfile user) async {
    await _firestore.collection('users').doc(user.uid).set(user.toJson());
  }
}

final userRepositoryProvider = Provider((ref) => UserRepository());