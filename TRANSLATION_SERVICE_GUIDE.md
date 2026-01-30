# Translation Service Integration Guide - Indian Languages

## Overview

The app now uses the Hugging Face Space endpoint (`https://samarth-006-vatsalya.hf.space/`) for real-time text translation across 10 supported **Indian languages** only.

This includes all major Indian languages covering diverse regions:
- **North India:** Hindi, Punjabi
- **South India:** Tamil, Telugu, Kannada, Malayalam
- **West India:** Gujarati, Marathi
- **East India:** Bengali
- **Pan-India:** English

## Translation Architecture

### Translation Repository
**File:** `lib/data/repositories/translation_repository.dart`

The `TranslationRepository` class handles all communication with the translation API:

```dart
// Single text translation
String translatedText = await TranslationRepository.translate(
  text: 'Hello, World!',
  targetLanguage: 'hi', // Hindi
  sourceLanguage: 'en', // English (default)
);

// Batch translation (multiple texts at once)
List<String> translations = await TranslationRepository.translateBatch(
  texts: ['Hello', 'Good morning', 'Thank you'],
  targetLanguage: 'es', // Spanish
  sourceLanguage: 'en',
);

// Check service availability
bool available = await TranslationRepository.isServiceAvailable();
```

### Language Provider
**File:** `lib/presentation/viewmodels/language_provider.dart`

The `LanguageNotifier` now includes translation methods:

```dart
// Access the language notifier
final languageNotifier = ref.read(languageProvider.notifier);

// Translate to current language
String translated = await languageNotifier.translateText('Hello');

// Translate multiple texts
List<String> translations = await languageNotifier.translateTexts([
  'Hello',
  'Good morning',
  'How are you?'
]);

// Check service availability
bool available = languageNotifier.isServiceAvailable;
```

### Translation Provider
**File:** `lib/presentation/viewmodels/translation_provider.dart`

Riverpod providers for easy reactive translation:

```dart
// Single text translation (reactive)
@override
Widget build(BuildContext context, WidgetRef ref) {
  final translatedFuture = ref.watch(translateProvider('Hello'));
  
  return translatedFuture.when(
    data: (translated) => Text(translated),
    loading: () => const CircularProgressIndicator(),
    error: (err, stack) => Text('Translation failed'),
  );
}

// Batch translation (reactive)
final texts = ['Hello', 'Good morning'];
final translationsFuture = ref.watch(translateBatchProvider(texts));

translationsFuture.when(
  data: (translations) => ListView(
    children: translations.map((t) => Text(t)).toList(),
  ),
  loading: () => const CircularProgressIndicator(),
  error: (err, stack) => Text('Translation failed'),
);

// Check service availability
final availableFuture = ref.watch(translationServiceProvider);
availableFuture.when(
  data: (available) => Text(available ? 'Ready' : 'Offline'),
  loading: () => const CircularProgressIndicator(),
  error: (_, __) => const Text('Offline'),
);
```

## Supported Indian Languages

| Code | Language | Native Name | Region |
|------|----------|-------------|--------|
| en | English | English | Pan-India |
| hi | Hindi | हिन्दी | North & Central India |
| ta | Tamil | தமிழ் | South India |
| te | Telugu | తెలుగు | South India |
| kn | Kannada | ಕನ್ನಡ | South India |
| ml | Malayalam | മലയാളം | South India |
| gu | Gujarati | ગુજરાતી | West India |
| mr | Marathi | मराठी | West India |
| pa | Punjabi | ਪੰਜਾਬੀ | North India |
| bn | Bengali | বাংলা | East India |

## API Endpoints

### Health Check
```
GET https://samarth-006-vatsalya.hf.space/health
```

**Response:** HTTP 200 if service is available

### Single Text Translation
```
POST https://samarth-006-vatsalya.hf.space/api/translate
```

**Request Body:**
```json
{
  "text": "Hello, World!",
  "source_lang": "en",
  "target_lang": "hi"
}
```

**Response (Hindi):**
```json
{
  "translated_text": "नमस्ते, दुनिया!"
}
```

### Batch Translation
```
POST https://samarth-006-vatsalya.hf.space/api/translate_batch
```

**Request Body:**
```json
{
  "texts": ["Hello", "Good morning", "Thank you"],
  "source_lang": "en",
  "target_lang": "hi"
}
```

**Response (Hindi):**
```json
{
  "translated_texts": ["नमस्ते", "सुप्रभात", "धन्यवाद"]
}
```

## Usage Examples

### Example 1: Simple Widget with Translation

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maternal_infant_care/presentation/viewmodels/translation_provider.dart';

class TranslatedText extends ConsumerWidget {
  final String text;
  
  const TranslatedText(this.text);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translatedFuture = ref.watch(translateProvider(text));
    
    return translatedFuture.when(
      data: (translated) => Text(translated),
      loading: () => const Padding(
        padding: EdgeInsets.all(8.0),
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (err, stack) => Text(text), // Fallback to original
    );
  }
}
```

### Example 2: Batch Translation for Lists

```dart
class TranslatedList extends ConsumerWidget {
  final List<String> items;
  
  const TranslatedList(this.items);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final translatedFuture = ref.watch(translateBatchProvider(items));
    
    return translatedFuture.when(
      data: (translations) => ListView.builder(
        itemCount: translations.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(translations[index]),
        ),
      ),
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, stack) => ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(items[index]),
        ),
      ),
    );
  }
}
```

### Example 3: Language Change with Translation

```dart
class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLanguage = ref.watch(languageProvider);
    final languageNotifier = ref.read(languageProvider.notifier);
    
    return Dialog(
      child: ListView(
        children: AppLanguage.values.map((language) {
          final isSelected = currentLanguage.languageCode == language.code;
          
          return ListTile(
            leading: Text(language.flag),
            title: Text(language.nativeName),
            trailing: isSelected ? const Icon(Icons.check) : null,
            onTap: () async {
              await languageNotifier.setLanguage(language);
              Navigator.pop(context);
              
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Language changed to ${language.nativeName}',
                  ),
                ),
              );
            },
          );
        }).toList(),
      ),
    );
  }
}
```

## Error Handling

The translation system includes graceful error handling:

1. **Network Timeout:** If request takes > 30 seconds, returns original text
2. **Service Unavailable:** Returns original text and logs error
3. **Invalid Response:** Returns original text
4. **Empty Text:** Returns empty string without making request

**Example with Error Handling:**

```dart
final translatedFuture = ref.watch(translateProvider('Hello'));

translatedFuture.when(
  data: (translated) {
    // Show translated text
    return Text(translated);
  },
  loading: () {
    // Show loading indicator
    return const CircularProgressIndicator();
  },
  error: (error, stackTrace) {
    // Show original text or error message
    print('Translation error: $error');
    return const Text('Translation unavailable');
  },
);
```

## Performance Considerations

### Single vs Batch Translation
- **Use `translateBatch` for multiple items:** More efficient API usage
- **Use `translate` for single items:** Lower latency for quick translations

### Caching Strategy
Consider caching translations locally:

```dart
// Example: Cache translations in SharedPreferences
final prefs = await SharedPreferences.getInstance();
final cacheKey = '${language}_${text}';
final cached = prefs.getString(cacheKey);

if (cached != null) {
  return cached;
}

final translated = await TranslationRepository.translate(
  text: text,
  targetLanguage: language,
);

await prefs.setString(cacheKey, translated);
return translated;
```

### Offline Support
The system gracefully falls back to English if:
- Service is unavailable
- Network is unreachable
- Translation fails

No crashes occur - user sees original content.

## Best Practices

### 1. Always Use Providers for Reactive UI
```dart
// ✅ Good - Reactive to language changes
final translated = ref.watch(translateProvider(text));

// ❌ Avoid - Not reactive
final translated = await TranslationRepository.translate(...);
```

### 2. Use Batch for Multiple Items
```dart
// ✅ Good - Single API call
final texts = ['Hello', 'Goodbye', 'Thank you'];
final translated = ref.watch(translateBatchProvider(texts));

// ❌ Avoid - Multiple API calls
for (final text in texts) {
  ref.watch(translateProvider(text));
}
```

### 3. Handle Loading States
```dart
// ✅ Good - Show loading indicator
translatedFuture.when(
  data: (text) => Text(text),
  loading: () => const CircularProgressIndicator(),
  error: (_, __) => Text(originalText),
);

// ❌ Avoid - Assume data is ready
Text(translatedFuture.value ?? originalText);
```

### 4. Don't Translate Numeric Values
```dart
// ✅ Good - Keep numbers and punctuation separate
await languageNotifier.translateText('Baby kicks: 12');

// ✅ Better - Translate only text
final kickCount = 12;
final translatedText = await languageNotifier.translateText('Baby kicks:');
return '$translatedText $kickCount';
```

## Troubleshooting

### Translation service shows as unavailable
1. Check internet connection
2. Verify API endpoint: `https://samarth-006-vatsalya.hf.space/health`
3. Check Hugging Face Space status
4. Check logs for specific error messages

### Translations not working for specific language
1. Verify language code in `AppLanguage` enum
2. Check API supports the language
3. Review logs for API error responses
4. Test with different text (some medical terms may not translate)

### Slow translations
1. Use batch translation for multiple items
2. Consider caching frequent translations
3. Monitor API response times
4. Consider pre-translating static content

### Text overflow after translation
1. Some languages (German, Russian) produce longer text
2. Use `maxLines` and `overflow: TextOverflow.ellipsis`
3. Adjust font sizes for different languages
4. Use `FittedBox` for critical UI elements

## Migration to Custom Translation Service

If you want to switch from the Hugging Face API:

1. **Create new repository:** `lib/data/repositories/custom_translation_repository.dart`
2. **Implement same interface:** `translate()`, `translateBatch()`, `isServiceAvailable()`
3. **Update imports:** Replace in `language_provider.dart` and `translation_provider.dart`
4. **Update endpoint:** Change `_baseUrl` constant to your service

## API Response Codes

| Code | Meaning | Action |
|------|---------|--------|
| 200 | Success | Use translated_text |
| 400 | Bad Request | Log error, return original |
| 500 | Server Error | Log error, return original |
| Timeout | Request took too long | Return original |
| No connection | No internet | Return original, check later |

## Future Enhancements

1. **Offline Translation:** Use on-device ML models for Indian languages
2. **Translation Caching:** Store translations locally for better performance
3. **Pronunciation Guide:** Add audio pronunciation for Indian languages
4. **Regional Script Support:** Full support for Devanagari, Tamil, Telugu, Kannada, Malayalam scripts
5. **Auto-Detection:** Detect user language from device settings (India-centric)
6. **Translation History:** Track previously translated strings
7. **Colloquial Support:** Better handling of regional dialects and colloquialisms

## Support & Resources

- **API Documentation:** Contact Hugging Face for API docs
- **Language Support:** All 10 Indian languages supported by endpoint
- **Regional Coverage:** Covers all major regions of India
- **Rate Limits:** Check Hugging Face Space limits
- **Uptime:** Monitor endpoint health regularly
- **Community:** Support for Indian language translation standards

---

**Last Updated:** January 30, 2026  
**Service:** Hugging Face Space Translation API (Indian Languages)  
**Endpoint:** https://samarth-006-vatsalya.hf.space/  
**Supported Languages:** 10 Indian Languages
