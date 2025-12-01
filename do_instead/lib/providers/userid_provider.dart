import 'package:do_instead/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final userIdProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).value?.uid;
});
