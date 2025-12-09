// lib/data/services/gemini_service.dart

import 'dart:convert';
import 'package:do_instead/data/models/agent_response.dart';
import 'package:do_instead/data/models/user_model.dart'; // UserProfile
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class GeminiService {
  late final GenerativeModel _model;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      print('Warning: GEMINI_API_KEY is missing in .env');
    }

    const jsonSchema = '''
    {
      "text": "String, Supportive message in Korean.",
      "suggested_activity": {
        "title": "String, Activity name in Korean",
        "type": "String, physical/mindfulness/creative",
        "duration": "Integer, minutes"
      }
    }
    Response MUST be valid JSON. 
    ''';

    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey ?? '',
      generationConfig: GenerationConfig(
        responseMimeType: 'application/json',
      ),
      systemInstruction: Content.system(
        '너는 디지털 웰빙 코치 "Doobie"야. '
        '사용자가 스마트폰 사용을 줄이고 건강한 습관을 갖도록 도와줘. '
        '모든 대답은 사용자의 응답에 따른 언어(한국어면 한국어, 영어면 영어)로 해야 해. '
        '친근하고 격려하는 말투를 사용해. '
        '응답은 항상 다음 JSON 스키마를 따라야 해: $jsonSchema'
      ),
    );
  }

  Future<AgentResponse> sendMessage(String message, {List<String>? memory}) async {
    // 기억을 프롬프트에 증강 (Augmented)
    String memoryContext = "";
    if (memory != null && memory.isNotEmpty) {
      memoryContext = """
      [Memory - Activities the user liked in the past]
      ${memory.join(', ')}
      (Consider these preferences when suggesting, but prioritize the current context.)
      """;
    }

    final prompt = """
    $memoryContext
    User says: "$message"
    If user wants specific activity, you should suggest related action.
    """;

    return _generateContent(prompt);
  }

  Future<AgentResponse> regenerateSuggestion({
    required String lastActivity,
    required String feedbackType,
    List<String>? memory,
  }) async {
    String context = "";
    if (feedbackType == "easier") context = "더 쉬운 활동";
    if (feedbackType == "indoor") context = "집 안에서 할 수 있는 활동";
    if (feedbackType == "short") context = "5분 이내로 짧게 끝나는 활동";

    String memoryContext = "";
    if (memory != null && memory.isNotEmpty) {
      memoryContext = "참고: 사용자는 과거에 [${memory.join(', ')}] 활동들을 좋아했어.";
    }

    final prompt = '''
    $memoryContext
    사용자가 "$lastActivity" 제안에 이어서
    사용자는 "$context"을(를) 원해.
    만약 사용자가 "$lastActivity"에 대해 부정적인 반응이었거나 집 안에서 할 수 있는 활동, indoor를 선택한 경우 다른 활동을 제안해줘.
    만약 사용자가 "$lastActivity"에 대해 긍정적인 반응이었거나 무반응, 혹은 더 쉬운 활동(easier), 5분 이내로 짧게 끝나는 활동(short)을 선택한 경우 같은 맥락의 더 가벼운 활동을 추천해줘.
    ''';
    
    return _generateContent(prompt);
  }

  Future<AgentResponse> celebrateCompletion(String activityTitle) async {
    final prompt = '사용자가 "$activityTitle" 활동을 완료했어! 짧고 열정적인 칭찬 메시지를 보내줘. (추천 활동은 포함하지 마)';
    return _generateContent(prompt);
  }

  Future<AgentResponse> generateWelcomeMessage(UserProfile user) async {
    final hobbies = user.hobbies.join(', ');
    final habits = user.badHabits.join(', ');
    
    final prompt = '''
    사용자 이름: ${user.nickname}
    좋아하는 취미: $hobbies
    줄이고 싶은 습관: $habits
    
    사용자가 앱에 처음 접속했어. 
    1. 입력한 정보를 바탕으로 따뜻한 환영 인사를 해줘.
    2. 습관($habits)을 줄이고 취미($hobbies)를 시작할 수 있도록, 
       지금 당장 할 수 있는 아주 간단한 첫 번째 활동을 제안해줘.
    ''';
    return _generateContent(prompt);
  }

  Future<AgentResponse> _generateContent(String prompt) async {
    try {
      final content = [Content.text(prompt)];
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