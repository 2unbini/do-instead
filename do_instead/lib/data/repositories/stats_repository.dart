import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:do_instead/data/models/stats_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StatsRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 실제 앱에서는 activities 컬렉션을 쿼리하여 계산하거나, 별도 stats 문서를 읽습니다.
  Future<StatsModel> fetchUserStats(String userId) async {
    // MVP용 더미 로직: 나중에 실제 Firestore 연동 필요
    return StatsModel(savedMinutes: 45, totalActivities: 3);
  }
}

final statsRepositoryProvider = Provider((ref) => StatsRepository());