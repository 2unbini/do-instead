import 'package:do_instead/models/message.dart';
import 'package:do_instead/services/app_usage_service.dart';
import 'package:do_instead/services/health_service.dart';
import 'package:do_instead/services/notification_service.dart';

class AgentService {
  final AppUsageService _appUsageService = AppUsageService();
  final HealthService _healthService = HealthService();
  final NotificationService _notificationService = NotificationService();

  Future<Message> getResponse(String message) async {
    await Future.delayed(const Duration(milliseconds: 800)); // Simulate thinking
    final lowerCaseMessage = message.toLowerCase();

    if (lowerCaseMessage.contains('test notification')) {
      await _notificationService.showTestNotification();
      return Message(sender: MessageSender.agent, text: 'I\'ve sent you a test notification!');
    }

    if (lowerCaseMessage.contains('usage') || lowerCaseMessage.contains('stats')) {
      final stats = await _appUsageService.getAppUsageStats();
      final statsText = stats.map((s) => '- ${s.appName}: ${s.usage.inHours}h ${s.usage.inMinutes.remainder(60)}m').join('\n');
      return Message(sender: MessageSender.agent, text: 'Here is your app usage for today:\n$statsText');
    }

    if (lowerCaseMessage.contains('health')) {
      final health = await _healthService.getHealthData();
      return Message(sender: MessageSender.agent, text: 'Here is your health data for today:\n- Steps: ${health.steps}\n- Sleep: ${health.sleep.inHours}h ${health.sleep.inMinutes.remainder(60)}m');
    }
    
    if (lowerCaseMessage.contains('hello') || lowerCaseMessage.contains('hi')) {
      return Message(sender: MessageSender.agent, text: 'Hello there! What can I do for you?');
    }

    if (lowerCaseMessage.contains('recommend') || lowerCaseMessage.contains('suggestion')) {
      // TODO: Implement smarter recommendation logic based on history
      // For now, just a simple recommendation
      final recommendationText = 'I recommend going for a walk or reading a book for 30 minutes.';
      return Message(
        sender: MessageSender.agent,
        text: recommendationText,
        isRecommendation: true,
      );
    }

    return Message(sender: MessageSender.agent, text: 'I am not sure how to respond to that yet. Try asking about "usage", "health", or for a "recommendation".');
  }
}
