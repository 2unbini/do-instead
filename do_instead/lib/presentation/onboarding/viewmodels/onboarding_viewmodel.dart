import 'package:do_instead/data/models/user_model.dart';
import 'package:do_instead/data/repositories/user_repository.dart';
import 'package:do_instead/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// 채팅 메시지 모델 (온보딩 전용)
class OnboardingMessage {
  final String text;
  final bool isUser;
  OnboardingMessage(this.text, this.isUser);
}

// 온보딩 상태
class OnboardingState {
  final List<OnboardingMessage> messages;
  final bool isLoading;
  final bool isCompleted; // 온보딩 완료 여부

  OnboardingState({
    this.messages = const [],
    this.isLoading = false,
    this.isCompleted = false,
  });

  OnboardingState copyWith({
    List<OnboardingMessage>? messages,
    bool? isLoading,
    bool? isCompleted,
  }) {
    return OnboardingState(
      messages: messages ?? this.messages,
      isLoading: isLoading ?? this.isLoading,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}

class OnboardingViewModel extends StateNotifier<OnboardingState> {
  final Ref _ref;
  
  // 임시 저장 데이터
  String _name = '';
  List<String> _hobbies = [];
  List<String> _badHabits = [];
  
  int _step = 0; // 진행 단계 (0:이름, 1:취미, 2:나쁜습관, 3:필요한것)

  OnboardingViewModel(this._ref) : super(OnboardingState()) {
    _startInterview();
  }

  void _startInterview() async {
    await Future.delayed(const Duration(milliseconds: 500));
    _addAiMessage("안녕하세요! 저는 당신의 습관 코치 두비Doobie 입니다. 👋");
    await Future.delayed(const Duration(milliseconds: 800));
    _addAiMessage("더 나은 하루를 설계하기 위해 몇 가지만 여쭤볼게요.\n먼저, 제가 당신을 어떻게 부르면 좋을까요?");
  }

  void _addAiMessage(String text) {
    state = state.copyWith(messages: [...state.messages, OnboardingMessage(text, false)]);
  }

  // 사용자 입력 처리
  Future<void> handleUserInput(String input) async {
    if (input.trim().isEmpty) return;

    // 1. 사용자 메시지 추가
    state = state.copyWith(messages: [...state.messages, OnboardingMessage(input, true)]);

    // 2. 단계별 로직
    switch (_step) {
      case 0: // 이름 입력 받음
        _name = input;
        _step++;
        await Future.delayed(const Duration(milliseconds: 600));
        _addAiMessage("반가워요, $_name님! 😊\n평소에 '하고 싶었지만' 시간이 없어서 못했던 취미가 있나요?\n(쉼표로 구분해서 알려주세요. 예: 독서, 러닝)");
        break;

      case 1: // 취미 입력 받음
        _hobbies = input.split(',').map((e) => e.trim()).toList();
        _step++;
        await Future.delayed(const Duration(milliseconds: 600));
        _addAiMessage("멋진 취미네요! 반대로, 줄이고 싶은 나쁜 습관이나 방해 요소는 무엇인가요?\n(예: 유튜브 쇼츠, 인스타, 눕기)");
        break;

      case 2: // 나쁜 습관 입력 받음
        _badHabits = input.split(',').map((e) => e.trim()).toList();
        _step++;
        await Future.delayed(const Duration(milliseconds: 600));
        _addAiMessage("그렇군요. 마지막으로, 현재 삶에서 가장 필요한 것은 무엇인가요?\n(예: 체력, 휴식, 집중력)");
        break;

      case 3: // 필요한 것 입력 받음 & 완료 처리
        final needs = input.split(',').map((e) => e.trim()).toList();
        await _completeOnboarding(needs);
        break;
    }
  }

  Future<void> _completeOnboarding(List<String> needs) async {
    state = state.copyWith(isLoading: true);
    _addAiMessage("정보를 저장하고 있어요... 💾");

    try {
      final auth = _ref.read(authRepositoryProvider);
      final userRepo = _ref.read(userRepositoryProvider);

      // 1. 익명 로그인 (이미 되어있을 수 있음)
      var user = auth.currentUser;
      if (user == null) {
        final credential = await auth.signInAnonymously();
        user = credential.user;
      }

      if (user != null) {
        // 2. UserProfile 생성 및 저장
        final newProfile = UserProfile(
          uid: user.uid,
          nickname: _name,
          hobbies: _hobbies,
          badHabits: _badHabits,
          needs: needs,
          createdAt: DateTime.now(),
        );

        await userRepo.saveUser(newProfile);
        
        state = state.copyWith(isLoading: false, isCompleted: true);
        // AuthGate가 상태 변화를 감지하여 자동으로 홈으로 이동할 것입니다.
      }
    } catch (e) {
      state = state.copyWith(isLoading: false);
      _addAiMessage("오류가 발생했어요. 다시 시도해주세요. 😥");
      print("Onboarding Error: $e");
    }
  }
}

final onboardingViewModelProvider =
    StateNotifierProvider<OnboardingViewModel, OnboardingState>((ref) => OnboardingViewModel(ref));