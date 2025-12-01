import 'package:do_instead/presentation/settings/viewmodels/settings_viewmodel.dart';
import 'package:do_instead/providers/userid_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingTab extends ConsumerWidget {
  const SettingTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.read(settingViewModelProvider);
    final userId = ref.watch(userIdProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('설정')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const ListTile(
            leading: Icon(Icons.person),
            title: Text('내 계정'),
            subtitle: Text('프로필 수정 및 목표 설정'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('UserID (Debug)'),
            subtitle: Text(userId ?? 'Not logged in'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('로그아웃', style: TextStyle(color: Colors.red)),
            onTap: () async {
              await viewModel.logout();
              // 로그아웃 시 AuthGate에 의해 자동으로 Onboarding으로 전환됨
            },
          ),
        ],
      ),
    );
  }
}