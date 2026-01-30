---
title: Vatsalya Translation Service
emoji: 🌐
colorFrom: blue
colorTo: green
sdk: docker
pinned: false
---

# Vatsalya Translation Service

Backend translation API for the Vatsalya maternal & infant care app.

## Endpoints

### GET /health
Health check endpoint

**Response:**
```json
{
  "status": "healthy"
}
```

### POST /translate
Translate text from one language to another

**Single Text Request:**
```json
{
  "text": "Hello",
  "source": "en",
  "target": "hi"
}
```

**Single Text Response:**
```json
{
  "translated_text": "नमस्ते",
  "source_language": "en",
  "target_language": "hi"
}
```

**Batch Request:**
```json
{
  "text": ["Hello", "World", "How are you?"],
  "source": "en",
  "target": "hi"
}
```

**Batch Response:**
```json
{
  "translations": ["नमस्ते", "दुनिया", "आप कैसे हैं?"]
}
```

## Supported Languages

- `en` - English
- `hi` - Hindi
- `gu` - Gujarati
- `ta` - Tamil
- `te` - Telugu
- `kn` - Kannada
- `ml` - Malayalam
- `mr` - Marathi
- `bn` - Bengali

## Tech Stack

- Flask 3.0.0
- googletrans 4.0.0rc1
- Docker
- Python 3.10

## Local Development

```bash
pip install -r requirements.txt
python app.py
```

The server runs on `http://localhost:7860`
