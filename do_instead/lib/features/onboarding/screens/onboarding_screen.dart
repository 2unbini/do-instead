import 'package:do_instead/features/home/home_screen.dart';
import 'package:do_instead/features/onboarding/widgets/goal_input.dart';
import 'package:do_instead/features/onboarding/widgets/onboarding_page.dart';
import 'package:do_instead/services/storage_service.dart';
import 'package:flutter/material.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  String _goals = '';

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      const OnboardingPage(
        title: 'Welcome to\nDo Instead!',
        description: 'Your personal agent to help you build better habits and live a more energetic life.',
      ),
      const OnboardingPage(
        title: 'What apps are distracting you?',
        description: 'Select the apps you want to use less. We will help you monitor your usage.',
        child: Center(child: Text('[App Selection Widget Placeholder]')),
      ),
      OnboardingPage(
        title: 'What are your goals?',
        description: 'What new habits or activities would bring more energy to your life? (e.g., read a book, exercise, learn a new language)',
        child: GoalInput(
          onChanged: (value) {
            _goals = value;
          },
        ),
      ),
    ];
  }

  void _onPageChanged(int page) {
    setState(() {
      _currentPage = page;
    });
  }

  void _completeOnboarding() async {
    final storageService = StorageService();
    // Save the user's goals and mark onboarding as complete.
    await storageService.saveUserGoals(_goals);
    await storageService.saveOnboardingComplete(true);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  void _onNext() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _completeOnboarding();
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: _completeOnboarding,
            child: const Text('Skip'),
          ),
        ],
      ),
      body: PageView(
        controller: _pageController,
        onPageChanged: _onPageChanged,
        children: _pages,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _onNext,
        label: Text(_currentPage < _pages.length - 1 ? 'Next' : 'Get Started'),
        icon: Icon(_currentPage < _pages.length - 1 ? Icons.arrow_forward : Icons.check),
      ),
    );
  }
}
