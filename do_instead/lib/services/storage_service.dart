import 'dart:convert';
import 'package:do_instead/models/recommendation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _onboardingCompleteKey = 'onboarding_complete';
  static const String _userGoalsKey = 'user_goals';
  static const String _recommendationHistoryKey = 'recommendation_history';

  Future<void> saveOnboardingComplete(bool complete) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_onboardingCompleteKey, complete);
  }

  Future<bool> isOnboardingComplete() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_onboardingCompleteKey) ?? false;
  }

  Future<void> saveUserGoals(String goals) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userGoalsKey, goals);
  }

  Future<String> getUserGoals() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_userGoalsKey) ?? '';
  }

  Future<void> saveRecommendation(Recommendation recommendation) async {
    final prefs = await SharedPreferences.getInstance();
    final history = await getRecommendationHistory();
    history.add(recommendation);
    final encoded = jsonEncode(history.map((r) => r.toJson()).toList());
    await prefs.setString(_recommendationHistoryKey, encoded);
  }

  Future<List<Recommendation>> getRecommendationHistory() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getString(_recommendationHistoryKey);
    if (encoded == null) {
      return [];
    }
    final decoded = jsonDecode(encoded) as List;
    return decoded.map((item) => Recommendation.fromJson(item)).toList();
  }
}
