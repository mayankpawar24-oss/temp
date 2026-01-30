# Language Translation Integration Guide

This guide explains how to integrate free translation APIs and services into the Maternal & Infant Care app.

## Current Implementation

The app currently supports 10 languages with a language provider system located in:
- `lib/presentation/viewmodels/language_provider.dart`

### Supported Languages:
1. English (en) 🇬🇧
2. Hindi (hi) 🇮🇳
3. Spanish (es) 🇪🇸
4. French (fr) 🇫🇷
5. German (de) 🇩🇪
6. Chinese (zh) 🇨🇳
7. Arabic (ar) 🇸🇦
8. Portuguese (pt) 🇵🇹
9. Russian (ru) 🇷🇺
10. Japanese (ja) 🇯🇵

## Free Translation API Options

### Option 1: Google Cloud Translation API (Free Tier)
**Free Quota**: 500,000 characters/month

**Setup:**
```yaml
# pubspec.yaml
dependencies:
  translator: ^1.0.0
```

**Implementation:**
```dart
import 'package:translator/translator.dart';

class TranslationService {
  final translator = GoogleTranslator();
  
  Future<String> translate(String text, String targetLanguage) async {
    try {
      final translation = await translator.translate(
        text, 
        to: targetLanguage,
      );
      return translation.text;
    } catch (e) {
      return text; // Return original text on error
    }
  }
}
```

### Option 2: LibreTranslate (Open Source & Free)
**Free & Self-Hosted**: Unlimited translations

**Setup:**
```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0
```

**Implementation:**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class LibreTranslateService {
  static const String apiUrl = 'https://libretranslate.com/translate';
  
  Future<String> translate(String text, String source, String target) async {
    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'q': text,
          'source': source,
          'target': target,
          'format': 'text',
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translatedText'];
      }
      return text;
    } catch (e) {
      return text;
    }
  }
}
```

### Option 3: Microsoft Translator (Free Tier)
**Free Quota**: 2 million characters/month

**Setup:**
```yaml
# pubspec.yaml
dependencies:
  http: ^1.1.0
```

**Implementation:**
```dart
import 'package:http/http.dart' as http;
import 'dart:convert';

class MicrosoftTranslatorService {
  final String apiKey = 'YOUR_API_KEY';
  final String endpoint = 'https://api.cognitive.microsofttranslator.com';
  final String region = 'global';
  
  Future<String> translate(String text, String targetLanguage) async {
    try {
      final response = await http.post(
        Uri.parse('$endpoint/translate?api-version=3.0&to=$targetLanguage'),
        headers: {
          'Ocp-Apim-Subscription-Key': apiKey,
          'Ocp-Apim-Subscription-Region': region,
          'Content-Type': 'application/json',
        },
        body: jsonEncode([{'Text': text}]),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data[0]['translations'][0]['text'];
      }
      return text;
    } catch (e) {
      return text;
    }
  }
}
```

## Recommended: Static Translation Files (Best Performance)

For production apps, static translation files are recommended:

### Setup with Easy Localization Package:

1. **Add dependencies:**
```yaml
# pubspec.yaml
dependencies:
  easy_localization: ^3.0.3

flutter:
  assets:
    - assets/translations/
```

2. **Create translation JSON files:**

**assets/translations/en.json:**
```json
{
  "app_name": "Maternal & Infant Care",
  "dashboard": "Dashboard",
  "profile": "Profile",
  "resources": "Resources",
  "daily_summary": "Daily Summary",
  "weekly_insights": "Weekly Insights",
  "settings": "Settings",
  "language": "Language",
  "theme": "Theme",
  "logout": "Logout",
  "pregnancy_journey": "Pregnancy Journey",
  "baby_kicks": "Baby Kicks",
  "contractions": "Contractions",
  "hydration_goal": "Hydration Goal",
  "activity": "Activity",
  "fetal_movement": "Fetal Movement",
  "blood_pressure": "Blood Pressure",
  "nutrition": "Nutrition"
}
```

**assets/translations/hi.json:**
```json
{
  "app_name": "मातृ एवं शिशु देखभाल",
  "dashboard": "डैशबोर्ड",
  "profile": "प्रोफ़ाइल",
  "resources": "संसाधन",
  "daily_summary": "दैनिक सारांश",
  "weekly_insights": "साप्ताहिक अंतर्दृष्टि",
  "settings": "सेटिंग्स",
  "language": "भाषा",
  "theme": "थीम",
  "logout": "लॉगआउट",
  "pregnancy_journey": "गर्भावस्था यात्रा",
  "baby_kicks": "शिशु की लात",
  "contractions": "संकुचन",
  "hydration_goal": "जलयोजन लक्ष्य",
  "activity": "गतिविधि",
  "fetal_movement": "भ्रूण की गति",
  "blood_pressure": "रक्तचाप",
  "nutrition": "पोषण"
}
```

3. **Initialize in main.dart:**
```dart
import 'package:easy_localization/easy_localization.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  
  runApp(
    EasyLocalization(
      supportedLocales: [
        Locale('en'),
        Locale('hi'),
        Locale('es'),
        // ... other languages
      ],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: MyApp(),
    ),
  );
}
```

4. **Use in widgets:**
```dart
Text('daily_summary'.tr())  // Translated text
Text('welcome_message').tr(args: ['John'])  // With parameters
```

## Integration Steps

### 1. Choose Your Translation Method:
   - **Static files**: Best for production (fastest, offline support)
   - **API translation**: Good for dynamic content
   - **Hybrid**: Static for UI, API for user-generated content

### 2. Update Main App:
```dart
// lib/main.dart
class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(languageProvider);
    
    return MaterialApp(
      locale: locale,
      supportedLocales: AppLanguage.values.map((l) => Locale(l.code)),
      localizationsDelegates: [
        // Add your localization delegates here
      ],
      // ... rest of app config
    );
  }
}
```

### 3. Test Language Changes:
```dart
// In any widget
final languageNotifier = ref.read(languageProvider.notifier);
await languageNotifier.setLanguage(AppLanguage.hindi);
```

## Best Practices

1. **Cache translations** to reduce API calls
2. **Fallback to English** if translation fails
3. **Test all languages** on different screen sizes
4. **Use context-aware translations** (formal vs informal)
5. **Handle RTL languages** (Arabic) properly
6. **Keep translations short** for buttons and labels
7. **Professional translations** for medical/health content

## Cost Comparison

| Service | Free Tier | Best For |
|---------|-----------|----------|
| Google Translate API | 500K chars/month | General use |
| Microsoft Translator | 2M chars/month | Higher volume |
| LibreTranslate | Unlimited (self-host) | Privacy-focused |
| Static Files | Free | Production apps |

## Recommended Approach

For this Maternal & Infant Care app:
1. Use **static translation files** for all UI elements
2. Use **LibreTranslate or Google Translate** for user-generated content (articles, tips)
3. Store frequently used translations in local database
4. Update translations monthly via remote config

## Support

For questions or issues with translation integration, refer to:
- Easy Localization: https://pub.dev/packages/easy_localization
- LibreTranslate: https://libretranslate.com/
- Google Cloud Translation: https://cloud.google.com/translate/docs
