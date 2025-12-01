import 'package:do_instead/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingViewModel {
  final Ref _ref;
  SettingViewModel(this._ref);

  Future<void> logout() async {
    await _ref.read(authRepositoryProvider).signOut();
    // 로그아웃 시 AuthState가 변경되어 자동으로 Onboarding으로 이동됨
  }
}

final settingViewModelProvider = Provider((ref) => SettingViewModel(ref));