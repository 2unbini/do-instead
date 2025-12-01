import 'package:do_instead/data/models/user_model.dart';
import 'package:do_instead/data/repositories/user_repository.dart';
import 'package:do_instead/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OnboardingState {
  final bool isLoading;
  OnboardingState({this.isLoading = false});
}

class OnboardingViewModel extends StateNotifier<OnboardingState> {
  final Ref _ref;

  OnboardingViewModel(this._ref) : super(OnboardingState());

  Future<void> completeOnboarding({required String name, required String goal}) async {
    state = OnboardingState(isLoading: true);
    try {
      final auth = _ref.read(authRepositoryProvider);
      final userRepo = _ref.read(userRepositoryProvider);

      // 1. 익명 로그인 (실제 앱에선 소셜 로그인 등 사용)
      final credential = await auth.signInAnonymously();
      final uid = credential.user!.uid;

      // 2. 유저 정보 저장
      final newUser = UserModel(id: uid, name: name, goal: goal);
      await userRepo.saveUser(newUser);

    } catch (e) {
      print('Onboarding Error: $e');
    } finally {
      state = OnboardingState(isLoading: false);
    }
  }
}

final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingState>((ref) => OnboardingViewModel(ref));
