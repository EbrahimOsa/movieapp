# حل مشاكل تطبيق MovieVerse 🎬

## التحديثات الجديدة ✅

### المشاكل التي تم حلها:
- ✅ إصلاح مشكلة `accentColor` في theme
- ✅ حذف الملفات المكررة (`main_safe.dart`)
- ✅ تنظيف ملفات البناء غير الضرورية
- ✅ إضافة أدوات تشخيص شاملة

## طرق تشغيل التطبيق 🚀

### الطريقة 1: استخدام PowerShell Script
```powershell
.\run_app.ps1
```

### الطريقة 2: الأوامر اليدوية
```bash
flutter clean
flutter pub get  
flutter analyze
flutter run
```

### الطريقة 3: التشخيص الشامل
```batch
.\diagnose_app.bat
```

## المشاكل الشائعة وحلولها

### 1. التطبيق لا يستجيب أو لا يعمل ❌

#### الأسباب المحتملة:
- **API Key غير صحيح**: التطبيق يحتاج TMDB API key
- **مشاكل في الشبكة**: عدم توفر الإنترنت
- **مشاكل في Dependencies**: التبعيات غير محدثة
- **مشاكل في الـ theme**: تم إصلاحها ✅

#### الحلول السريعة:

```bash
# 1. تنظيف التطبيق
flutter clean

# 2. تحديث التبعيات
flutter pub get

# 3. تحليل الكود
flutter analyze

# 4. فحص Flutter
flutter doctor
```

### 2. مشكلة API Key 🔑

حالياً التطبيق يستخدم API key صالح، ولكن إذا كان لديك مشاكل:

1. اذهب إلى [TMDB](https://www.themoviedb.org/settings/api)
2. احصل على API key مجاني
3. استبدل الـ key في الملف:

```dart
// في ملف lib/core/constants/app_constants.dart
static const String tmdbApiKey = 'ضع_الـapi_key_الجديد_هنا';
```

### 3. مشاكل withOpacity (deprecated) ⚠️

```bash
# تشغيل سكريپت الإصلاح
python fix_withopacity.py
```

### 4. مشاكل في الـ PowerShell Encoding

إذا كان هناك مشاكل في encoding:

```powershell
# تغيير encoding
chcp 65001
```

أو استخدم:
```powershell
powershell -ExecutionPolicy Bypass -File run_app.ps1
```

### 5. مشاكل الـ Build

```bash
# للـ Android
flutter build apk --debug --verbose

# للـ iOS  
flutter build ios --debug --verbose
```

### 6. فحص الأخطاء أثناء التشغيل

```bash
# تشغيل مع تفاصيل الأخطاء
flutter run --verbose

# تشغيل على جهاز معين
flutter devices
flutter run -d <device_id>
```

### 7. مشاكل الـ Gradle (Android)

```bash
# في مجلد android
cd android
./gradlew clean
cd ..
flutter clean  
flutter pub get
```

## الملفات الجديدة المفيدة:

- **`run_app.ps1`** - سكريپت PowerShell لتشغيل التطبيق
- **`diagnose_app.bat`** - تشخيص شامل للمشاكل
- **`fix_withopacity.py`** - إصلاح استخدام withOpacity المهجور
- **`TROUBLESHOOTING_AR.md`** - هذا الدليل

## الملفات المهمة للفحص:

- **`lib/core/constants/app_constants.dart`** - تحقق من API key ✅
- **`pubspec.yaml`** - تحقق من التبعيات ✅ 
- **`android/build.gradle`** - إعدادات Android
- **`lib/main.dart`** - نقطة البداية ✅

## معلومات مفيدة:

### متطلبات التطبيق:
- Flutter ≥ 3.10.0 ✅
- Dart ≥ 3.0.0 ✅
- Android SDK ≥ 21
- iOS ≥ 12.0

### التبعيات الرئيسية:
- provider (إدارة الحالة) ✅
- http (طلبات الشبكة) ✅
- go_router (التنقل) ✅
- cached_network_image (الصور) ✅

## الحالة الحالية:

### ما تم إصلاحه: ✅
1. مشكلة `accentColor` في theme
2. حذف الملفات المكررة
3. تنظيف ملفات البناء
4. إضافة أدوات تشخيص

### التطبيق جاهز للتشغيل! 🎉

```bash
flutter run
```

## الدعم الفني:

إذا استمرت المشاكل:
1. شغل `diagnose_app.bat` للتشخيص الشامل
2. تحقق من `flutter doctor -v`
3. راجع console logs بالتفصيل
4. تأكد من اتصال الإنترنت
5. جرب على جهاز/simulator مختلف

---
**نصيحة**: التطبيق الآن نظيف ومُحسَّن ويجب أن يعمل بسلاسة! 🚀�
