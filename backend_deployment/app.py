from flask import Flask, request, jsonify
from flask_cors import CORS
from googletrans import Translator
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

app = Flask(__name__)
CORS(app)  # Enable CORS for Flutter app
translator = Translator()

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({"status": "healthy"}), 200

@app.route('/translate', methods=['POST'])
def translate():
    """
    Translate text from source to target language
    
    Request body (single text):
    {
        "text": "Hello",
        "source": "en",
        "target": "hi"
    }
    
    Request body (batch):
    {
        "text": ["Hello", "World", "How are you?"],
        "source": "en",
        "target": "hi"
    }
    
    Response (single):
    {
        "translated_text": "नमस्ते"
    }
    
    Response (batch):
    {
        "translations": ["नमस्ते", "दुनिया", "आप कैसे हैं?"]
    }
    """
    try:
        data = request.get_json()
        
        if not data:
            return jsonify({"error": "No JSON data provided"}), 400
        
        text = data.get('text')
        source = data.get('source', 'en')
        target = data.get('target', 'hi')
        
        if not text:
            return jsonify({"error": "Missing 'text' field"}), 400
        
        logger.info(f"Translation request - Source: {source}, Target: {target}")
        
        # Handle batch translation (list of strings)
        if isinstance(text, list):
            if not text:  # Empty list
                return jsonify({"translations": []}), 200
            
            logger.info(f"Batch translating {len(text)} texts")
            translations = []
            
            for idx, t in enumerate(text):
                if not t or not isinstance(t, str):
                    translations.append("")
                    continue
                
                try:
                    result = translator.translate(t, src=source, dest=target)
                    translations.append(result.text)
                    if idx % 10 == 0:  # Log progress every 10 items
                        logger.info(f"Translated {idx + 1}/{len(text)} items")
                except Exception as e:
                    logger.error(f"Error translating item {idx}: {str(e)}")
                    translations.append(t)  # Use original text on error
            
            logger.info(f"Batch translation complete: {len(translations)} texts")
            return jsonify({"translations": translations}), 200
        
        # Handle single text translation
        elif isinstance(text, str):
            if not text.strip():
                return jsonify({"translated_text": ""}), 200
            
            logger.info(f"Translating single text: '{text[:50]}...'")
            result = translator.translate(text, src=source, dest=target)
            
            return jsonify({
                "translated_text": result.text,
                "source_language": result.src,
                "target_language": target
            }), 200
        
        else:
            return jsonify({"error": "'text' must be string or array"}), 400
            
    except Exception as e:
        logger.error(f"Translation error: {str(e)}")
        return jsonify({"error": str(e)}), 500

if __name__ == '__main__':
    # Hugging Face Spaces uses port 7860 by default
    app.run(host='0.0.0.0', port=7860, debug=False)
