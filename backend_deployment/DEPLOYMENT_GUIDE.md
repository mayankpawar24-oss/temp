# Deploying Vatsalya Translation Service to Hugging Face Spaces

## Current Issue
Your space at https://huggingface.co/spaces/samarth-006/vatsalya is showing an error. This guide will fix it.

## Step-by-Step Deployment

### 1. Access Your Space
Go to: https://huggingface.co/spaces/samarth-006/vatsalya

### 2. Update Files
Click on "Files" tab, then update/create these 4 files:

#### File 1: app.py
- Click "Add file" → "Create a new file"
- Name: `app.py`
- Copy content from `backend_deployment/app.py`
- Click "Commit new file to main"

#### File 2: requirements.txt
- Click "Add file" → "Create a new file"
- Name: `requirements.txt`
- Copy content from `backend_deployment/requirements.txt`
- Click "Commit new file to main"

#### File 3: Dockerfile
- Click "Add file" → "Create a new file"
- Name: `Dockerfile`
- Copy content from `backend_deployment/Dockerfile`
- Click "Commit new file to main"

#### File 4: README.md
- If README.md exists, click on it and "Edit"
- If not, "Add file" → "Create a new file"
- Name: `README.md`
- Copy content from `backend_deployment/README.md`
- The header must start with `---` (YAML frontmatter)
- Make sure it has:
  ```yaml
  ---
  title: Vatsalya Translation Service
  emoji: 🌐
  colorFrom: blue
  colorTo: green
  sdk: docker
  pinned: false
  ---
  ```
- Click "Commit changes"

### 3. Wait for Build
- Hugging Face will automatically rebuild your Space
- Watch the "Build" tab for progress
- Wait for "Running" status (may take 2-3 minutes)

### 4. Test the Deployment

Open PowerShell and run:

```powershell
# Test health endpoint
Invoke-WebRequest -Uri "https://samarth-006-vatsalya.hf.space/health" -Method Get

# Test single translation
$body = @{
    text = "Hello"
    source = "en"
    target = "hi"
} | ConvertTo-Json

Invoke-WebRequest -Uri "https://samarth-006-vatsalya.hf.space/translate" `
    -Method Post `
    -Headers @{"Content-Type"="application/json"} `
    -Body $body

# Test batch translation
$batchBody = @{
    text = @("Hello", "World", "How are you?")
    source = "en"
    target = "hi"
} | ConvertTo-Json

Invoke-WebRequest -Uri "https://samarth-006-vatsalya.hf.space/translate" `
    -Method Post `
    -Headers @{"Content-Type"="application/json"} `
    -Body $batchBody
```

### 5. Verify in App

Once the backend is running:

```bash
cd C:\Users\Sam\Code\APP\badal\Mayank\temp
flutter run
```

Then in the app:
1. Go to Profile page
2. Click on "Language" setting
3. Select "हिंदी (Hindi)"
4. Watch the console logs - you should see:
   ```
   🔄 Starting translation to hi...
   📝 Flattened XX translation keys
   🌐 Sending XX texts to translation API...
   📦 Received XX translated texts
   ✅ Translation complete for hi!
   ```
5. The entire app should now show Hindi text

## Common Issues

### Error: "Space is in error"
- Make sure the Dockerfile has correct syntax
- Check that requirements.txt doesn't have version conflicts
- View logs in the "Build" tab

### Error: "Connection timeout"
- The Space might be in cold start (first request takes 20-30 seconds)
- The health check in the Flutter app now waits 30 seconds
- Try again after the Space warms up

### Error: "502 Bad Gateway"
- The Space is starting up
- Wait 1-2 minutes and try again

### Translation not working in app
- Check console logs for error messages
- Verify the URL in `lib/data/repositories/translation_repository.dart` is correct:
  ```dart
  static const String _baseUrl = 'https://samarth-006-vatsalya.hf.space';
  ```

## Testing Specific Languages

### Hindi (हिंदी)
```powershell
$body = @{ text = "Welcome to Vatsalya"; source = "en"; target = "hi" } | ConvertTo-Json
Invoke-WebRequest -Uri "https://samarth-006-vatsalya.hf.space/translate" -Method Post -Headers @{"Content-Type"="application/json"} -Body $body
```
Expected: `वत्सल्य में आपका स्वागत है`

### Gujarati (ગુજરાતી)
```powershell
$body = @{ text = "Welcome to Vatsalya"; source = "en"; target = "gu" } | ConvertTo-Json
Invoke-WebRequest -Uri "https://samarth-006-vatsalya.hf.space/translate" -Method Post -Headers @{"Content-Type"="application/json"} -Body $body
```
Expected: `વત્સલ્યામાં આપનું સ્વાગત છે`

### Tamil (தமிழ்)
```powershell
$body = @{ text = "Welcome to Vatsalya"; source = "en"; target = "ta" } | ConvertTo-Json
Invoke-WebRequest -Uri "https://samarth-006-vatsalya.hf.space/translate" -Method Post -Headers @{"Content-Type"="application/json"} -Body $body
```
Expected: `வத்சல்யாவுக்கு வரவேற்கிறோம்`

## What Changed

The previous backend had these issues:
1. ❌ Couldn't handle list input (only single strings)
2. ❌ JSON parsing errors caused 500 responses
3. ❌ No proper error handling for batch requests

The new backend:
1. ✅ Handles both single strings AND arrays
2. ✅ Robust error handling with fallbacks
3. ✅ Detailed logging for debugging
4. ✅ CORS enabled for Flutter app
5. ✅ Proper Docker configuration
6. ✅ Health check endpoint

## Files Location

All deployment files are in:
```
C:\Users\Sam\Code\APP\badal\Mayank\temp\backend_deployment\
├── app.py           (Flask application)
├── requirements.txt (Python dependencies)
├── Dockerfile       (Container configuration)
└── README.md        (Space documentation)
```

## Support

If issues persist:
1. Check Hugging Face Space logs: https://huggingface.co/spaces/samarth-006/vatsalya/logs
2. Verify all 4 files are uploaded correctly
3. Make sure Space status shows "Running" not "Building" or "Error"
4. Try restarting the Space (Settings → Factory reboot)
