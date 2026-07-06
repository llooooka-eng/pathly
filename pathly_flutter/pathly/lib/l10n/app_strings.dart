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

  // Custom goal
  String get customGoal        => _t(ar: 'هدف مخصص', en: 'Custom goal', fr: 'Objectif personnalisé', es: 'Meta personalizada', tr: 'Özel hedef', ur: 'حسب ضرورت ہدف', hi: 'कस्टम लक्ष्य', id: 'Tujuan khusus', ms: 'Matlamat tersuai', sw: 'Lengo maalum');
  String get customGoalDesc    => _t(ar: 'أنشئ هدفك الخاص', en: 'Create your own goal', fr: 'Créez votre propre objectif', es: 'Crea tu propia meta', tr: 'Kendi hedefini oluştur', ur: 'اپنا ہدف بنائیں', hi: 'अपना लक्ष्य बनाएं', id: 'Buat tujuan Anda sendiri', ms: 'Cipta matlamat anda', sw: 'Unda lengo lako');
  String get goalTitle         => _t(ar: 'عنوان الهدف', en: 'Goal title', fr: 'Titre de l\'objectif', es: 'Título de la meta', tr: 'Hedef başlığı', ur: 'ہدف کا عنوان', hi: 'लक्ष्य शीर्षक', id: 'Judul tujuan', ms: 'Tajuk matlamat', sw: 'Kichwa cha lengo');
  String get goalDescription   => _t(ar: 'الوصف', en: 'Description', fr: 'Description', es: 'Descripción', tr: 'Açıklama', ur: 'تفصیل', hi: 'विवरण', id: 'Deskripsi', ms: 'Penerangan', sw: 'Maelezo');
  String get category          => _t(ar: 'الفئة', en: 'Category', fr: 'Catégorie', es: 'Categoría', tr: 'Kategori', ur: 'زمرہ', hi: 'श्रेणी', id: 'Kategori', ms: 'Kategori', sw: 'Kategoria');
  String get durationDays      => _t(ar: 'المدة (أيام)', en: 'Duration (days)', fr: 'Durée (jours)', es: 'Duración (días)', tr: 'Süre (gün)', ur: 'دورانیہ (دن)', hi: 'अवधि (दिन)', id: 'Durasi (hari)', ms: 'Tempoh (hari)', sw: 'Muda (siku)');
  String get create            => _t(ar: 'إنشاء', en: 'Create', fr: 'Créer', es: 'Crear', tr: 'Oluştur', ur: 'بنائیں', hi: 'बनाएं', id: 'Buat', ms: 'Cipta', sw: 'Unda');
  String get cancel            => _t(ar: 'إلغاء', en: 'Cancel', fr: 'Annuler', es: 'Cancelar', tr: 'İptal', ur: 'منسوخ', hi: 'रद्द करें', id: 'Batal', ms: 'Batal', sw: 'Ghairi');
  String get delete            => _t(ar: 'حذف', en: 'Delete', fr: 'Supprimer', es: 'Eliminar', tr: 'Sil', ur: 'حذف', hi: 'हटाएं', id: 'Hapus', ms: 'Padam', sw: 'Futa');
  String get deleteGoal        => _t(ar: 'حذف الهدف', en: 'Delete goal', fr: 'Supprimer l\'objectif', es: 'Eliminar meta', tr: 'Hedefi sil', ur: 'ہدف حذف کریں', hi: 'लक्ष्य हटाएं', id: 'Hapus tujuan', ms: 'Padam matlamat', sw: 'Futa lengo');
  String get deleteGoalConfirm => _t(ar: 'هل تريد حذف هذا الهدف؟ لا يمكن التراجع.', en: 'Delete this goal? This cannot be undone.', fr: 'Supprimer cet objectif ? Action irréversible.', es: '¿Eliminar esta meta? No se puede deshacer.', tr: 'Bu hedef silinsin mi? Geri alınamaz.', ur: 'یہ ہدف حذف کریں؟ واپس نہیں ہوگا۔', hi: 'यह लक्ष्य हटाएं? इसे पूर्ववत नहीं किया जा सकता।', id: 'Hapus tujuan ini? Tidak dapat dibatalkan.', ms: 'Padam matlamat ini? Tidak boleh dibuat asal.', sw: 'Futa lengo hili? Haiwezi kutenduliwa.');
  String get goalDeleted       => _t(ar: 'تم حذف الهدف', en: 'Goal deleted', fr: 'Objectif supprimé', es: 'Meta eliminada', tr: 'Hedef silindi', ur: 'ہدف حذف ہو گیا', hi: 'लक्ष्य हटा दिया गया', id: 'Tujuan dihapus', ms: 'Matlamat dipadam', sw: 'Lengo limefutwa');
  String get goalTitleRequired => _t(ar: 'أدخل عنوان الهدف', en: 'Enter a goal title', fr: 'Saisissez un titre', es: 'Ingresa un título', tr: 'Bir başlık girin', ur: 'ہدف کا عنوان درج کریں', hi: 'लक्ष्य शीर्षक दर्ज करें', id: 'Masukkan judul tujuan', ms: 'Masukkan tajuk matlamat', sw: 'Weka kichwa cha lengo');

  // Daily reminder
  String get dailyReminder     => _t(ar: 'التذكير اليومي', en: 'Daily reminder', fr: 'Rappel quotidien', es: 'Recordatorio diario', tr: 'Günlük hatırlatma', ur: 'روزانہ یاد دہانی', hi: 'दैनिक अनुस्मारक', id: 'Pengingat harian', ms: 'Peringatan harian', sw: 'Kikumbusho cha kila siku');
  String get dailyReminderDesc => _t(ar: 'ذكّرني يوميًا لمتابعة درسي', en: 'Remind me daily to follow my lesson', fr: 'Me rappeler chaque jour ma leçon', es: 'Recuérdame mi lección cada día', tr: 'Dersim için her gün hatırlat', ur: 'میرے سبق کے لیے روزانہ یاد دلائیں', hi: 'मेरे पाठ के लिए रोज़ याद दिलाएं', id: 'Ingatkan saya setiap hari', ms: 'Ingatkan saya setiap hari', sw: 'Nikumbushe kila siku');
  String get reminderTime      => _t(ar: 'وقت التذكير', en: 'Reminder time', fr: 'Heure du rappel', es: 'Hora del recordatorio', tr: 'Hatırlatma saati', ur: 'یاد دہانی کا وقت', hi: 'अनुस्मारक समय', id: 'Waktu pengingat', ms: 'Masa peringatan', sw: 'Muda wa kikumbusho');
  String get reminderTitle     => _t(ar: 'حان وقت درسك في Pathly ✨', en: 'Time for your Pathly lesson ✨', fr: 'C\'est l\'heure de votre leçon Pathly ✨', es: 'Es hora de tu lección de Pathly ✨', tr: 'Pathly dersinin zamanı ✨', ur: 'آپ کے Pathly سبق کا وقت ✨', hi: 'आपके Pathly पाठ का समय ✨', id: 'Waktunya pelajaran Pathly ✨', ms: 'Masa untuk pelajaran Pathly ✨', sw: 'Wakati wa somo lako la Pathly ✨');
  String get reminderBody      => _t(ar: 'خصّص دقائق لهدفك اليوم. استمر في مسارك!', en: 'Spend a few minutes on your goal today. Keep your streak!', fr: 'Consacrez quelques minutes à votre objectif. Gardez votre série !', es: 'Dedica unos minutos a tu meta hoy. ¡Mantén tu racha!', tr: 'Bugün hedefine birkaç dakika ayır. Serini koru!', ur: 'آج اپنے ہدف کے لیے چند منٹ نکالیں۔ سلسلہ جاری رکھیں!', hi: 'आज अपने लक्ष्य पर कुछ मिनट दें। अपनी लकीर बनाए रखें!', id: 'Luangkan beberapa menit untuk tujuanmu hari ini. Jaga streakmu!', ms: 'Luangkan beberapa minit untuk matlamat anda hari ini!', sw: 'Tumia dakika chache kwa lengo lako leo. Endeleza msururu wako!');
  String get permissionDenied  => _t(ar: 'لم يتم منح إذن الإشعارات', en: 'Notification permission not granted', fr: 'Permission de notification refusée', es: 'Permiso de notificaciones denegado', tr: 'Bildirim izni verilmedi', ur: 'اطلاع کی اجازت نہیں ملی', hi: 'सूचना अनुमति नहीं मिली', id: 'Izin notifikasi tidak diberikan', ms: 'Kebenaran pemberitahuan tidak diberikan', sw: 'Ruhusa ya arifa haijatolewa');

  // Share progress
  String get shareProgress  => _t(ar: 'شارك تقدمي', en: 'Share my progress', fr: 'Partager ma progression', es: 'Compartir mi progreso', tr: 'İlerlememi paylaş', ur: 'میری پیشرفت شیئر کریں', hi: 'मेरी प्रगति साझा करें', id: 'Bagikan kemajuan saya', ms: 'Kongsi kemajuan saya', sw: 'Shiriki maendeleo yangu');
  String get shareHeadline  => _t(ar: '🎯 تقدمي في Pathly', en: '🎯 My progress on Pathly', fr: '🎯 Ma progression sur Pathly', es: '🎯 Mi progreso en Pathly', tr: '🎯 Pathly\'deki ilerlemem', ur: '🎯 Pathly پر میری پیشرفت', hi: '🎯 Pathly पर मेरी प्रगति', id: '🎯 Kemajuan saya di Pathly', ms: '🎯 Kemajuan saya di Pathly', sw: '🎯 Maendeleo yangu kwenye Pathly');
  String get shareNoData    => _t(ar: 'لا يوجد هدف لمشاركته بعد', en: 'No goal to share yet', fr: 'Aucun objectif à partager', es: 'Aún no hay meta para compartir', tr: 'Paylaşılacak hedef yok', ur: 'ابھی شیئر کرنے کے لیے کوئی ہدف نہیں', hi: 'साझा करने के लिए कोई लक्ष्य नहीं', id: 'Belum ada tujuan untuk dibagikan', ms: 'Tiada matlamat untuk dikongsi', sw: 'Hakuna lengo la kushiriki bado');

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
