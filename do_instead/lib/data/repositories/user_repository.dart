import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_instead/data/models/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser(UserModel user) async {
    await _firestore.collection('users').doc(user.id).set(user.toJson());
  }
}

final userRepositoryProvider = Provider((ref) => UserRepository());