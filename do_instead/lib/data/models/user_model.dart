import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String nickname;
  final List<String> hobbies; // 대체 활동 (독서, 러닝 등)
  final List<String> badHabits; // 줄이고 싶은 습관 (SNS, 숏폼 등)
  final List<String> needs; // 현재 필요한 것 (휴식, 체력 등)
  final int dailyStepGoal;
  final int snsLimitMinutes;
  final DateTime createdAt;

  UserProfile({
    required this.uid,
    required this.nickname,
    required this.hobbies,
    required this.badHabits,
    required this.needs,
    this.dailyStepGoal = 8000,
    this.snsLimitMinutes = 30,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() => {
        'nickname': nickname,
        'preferences': {
          'hobbies': hobbies,
          'badHabits': badHabits,
          'needs': needs,
        },
        'settings': {
          'dailyStepGoal': dailyStepGoal,
          'snsLimitMinutes': snsLimitMinutes,
        },
        'createdAt': Timestamp.fromDate(createdAt),
      };

  factory UserProfile.fromMap(Map<String, dynamic> map, String id) {
    final prefs = map['preferences'] as Map<String, dynamic>? ?? {};
    final settings = map['settings'] as Map<String, dynamic>? ?? {};

    return UserProfile(
      uid: id,
      nickname: map['nickname'] ?? '',
      hobbies: List<String>.from(prefs['hobbies'] ?? []),
      badHabits: List<String>.from(prefs['badHabits'] ?? []),
      needs: List<String>.from(prefs['needs'] ?? []),
      dailyStepGoal: settings['dailyStepGoal'] ?? 8000,
      snsLimitMinutes: settings['snsLimitMinutes'] ?? 30,
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}