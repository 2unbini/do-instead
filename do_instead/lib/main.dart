import 'package:do_instead/presentation/home/screens/home_screen.dart';
import 'package:do_instead/presentation/onboarding/screens/onboarding_screen.dart';
import 'package:do_instead/firebase_options.dart';
import 'package:do_instead/data/services/notification_service.dart';
import 'package:do_instead/data/services/storage_service.dart';
import 'package:flutter/material.dart';
import 'package:do_instead/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  // Ensure that plugin services are initialized.
  WidgetsFlutterBinding.ensureInitialized();

  // Firebase 초기화 (플랫폼별 설정 자동 적용)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  await dotenv.load(fileName: ".env");

  // Initialize services.
  final storageService = StorageService();
  final notificationService = NotificationService();
  await notificationService.init();

  final isOnboardingComplete = await storageService.isOnboardingComplete();
  final initialPage = isOnboardingComplete ? const HomeScreen() : const OnboardingScreen();

  runApp(ProviderScope(child: MyApp(home: initialPage)));
}