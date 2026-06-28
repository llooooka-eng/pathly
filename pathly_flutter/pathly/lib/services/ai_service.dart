import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/goal.dart';

class AIService {
  static const String _baseUrl = 'https://api.anthropic.com/v1/messages';

  // في الإنتاج: احفظ المفتاح في متغيرات البيئة أو backend آمن
  static const String _apiKey = 'YOUR_ANTHROPIC_API_KEY';

  static Future<String> getDailyLesson(Goal goal) async {
    final prompt = _buildLessonPrompt(goal);
    return await _callClaude(prompt);
  }

  static Future<String> chat(String userMessage, Goal goal, List<Map<String, String>> history) async {
    final systemPrompt = _buildChatSystemPrompt(goal);
    final messages = [
      ...history.map((m) => {'role': m['role']!, 'content': m['content']!}),
      {'role': 'user', 'content': userMessage},
    ];
    return await _callClaude('', systemPrompt: systemPrompt, messages: messages);
  }

  static Future<String> getWeeklyInsight(Goal goal) async {
    final prompt = '''
أنت مدرب شخصي ذكي لتطبيق Pathly.
المستخدم يعمل على هدف: ${goal.title}
التقدم الحالي: ${(goal.progress * 100).toStringAsFixed(0)}%
أيام متواصلة: ${goal.currentStreak}

اكتب رسالة تحفيزية قصيرة (جملتان فقط) بالعربية تناسب أداءه هذا الأسبوع.
كن مباشراً وعملياً، لا تكن مبالغاً في المديح.
''';
    return await _callClaude(prompt);
  }

  static Future<String> _callClaude(
    String userPrompt, {
    String? systemPrompt,
    List<Map<String, String>>? messages,
  }) async {
    try {
      final body = {
        'model': 'claude-sonnet-4-6',
        'max_tokens': 500,
        if (systemPrompt != null) 'system': systemPrompt,
        'messages': messages ?? [
          {'role': 'user', 'content': userPrompt},
        ],
      };

      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'x-api-key': _apiKey,
          'anthropic-version': '2023-06-01',
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['content'][0]['text'] as String;
      } else {
        return 'حدث خطأ في الاتصال. حاول مجدداً.';
      }
    } catch (e) {
      return 'تعذّر الاتصال بالمساعد. تحقق من الإنترنت.';
    }
  }

  static String _buildLessonPrompt(Goal goal) {
    return '''
أنت مساعد تعليمي لتطبيق Pathly.
الهدف: ${goal.title} — ${goal.description}
اليوم رقم: ${goal.totalDays + 1}

أعطِ درساً يومياً قصيراً جداً (جملة أو مفهوم واحد) يناسب هذا اليوم في المسار.
اكتب بصيغة:
الدرس: [المحتوى]
الترجمة: [بالعربية إن لزم]
تمرين: [نشاط بسيط للتطبيق]
''';
  }

  static String _buildChatSystemPrompt(Goal goal) {
    return '''
أنت مساعد تدريبي ذكي في تطبيق Pathly.
هدف المستخدم الحالي: ${goal.title}
التقدم: ${(goal.progress * 100).toStringAsFixed(0)}% — يوم ${goal.currentStreak}

قواعدك:
- تحدث بالعربية أساساً، لكن استخدم لغة الهدف عند التدريب
- كن مشجعاً لكن مباشراً
- ردودك قصيرة ومركزة (لا تزيد على 3 جمل)
- اقترح دائماً التالي: "الآن جرّب..."
''';
  }
}
