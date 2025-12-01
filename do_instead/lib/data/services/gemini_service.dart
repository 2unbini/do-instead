import 'dart:convert';

import 'package:do_instead/data/models/agent_response.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      // 개발 중 디버깅을 위해 로그 출력
      print('Warning: GEMINI_API_KEY is missing in .env');
    }

    const jsonSchema = '''
    {
      "text": "String, Supportive message.",
      "suggested_activity": {
        "title": "String, Activity name",
        "type": "String, physical/mindfulness/creative",
        "duration": "Integer, minutes"
      }
    }
    Response MUST be valid JSON. If no activity suggested, "suggested_activity": null.
    ''';

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey ?? '',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
      systemInstruction: Content.system(
        'You are "Doobie". Help users reduce screen time. '
        'Always respond in JSON format following this schema: $jsonSchema',
      ),
    );
  }

  Future<AgentResponse> sendMessage(String message) async {
    try {
      final content = [Content.text(message)];
      final response = await _model.generateContent(content);
      final responseText = response.text;

      if (responseText == null) throw Exception('No response');

      final jsonMap = jsonDecode(responseText);
      return AgentResponse.fromJson(jsonMap);
    } catch (e) {
      print('Gemini Error: $e');
      return AgentResponse(text: '잠시 연결이 원활하지 않아요. 다시 시도해주세요.');
    }
  }
}

final geminiServiceProvider = Provider((ref) => GeminiService());