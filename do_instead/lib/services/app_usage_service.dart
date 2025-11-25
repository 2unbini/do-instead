import 'package:do_instead/models/app_usage_stat.dart';

class AppUsageService {
  // In a real app, this would use a platform-specific package
  // to get the actual app usage data.
  Future<List<AppUsageStat>> getAppUsageStats() async {
    // Simulate a network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return some hardcoded data
    return [
      const AppUsageStat(appName: 'Instagram', usage: Duration(hours: 2, minutes: 30)),
      const AppUsageStat(appName: 'TikTok', usage: Duration(hours: 1, minutes: 45)),
      const AppUsageStat(appName: 'YouTube', usage: Duration(hours: 3, minutes: 10)),
    ];
  }
}
