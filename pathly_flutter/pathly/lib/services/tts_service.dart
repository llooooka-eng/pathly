import 'package:flutter_tts/flutter_tts.dart';

/// خدمة تحويل النص إلى كلام (Text-to-Speech) لنطق الدروس وردود المساعد.
class TtsService {
  TtsService._();
  static final TtsService instance = TtsService._();

  final FlutterTts _tts = FlutterTts();
  bool _initialized = false;

  Future<void> _ensureInitialized() async {
    if (_initialized) return;
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    _initialized = true;
  }

  /// ينطق النص. إن مُرِّر [languageCode] ومتوفر في المحرك يُضبط قبل النطق.
  Future<void> speak(String text, {String? languageCode}) async {
    if (text.trim().isEmpty) return;
    await _ensureInitialized();
    if (languageCode != null) {
      final available = await _tts.isLanguageAvailable(languageCode);
      if (available == true) {
        await _tts.setLanguage(languageCode);
      }
    }
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
