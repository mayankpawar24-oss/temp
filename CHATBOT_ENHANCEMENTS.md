# Vatsalya AI Chatbot Enhancements

## Overview
The Vatsalya AI chatbot has been enhanced with **emergency safety detection**, **comprehensive system instructions**, and **improved error handling** similar to the Flask backend example you provided.

---

## Key Features Implemented

### 🚨 1. Emergency Safety Detection

**Location:** `lib/domain/services/gemini_service.dart`

#### Emergency Keywords Detection:
```dart
static const List<String> _dangerWords = [
  'suicide', 'kill myself', 'overdose',
  'fainting', 'severe bleeding', 'unconscious',
  'heavy blood loss', 'miscarriage', 'premature labor',
  'preeclampsia', 'sepsis',
];
```

#### Emergency Response:
When any danger word is detected, the chatbot immediately returns a critical alert:

```
🚨 MEDICAL EMERGENCY DETECTED

This may indicate a serious health situation. Please:

1. **Call Emergency Services NOW** 
   - Dial 112 (India) or your local emergency number
   - Do not delay seeking immediate medical help

2. **Inform healthcare provider immediately** of your symptoms

3. **Do not rely on AI for emergency situations**

We care about your safety. Professional medical professionals are best equipped to help you right now.

Stay safe. Help is available.
```

**Implementation:**
- `_containsDangerWords(String text)` - Checks if message contains emergency keywords
- `_generateEmergencyResponse()` - Generates standardized emergency response
- Called **first** in `sendMessage()` before any API calls

---

### 2. Enhanced System Instructions

**Location:** `lib/presentation/viewmodels/ai_provider.dart`

#### Comprehensive Personality & Guidelines:

```
You are Vatsalya AI, a compassionate women's reproductive health and maternal care assistant.

FOCUS AREAS:
* Menstrual health and cycle tracking
* Pregnancy care across all trimesters
* Postpartum recovery and wellness
* Parenting and caring for toddlers
* Nutrition, hormonal balance, mental wellbeing

PERSONALITY:
* Warm and supportive
* Reassuring and empathetic
* Positive and encouraging
* Calm and gentle tone
* Non-judgmental and inclusive

STRICT RULES:
1. ALWAYS respond in an affirmative and comforting tone
2. Do NOT change medical facts just to agree with user
3. Do NOT diagnose diseases or medical conditions
4. Do NOT prescribe medicines, dosages, or specific treatments
5. ALWAYS encourage doctor/healthcare professional consultation
6. For out-of-scope: "I specialize in menstrual, pregnancy, and maternal health topics."
7. For emotional concerns: Show deep empathy and validate feelings
8. For danger symptoms: Recommend URGENT medical help

CRITICAL - NEVER OFFER MEDICAL DIAGNOSIS:
* Wrong: "You likely have preeclampsia"
* Right: "Please contact your healthcare provider urgently as these could indicate a serious condition"
```

#### Role-Specific Context:
- **Pregnant Users:** Pregnancy-specific guidance, trimester awareness
- **TTC Users:** Fertility, ovulation tracking, cycle awareness
- **Toddler Parents:** Child development, nutrition, behavior, parental wellbeing

---

### 3. Message Processing Flow

```
sendMessage(String message)
  ↓
[1] 🚨 Emergency Detection
    ↓
    Contains danger word? → Return emergency response
    ↓
[2] ✅ Normal Processing
    ↓
    Add user message to chat
    ↓
    Send to Gemini API with system instructions
    ↓
    Receive AI response
    ↓
[3] Error Handling
    ↓
    Network error → Network error message
    Rate limit → Rate limit message
    API key error → API key missing message
    Safety violation → Safety guidelines message
    ↓
[4] Save to History
    ↓
    Store in Hive chat history
```

---

## Code Changes

### File: `lib/domain/services/gemini_service.dart`

**Added:**
- Emergency keywords list
- `_containsDangerWords()` method
- `_generateEmergencyResponse()` method
- Emergency check in `sendMessage()` (priority #1)

**Benefits:**
- ✅ Catches critical health emergencies immediately
- ✅ Provides standardized emergency response
- ✅ No delay - happens before API call
- ✅ Consistent across all user types

---

### File: `lib/presentation/viewmodels/ai_provider.dart`

**Enhanced:**
- System instruction from basic (1 line) to comprehensive (40+ lines)
- Added personality definition
- Added strict medical guidelines
- Added role-specific context
- Improved example of what NOT to do

**Benefits:**
- ✅ Better AI responses aligned with app values
- ✅ Safer medical guidance
- ✅ Role-appropriate responses
- ✅ Consistent tone and approach

---

## Usage Examples

### Example 1: Emergency Detection
**User:** "I'm having severe bleeding and feeling faint"
**Result:** Immediate emergency response with 112 call instruction

### Example 2: Medical Question (Pregnant)
**User:** "Is it normal to have lower back pain in pregnancy?"
**Expected:** "Lower back pain is very common during pregnancy... While this is typically normal, please discuss any new or worsening pain with your healthcare provider."

### Example 3: Out of Scope
**User:** "What's the weather like today?"
**Expected:** "I specialize in menstrual, pregnancy, and maternal health topics. How can I help with those?"

### Example 4: Emotional Support
**User:** "I'm anxious about labor"
**Expected:** Empathetic validation + reassuring information + encouragement to discuss fears with healthcare provider

---

## Testing Recommendations

### Test Cases:

1. **Emergency Detection**
   - Send message with "suicide"
   - Send message with "severe bleeding"
   - Send message with "unconscious"
   - ✅ Should receive emergency response immediately

2. **Normal Pregnancy Questions**
   - "What should I eat during pregnancy?"
   - "Is morning sickness normal?"
   - "When will I feel baby move?"
   - ✅ Should receive relevant, supportive advice

3. **Role-Specific Responses**
   - Switch user role to "Pregnant" and ask pregnancy question
   - Switch user role to "TTC" and ask fertility question
   - Switch user role to "Toddler Parent" and ask parenting question
   - ✅ Each should receive role-appropriate guidance

4. **Medical Diagnosis Boundaries**
   - Ask: "Do I have gestational diabetes?"
   - ✅ Should NOT diagnose - should suggest doctor consultation

5. **Out of Scope Handling**
   - Ask unrelated question (sports, politics, etc.)
   - ✅ Should politely redirect to women's health topics

---

## Security & Safety Features

| Feature | Status | Details |
|---------|--------|---------|
| Emergency Detection | ✅ | Real-time keyword matching |
| Role-Based Guidance | ✅ | Personalized by user profile |
| No Diagnosis | ✅ | System instruction enforced |
| No Prescription | ✅ | Restricted in system prompt |
| Doctor Referral | ✅ | Encouraged for medical concerns |
| Chat History | ✅ | Stored in Hive locally |
| Error Handling | ✅ | Network, API key, rate limit |

---

## Future Enhancements

1. **Advanced Emergency Detection**
   - Regex patterns for more sophisticated matching
   - Severity scoring
   - Context awareness

2. **Response Personalization**
   - User pregnancy week awareness
   - Toddler age-specific advice
   - Symptom severity assessment

3. **Conversation Context**
   - Multi-turn question handling
   - Follow-up question support
   - Memory of previous topics

4. **Analytics**
   - Track frequently asked questions
   - Monitor emergency keyword frequency
   - User satisfaction ratings

---

## Files Modified

| File | Changes |
|------|---------|
| `lib/domain/services/gemini_service.dart` | Added emergency detection logic |
| `lib/presentation/viewmodels/ai_provider.dart` | Enhanced system instructions |

---

## Summary

The Vatsalya AI chatbot is now:
- 🚨 **Safe** - Emergency detection ensures critical situations are handled
- 💬 **Smart** - Comprehensive system instructions guide high-quality responses
- 🎯 **Specialized** - Role-specific guidance tailored to user journey
- ❤️ **Compassionate** - Warm, empathetic tone prioritizing user wellbeing

**Status:** ✅ **DEPLOYED** - Live on device, ready for testing
