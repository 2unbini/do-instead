import 'package:do_instead/presentation/dashboard/viewmodels/dashboard_viewmodel.dart';
import 'package:do_instead/providers/navindex_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(dashboardStatsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('대시보드')),
      body: statsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('에러 발생: $err')),
        data: (stats) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.timer_outlined, size: 80, color: Colors.blue),
                const SizedBox(height: 16),
                Text(
                  '${stats.savedMinutes}분',
                  style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
                ),
                const Text('절약한 스크린 타임', style: TextStyle(fontSize: 16, color: Colors.grey)),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: () {
                    // 채팅 탭(인덱스 1)으로 이동
                    ref.read(navIndexProvider.notifier).state = 1;
                  },
                  child: const Text('Doobie와 대화하러 가기'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}