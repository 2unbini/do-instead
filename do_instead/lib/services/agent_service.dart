import 'package:do_instead/models/message.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:do_instead/services/api_key.dart';

class AgentService {
  final GenerativeModel _model;

  AgentService()
      : _model = GenerativeModel(
          model: 'gemini-2.5-flash',
          apiKey: geminiApiKey,
          // SDK ^0.4.0 이상에서는 시스템 프롬프트를 모델 생성자에 직접 설정하는 것을 권장합니다.
          systemInstruction: Content.system(
            'You are "Doobie", a friendly and encouraging AI assistant for the "doInstead" app. Your primary goal is to help users achieve their self-improvement goals.',
          ),
        );

  // Message 리스트를 SDK의 Content 객체 리스트로 변환
  List<Content> _mapHistoryToContent(List<Message> history) {
    return history.map((m) {
      final role = m.sender == 'User' ? 'user' : 'model';
      return Content(role, [TextPart(m.text)]);
    }).toList();
  }

  Stream<String> getResponse(String message, List<Message> history) {
    try {
      // 1. 대화 기록 변환
      final conversationContents = _mapHistoryToContent(history);

      // 2. 이번 턴의 사용자 메시지와 태스크 지시사항 구성
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

      // 3. 스트림 응답 요청
      final responseStream = _model.generateContentStream(conversationContents);

      // 4. 응답 처리
      return responseStream.map((response) {
        return response.text ?? '';
      }).where((text) => text.isNotEmpty);
    } catch (e) {
      print('AgentService Error: $e');
      return Stream.value('죄송합니다. 오류가 발생했습니다: $e');
    }
  }
}