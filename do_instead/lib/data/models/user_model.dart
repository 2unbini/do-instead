import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String name;
  final String goal;

  UserModel({required this.id, required this.name, required this.goal});

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'goal': goal,
        'createdAt': FieldValue.serverTimestamp(),
      };

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      goal: json['goal'] ?? '',
    );
  }
}