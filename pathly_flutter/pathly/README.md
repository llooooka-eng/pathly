# Pathly — مسارك نحو هدفك

تطبيق Flutter لمتابعة الأهداف الشخصية مدعوم بالذكاء الاصطناعي.

## هيكل المشروع

```
lib/
├── main.dart                  # نقطة البداية + التنقل
├── theme/
│   └── app_theme.dart         # الألوان والتصميم
├── models/
│   └── goal.dart              # نماذج البيانات (Goal, DailyLesson, GoalTemplate)
├── services/
│   ├── goals_provider.dart    # إدارة الحالة (Provider)
│   └── ai_service.dart        # تكامل Claude API
└── screens/
    ├── home_screen.dart        # الشاشة الرئيسية
    ├── goals_screen.dart       # إدارة الأهداف
    ├── ai_chat_screen.dart     # المحادثة التدريبية
    └── progress_screen.dart   # الإحصائيات والرسوم
```

## خطوات التشغيل

### 1. تثبيت Flutter
```bash
# تأكد أن Flutter مثبت
flutter doctor
```

### 2. تثبيت المكتبات
```bash
flutter pub get
```

### 3. إضافة مفتاح Claude API
افتح `lib/services/ai_service.dart` وضع مفتاحك:
```dart
static const String _apiKey = 'sk-ant-...YOUR_KEY_HERE...';
```

> ⚠️ في الإنتاج: لا تضع المفتاح في الكود. استخدم متغيرات بيئة أو backend وسيط.

### 4. تشغيل التطبيق
```bash
# على محاكي
flutter run

# على جهاز حقيقي
flutter run -d <device_id>

# بناء APK
flutter build apk --release

# بناء iOS
flutter build ios --release
```

## الميزات المبنية

| الميزة | الحالة |
|--------|--------|
| الشاشة الرئيسية مع درس يومي | ✅ |
| إدارة أهداف متعددة | ✅ |
| مساعد AI تدريبي (Claude) | ✅ |
| إحصائيات ورسوم بيانية | ✅ |
| نظام Streak | ✅ |
| نموذج Freemium (Free/Pro) | ✅ |
| 5 قوالب أهداف جاهزة | ✅ |

## الميزات القادمة (v2)

- [ ] إشعارات تذكير يومية
- [ ] مشاركة التقدم مع الأصدقاء
- [ ] خطة Team
- [ ] دعم الصوت والنطق
- [ ] مزامنة مع iCloud / Google Drive

## نموذج العمل

| الخطة | السعر | الحد |
|-------|-------|------|
| Free | مجاني | هدف واحد |
| Pro | $7/شهر | أهداف غير محدودة + AI كامل |
| Team | $4/شخص | Pro للمجموعات |
