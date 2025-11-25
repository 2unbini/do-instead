import 'package:do_instead/features/home/home_screen.dart';
import 'package:do_instead/features/onboarding/screens/onboarding_screen.dart';
import 'package:do_instead/services/notification_service.dart';
import 'package:do_instead/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:do_instead/app/app.dart';

void main() async {
  // Ensure that plugin services are initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize services.
  final storageService = StorageService();
  final notificationService = NotificationService();
  await notificationService.init();

  final isOnboardingComplete = await storageService.isOnboardingComplete();
  final initialPage = isOnboardingComplete ? const HomeScreen() : const OnboardingScreen();

  runApp(MyApp(home: initialPage));
}