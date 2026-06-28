import 'package:flutter/material.dart';

// ─── Supported languages ────────────────────────────────────────────────────
enum AppLanguage {
  arabic,
  english,
  french,
  spanish,
  turkish,
  urdu,
  hindi,
  indonesian,
  malay,
  swahili,
}

// ─── Language metadata ───────────────────────────────────────────────────────
class LanguageInfo {
  final AppLanguage lang;
  final String name;         // اسم اللغة بلغتها الأصلية
  final String nameEn;       // الاسم بالإنجليزية
  final String flag;         // رمز العلم
  final Locale locale;
  final bool isRtl;

  const LanguageInfo({
    required this.lang,
    required this.name,
    required this.nameEn,
    required this.flag,
    required this.locale,
    this.isRtl = false,
  });

  static const List<LanguageInfo> all = [
    LanguageInfo(lang: AppLanguage.arabic,     name: 'العربية',    nameEn: 'Arabic',     flag: '🇸🇦', locale: Locale('ar'), isRtl: true),
    LanguageInfo(lang: AppLanguage.english,    name: 'English',    nameEn: 'English',    flag: '🇬🇧', locale: Locale('en')),
    LanguageInfo(lang: AppLanguage.french,     name: 'Français',   nameEn: 'French',     flag: '🇫🇷', locale: Locale('fr')),
    LanguageInfo(lang: AppLanguage.spanish,    name: 'Español',    nameEn: 'Spanish',    flag: '🇪🇸', locale: Locale('es')),
    LanguageInfo(lang: AppLanguage.turkish,    name: 'Türkçe',     nameEn: 'Turkish',    flag: '🇹🇷', locale: Locale('tr')),
    LanguageInfo(lang: AppLanguage.urdu,       name: 'اردو',       nameEn: 'Urdu',       flag: '🇵🇰', locale: Locale('ur'), isRtl: true),
    LanguageInfo(lang: AppLanguage.hindi,      name: 'हिंदी',       nameEn: 'Hindi',      flag: '🇮🇳', locale: Locale('hi')),
    LanguageInfo(lang: AppLanguage.indonesian, name: 'Indonesia',  nameEn: 'Indonesian', flag: '🇮🇩', locale: Locale('id')),
    LanguageInfo(lang: AppLanguage.malay,      name: 'Melayu',     nameEn: 'Malay',      flag: '🇲🇾', locale: Locale('ms')),
    LanguageInfo(lang: AppLanguage.swahili,    name: 'Kiswahili',  nameEn: 'Swahili',    flag: '🇰🇪', locale: Locale('sw')),
  ];

  static LanguageInfo fromLang(AppLanguage l) =>
      all.firstWhere((i) => i.lang == l);
}

// ─── Translations ─────────────────────────────────────────────────────────────
class AppStrings {
  final AppLanguage lang;
  const AppStrings(this.lang);

  // App
  String get appName => _t(ar: 'Pathly', en: 'Pathly');
  String get appTagline => _t(
    ar: 'مسارك نحو هدفك',
    en: 'Your path to your goal',
    fr: 'Votre chemin vers votre objectif',
    es: 'Tu camino hacia tu objetivo',
    tr: 'Hedefinize giden yolunuz',
    ur: 'آپ کا ہدف کی طرف راستہ',
    hi: 'अपने लक्ष्य की ओर आपका रास्ता',
    id: 'Jalur Anda menuju tujuan',
    ms: 'Laluan anda ke matlamat',
    sw: 'Njia yako kuelekea lengo lako',
  );

  // Unlock screen
  String get watchAd => _t(
    ar: 'شاهد إعلاناً واحداً',
    en: 'Watch one ad',
    fr: 'Regardez une publicité',
    es: 'Mira un anuncio',
    tr: 'Bir reklam izle',
    ur: 'ایک اشتہار دیکھیں',
    hi: 'एक विज्ञापन देखें',
    id: 'Tonton satu iklan',
    ms: 'Tonton satu iklan',
    sw: 'Tazama tangazo moja',
  );
  String get toUnlockApp => _t(
    ar: 'لتفتح التطبيق كاملاً',
    en: 'to unlock the full app',
    fr: 'pour débloquer l\'application',
    es: 'para desbloquear la app',
    tr: 'uygulamanın tamamını açmak için',
    ur: 'پوری ایپ کھولنے کے لیے',
    hi: 'पूरे ऐप को अनलॉक करने के लिए',
    id: 'untuk membuka semua fitur',
    ms: 'untuk membuka semua ciri',
    sw: 'kufungua programu nzima',
  );
  String get watchAdEnter => _t(
    ar: 'شاهد الإعلان — ادخل التطبيق',
    en: 'Watch ad — Enter app',
    fr: 'Voir la pub — Entrer',
    es: 'Ver anuncio — Entrar',
    tr: 'Reklamı izle — Uygulamaya gir',
    ur: 'اشتہار دیکھیں — ایپ میں داخل ہوں',
    hi: 'विज्ञापन देखें — ऐप में जाएं',
    id: 'Tonton iklan — Masuk',
    ms: 'Tonton iklan — Masuk',
    sw: 'Tazama tangazo — Ingia',
  );
  String get loading => _t(ar: 'جارٍ التحميل...', en: 'Loading...', fr: 'Chargement...', es: 'Cargando...', tr: 'Yükleniyor...', ur: 'لوڈ ہو رہا ہے...', hi: 'लोड हो रहा है...', id: 'Memuat...', ms: 'Memuatkan...', sw: 'Inapakia...');
  String get adFreeSession => _t(
    ar: 'إعلان واحد لكل جلسة • مجاني تماماً',
    en: 'One ad per session • Completely free',
    fr: 'Une pub par session • Totalement gratuit',
    es: 'Un anuncio por sesión • Totalmente gratis',
    tr: 'Oturum başına bir reklam • Tamamen ücretsiz',
    ur: 'ہر سیشن میں ایک اشتہار • بالکل مفت',
    hi: 'प्रति सत्र एक विज्ञापन • बिल्कुल मुफ्त',
    id: 'Satu iklan per sesi • Sepenuhnya gratis',
    ms: 'Satu iklan setiap sesi • Percuma sepenuhnya',
    sw: 'Tangazo moja kwa kila kikao • Bila malipo',
  );
  String get nowUnlocked => _t(ar: 'ما يفتح لك الآن:', en: 'What\'s unlocked for you:', fr: 'Ce qui vous est débloqué :', es: 'Lo que se desbloquea:', tr: 'Şimdi açılan özellikler:', ur: 'ابھی آپ کے لیے کیا کھلا:', hi: 'अभी आपके लिए क्या खुला:', id: 'Yang terbuka untuk Anda:', ms: 'Yang dibuka untuk anda:', sw: 'Inachofunguliwa kwako:');

  // Features
  String get aiHealthTips => _t(ar: 'نصائح AI مخصصة لصحتك', en: 'AI health tips tailored for you', fr: 'Conseils IA personnalisés pour votre santé', es: 'Consejos de IA personalizados para tu salud', tr: 'Sağlığınıza özel AI tavsiyeleri', ur: 'آپ کی صحت کے لیے AI نصائح', hi: 'आपके लिए AI स्वास्थ्य सुझाव', id: 'Tips kesehatan AI yang dipersonalisasi', ms: 'Petua kesihatan AI yang diperibadikan', sw: 'Vidokezo vya AI vya afya vilivyobinafsishwa');
  String get dailyLesson => _t(ar: 'درس اليوم لكل أهدافك', en: 'Daily lesson for all your goals', fr: 'Leçon quotidienne pour tous vos objectifs', es: 'Lección diaria para todos tus objetivos', tr: 'Tüm hedefleriniz için günlük ders', ur: 'آپ کے تمام اہداف کے لیے آج کا سبق', hi: 'आपके सभी लक्ष्यों के लिए दैनिक पाठ', id: 'Pelajaran harian untuk semua tujuan Anda', ms: 'Pelajaran harian untuk semua matlamat anda', sw: 'Somo la kila siku kwa malengo yako yote');
  String get aiSportCoach => _t(ar: 'مساعد AI للتدريب والتغذية', en: 'AI coach for training & nutrition', fr: 'Coach IA pour l\'entraînement et la nutrition', es: 'Entrenador IA para entrenamiento y nutrición', tr: 'Antrenman ve beslenme için AI koç', ur: 'تربیت اور غذائیت کے لیے AI کوچ', hi: 'प्रशिक्षण और पोषण के लिए AI कोच', id: 'Pelatih AI untuk latihan & nutrisi', ms: 'Jurulatih AI untuk latihan & pemakanan', sw: 'Kocha wa AI kwa mafunzo na lishe');
  String get stepsTracking => _t(ar: 'تتبع الخطوات والمؤشرات الصحية', en: 'Steps & health metrics tracking', fr: 'Suivi des pas et indicateurs de santé', es: 'Seguimiento de pasos e indicadores de salud', tr: 'Adım ve sağlık göstergesi takibi', ur: 'قدم اور صحت کے اشاریوں کا ٹریک', hi: 'कदम और स्वास्थ्य मेट्रिक्स ट्रैकिंग', id: 'Pelacakan langkah & metrik kesehatan', ms: 'Penjejakan langkah & metrik kesihatan', sw: 'Ufuatiliaji wa hatua na vipimo vya afya');

  // Navigation
  String get navHome     => _t(ar: 'الرئيسية', en: 'Home',     fr: 'Accueil',   es: 'Inicio',    tr: 'Ana Sayfa',  ur: 'گھر',   hi: 'होम',   id: 'Beranda', ms: 'Utama',  sw: 'Nyumbani');
  String get navGoals    => _t(ar: 'أهدافي',   en: 'Goals',    fr: 'Objectifs', es: 'Objetivos', tr: 'Hedefler',   ur: 'اہداف', hi: 'लक्ष्य', id: 'Tujuan',  ms: 'Matlamat', sw: 'Malengo');
  String get navAI       => _t(ar: 'مساعد AI', en: 'AI Coach', fr: 'Coach IA',  es: 'Coach IA',  tr: 'AI Koç',     ur: 'AI مدد', hi: 'AI कोच', id: 'AI Coach', ms: 'AI Jurulatih', sw: 'Kocha AI');
  String get navProgress => _t(ar: 'تقدمي',    en: 'Progress', fr: 'Progrès',   es: 'Progreso',  tr: 'İlerleme',   ur: 'پیشرفت', hi: 'प्रगति', id: 'Kemajuan', ms: 'Kemajuan', sw: 'Maendeleo');

  // Home screen
  String get todayLesson  => _t(ar: 'درس اليوم',      en: 'Today\'s lesson', fr: 'Leçon du jour', es: 'Lección de hoy', tr: 'Günün dersi', ur: 'آج کا سبق', hi: 'आज का पाठ', id: 'Pelajaran hari ini', ms: 'Pelajaran hari ini', sw: 'Somo la leo');
  String get dayStreak    => _t(ar: 'يوم متواصل',     en: 'Day streak',      fr: 'Jours consécutifs', es: 'Días seguidos', tr: 'Gün serisi', ur: 'مسلسل دن', hi: 'दिन की लकीर', id: 'Hari berturut-turut', ms: 'Hari berturut-turut', sw: 'Msururu wa siku');
  String get lessonDone   => _t(ar: 'درس مكتمل',      en: 'Lessons done',    fr: 'Leçons terminées', es: 'Lecciones hechas', tr: 'Tamamlanan ders', ur: 'مکمل سبق', hi: 'पाठ पूरे', id: 'Pelajaran selesai', ms: 'Pelajaran selesai', sw: 'Masomo yaliyokamilika');
  String get listen       => _t(ar: 'استمع',          en: 'Listen',          fr: 'Écouter',       es: 'Escuchar',    tr: 'Dinle',    ur: 'سنیں', hi: 'सुनें', id: 'Dengarkan', ms: 'Dengar', sw: 'Sikiliza');
  String get done         => _t(ar: 'أتممت',          en: 'Done',            fr: 'Terminé',       es: 'Listo',       tr: 'Tamam',    ur: 'مکمل', hi: 'हो गया', id: 'Selesai', ms: 'Selesai', sw: 'Imekamilika');
  String get aiAssistant  => _t(ar: 'مساعد AI',        en: 'AI Assistant',    fr: 'Assistant IA',  es: 'Asistente IA', tr: 'AI Asistan', ur: 'AI مددگار', hi: 'AI सहायक', id: 'Asisten AI', ms: 'Pembantu AI', sw: 'Msaidizi wa AI');
  String get startTraining => _t(ar: 'ابدأ محادثة تدريبية', en: 'Start a training chat', fr: 'Commencer un chat d\'entraînement', es: 'Iniciar chat de entrenamiento', tr: 'Antrenman sohbeti başlat', ur: 'تربیتی چیٹ شروع کریں', hi: 'प्रशिक्षण चैट शुरू करें', id: 'Mulai obrolan pelatihan', ms: 'Mulakan sembang latihan', sw: 'Anza mazungumzo ya mafunzo');

  // Settings / Language picker
  String get settings     => _t(ar: 'الإعدادات',    en: 'Settings',  fr: 'Paramètres', es: 'Configuración', tr: 'Ayarlar',   ur: 'ترتیبات', hi: 'सेटिंग्स', id: 'Pengaturan', ms: 'Tetapan', sw: 'Mipangilio');
  String get language     => _t(ar: 'اللغة',        en: 'Language',  fr: 'Langue',     es: 'Idioma',        tr: 'Dil',       ur: 'زبان',    hi: 'भाषा',    id: 'Bahasa',    ms: 'Bahasa', sw: 'Lugha');
  String get chooseLanguage => _t(ar: 'اختر لغتك', en: 'Choose your language', fr: 'Choisissez votre langue', es: 'Elige tu idioma', tr: 'Dilinizi seçin', ur: 'اپنی زبان چنیں', hi: 'अपनी भाषा चुनें', id: 'Pilih bahasa Anda', ms: 'Pilih bahasa anda', sw: 'Chagua lugha yako');

  // ─── Helper ───────────────────────────────────────────────────────────────
  String _t({
    required String ar,
    required String en,
    String? fr, String? es, String? tr,
    String? ur, String? hi, String? id,
    String? ms, String? sw,
  }) {
    switch (lang) {
      case AppLanguage.arabic:     return ar;
      case AppLanguage.english:    return en;
      case AppLanguage.french:     return fr ?? en;
      case AppLanguage.spanish:    return es ?? en;
      case AppLanguage.turkish:    return tr ?? en;
      case AppLanguage.urdu:       return ur ?? ar;
      case AppLanguage.hindi:      return hi ?? en;
      case AppLanguage.indonesian: return id ?? en;
      case AppLanguage.malay:      return ms ?? en;
      case AppLanguage.swahili:    return sw ?? en;
    }
  }
}
