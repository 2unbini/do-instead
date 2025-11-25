import 'package:do_instead/models/app_usage_stat.dart';
import 'package:do_instead/models/health_data.dart';
import 'package:do_instead/services/app_usage_service.dart';
import 'package:do_instead/services/health_service.dart';
import 'package:do_instead/features/reports/widgets/report_card.dart';
import 'package:flutter/material.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final AppUsageService _appUsageService = AppUsageService();
  final HealthService _healthService = HealthService();

  Future<Map<String, dynamic>>? _dataFuture;

  @override
  void initState() {
    super.initState();
    _dataFuture = _fetchData();
  }

  Future<Map<String, dynamic>> _fetchData() async {
    final usage = await _appUsageService.getAppUsageStats();
    final health = await _healthService.getHealthData();
    return {'usage': usage, 'health': health};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weekly Summary'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: Text('No data available.'));
          }

          final List<AppUsageStat> usageStats = snapshot.data!['usage'];
          final HealthData healthData = snapshot.data!['health'];

          return ListView(
            children: [
              ReportCard(
                title: 'App Usage',
                description: 'Here\'s a summary of your screen time on distracting apps this week.',
                onTap: () {},
              ),
              ...usageStats.map((stat) => ListTile(
                    title: Text(stat.appName),
                    trailing: Text('${stat.usage.inHours}h ${stat.usage.inMinutes.remainder(60)}m'),
                  )),
              const Divider(),
              ReportCard(
                title: 'Health & Activity',
                description: 'A look at your steps and sleep this week.',
                onTap: () {},
              ),
              ListTile(
                title: const Text('Total Steps'),
                trailing: Text('${healthData.steps}'),
              ),
              ListTile(
                title: const Text('Average Sleep'),
                trailing: Text('${healthData.sleep.inHours}h ${healthData.sleep.inMinutes.remainder(60)}m'),
              ),
            ],
          );
        },
      ),
    );
  }
}
