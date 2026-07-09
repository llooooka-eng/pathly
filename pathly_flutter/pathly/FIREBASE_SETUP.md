# إعداد Firebase للمزامنة السحابية

المزامنة السحابية في Pathly تستخدم **Firebase Auth (تسجيل دخول Google)** و**Cloud Firestore**.
كود التطبيق جاهز، لكنه **معطَّل بأمان حتى تُكمل الخطوات التالية**. بدونها سيعمل التطبيق
بشكل طبيعي مع إخفاء ميزة المزامنة (تظهر رسالة "المزامنة غير مهيّأة").

> ⚠️ ملاحظة: مجلّدا `android/` و `ios/` هنا يحتويان ملفات المصدر فقط. إن لم تكن منصّات
> Flutter الأصلية مولّدة بعد، شغّل `flutter create .` داخل `pathly_flutter/pathly` أولاً.

## 1) أنشئ مشروع Firebase
- افتح <https://console.firebase.google.com> → **Add project**.
- فعّل **Authentication → Sign-in method → Google**.
- أنشئ **Cloud Firestore** (Production mode).

## 2) اربط التطبيق عبر FlutterFire
```bash
dart pub global activate flutterfire_cli
cd pathly_flutter/pathly
flutterfire configure
```
هذا يولّد `lib/firebase_options.dart` وملفات المنصّات:
- Android: `android/app/google-services.json` + إضافة plugin `com.google.gms.google-services`
- iOS: `ios/Runner/GoogleService-Info.plist`

> الكود يستدعي `Firebase.initializeApp()` بدون معطيات، وهو يقرأ ملفات المنصّات تلقائيًا.
> إن أردت دعم الويب/سطح المكتب، مرّر `options: DefaultFirebaseOptions.currentPlatform`.

## 3) إعداد تسجيل دخول Google (Android)
- أضف بصمة **SHA-1** (و SHA-256) لتطبيقك في إعدادات مشروع Firebase:
  ```bash
  cd android && ./gradlew signingReport
  ```
- أعد تنزيل `google-services.json` بعد إضافة البصمات.

## 4) إعداد تسجيل دخول Google (iOS)
- أضف **URL Scheme** = قيمة `REVERSED_CLIENT_ID` من `GoogleService-Info.plist`
  إلى `ios/Runner/Info.plist` تحت `CFBundleURLTypes`.

## 5) قواعد أمان Firestore
كل مستخدم يقرأ/يكتب مستنده فقط، وأي مستخدم مسجَّل يمكنه قراءة/الانضمام للفرق:
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }
    // الفرق: أي مستخدم مسجَّل يقرأ الفريق (لإيجاده بالرمز) ويحدّث عضويته
    match /teams/{teamId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.ownerUid == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.ownerUid == request.auth.uid;

      match /members/{uid} {
        allow read: if request.auth != null;
        // كل عضو يكتب/يحذف سجلّ عضويته فقط
        allow write: if request.auth != null && request.auth.uid == uid;
      }
    }
  }
}
```
> ملاحظة: البحث عن فريق بالرمز يتطلب `allow read` على `teams`. لتشديد الأمان لاحقًا
> يمكن نقل البحث بالرمز إلى Cloud Function.

## 6) شغّل
```bash
flutter pub get
flutter run
```
ثم من **الإعدادات → المزامنة السحابية**: سجّل الدخول عبر Google، ثم استخدم
**رفع إلى السحابة** / **استرجاع من السحابة**.

## بنية البيانات
```
users/{uid} = {
  goals: [ { id, title, category, description, startDate, targetDate,
             currentStreak, totalDays, progress, lessons, isPro }, ... ],
  updatedAt: <serverTimestamp>,
  teamId: <مرجع الفريق الحالي، إن وُجد>
}

teams/{teamId} = { name, code, ownerUid, createdAt }
teams/{teamId}/members/{uid} = { email, streak, goals, updatedAt }
```

## ملاحظات
- المزامنة الحالية **يدوية** (رفع/استرجاع) لتفادي دمج التعارضات تلقائيًا. يمكن لاحقًا
  إضافة مزامنة تلقائية بمقارنة `updatedAt`.
- كل الكود المتعلق محمي بـ `SyncService.firebaseReady`، فلا يتعطّل التطبيق قبل الإعداد.
