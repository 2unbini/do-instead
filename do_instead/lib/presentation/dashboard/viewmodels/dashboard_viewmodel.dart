import 'package:do_instead/data/models/stats_model.dart';
import 'package:do_instead/data/repositories/stats_repository.dart';
import 'package:do_instead/providers/userid_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final dashboardStatsProvider = FutureProvider<StatsModel>((ref) async {
  final userId = ref.watch(userIdProvider);
  if (userId == null) throw Exception('User not logged in');

  final statsRepo = ref.read(statsRepositoryProvider);
  return statsRepo.fetchUserStats(userId);
});