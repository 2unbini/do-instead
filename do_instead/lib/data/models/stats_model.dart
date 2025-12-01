class StatsModel {
  final int savedMinutes;
  final int totalActivities;

  StatsModel({required this.savedMinutes, required this.totalActivities});

  // 데이터가 없을 때 기본값
  factory StatsModel.empty() {
    return StatsModel(savedMinutes: 0, totalActivities: 0);
  }
}