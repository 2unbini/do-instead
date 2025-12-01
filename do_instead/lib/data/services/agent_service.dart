import 'package:do_instead/data/models/message.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class AgentService {
  final GenerativeModel _model;

  AgentService()
      : _model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: dotenv.get("GEMINI_API_KEY"),
          systemInstruction: Content.system(
            'You are "Doobie", a friendly and encouraging AI assistant for the "doInstead" app. Your primary goal is to help users achieve their self-improvement goals.',
          ),
        );

  List<Content> _mapHistoryToContent(List<Message> history) {
    return history.map((m) {
      final role = m.sender == MessageSender.user ? 'user' : 'model';
      return Content(role, [TextPart(m.text)]);
    }).toList();
  }

  Stream<String> getResponse(String message, List<Message> history) {
    try {
      final conversationContents = _mapHistoryToContent(history);

      final taskInstruction = '''
        
**User's Goal:** "I want to reduce my screen time and be more active."

**Your Task:**
1. Acknowledge the user's message.
2. Provide a supportive and encouraging response.
3. If appropriate, suggest a simple, actionable "instead" activity.
4. Keep your responses concise.
''';

      // 사용자의 메시지에 태스크 지시사항을 덧붙여서 보냅니다.
      // 하나의 Content 안에 여러 개의 TextPart를 담을 수 있습니다.
      final currentMessageContent = Content('user', [
        TextPart(message),
        TextPart(taskInstruction),
      ]);

      conversationContents.add(currentMessageContent);

      final responseStream = _model.generateContentStream(conversationContents);

      return responseStream.map((response) {
        return response.text ?? '';
      }).where((text) => text.isNotEmpty);
    } catch (e) {
      print('AgentService Error: $e');
      return Stream.value('죄송합니다. 오류가 발생했습니다: $e');
    }
  }
}