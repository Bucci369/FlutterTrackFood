import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/chat_message.dart';

class GeminiService {
  static const String _baseUrl = 'https://generativelanguage.googleapis.com/v1beta/models';
  static const String _model = 'gemini-1.5-flash';
  
  late final String _apiKey;

  GeminiService() {
    _apiKey = dotenv.env['GEMINI_API_KEY'] ?? '';
    if (_apiKey.isEmpty) {
      throw Exception('GEMINI_API_KEY not found in environment variables');
    }
  }

  Future<String> sendMessage({
    required String message,
    required List<ChatMessage> chatHistory,
    String? nutritionContext,
  }) async {
    try {
      final url = '$_baseUrl/$_model:generateContent?key=$_apiKey';
      
      // Build conversation context
      final List<Map<String, dynamic>> contents = [];
      
      // Add system prompt with nutrition context
      contents.add({
        'role': 'user',
        'parts': [{'text': _buildSystemPrompt(nutritionContext)}]
      });
      
      // Add chat history
      for (final msg in chatHistory) {
        contents.add({
          'role': msg.role == 'user' ? 'user' : 'model',
          'parts': [{'text': msg.content}]
        });
      }
      
      // Add current message
      contents.add({
        'role': 'user',
        'parts': [{'text': message}]
      });

      final requestBody = {
        'contents': contents,
        'generationConfig': {
          'temperature': 0.7,
          'topK': 40,
          'topP': 0.95,
          'maxOutputTokens': 1000,
        },
        'safetySettings': [
          {
            'category': 'HARM_CATEGORY_HARASSMENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_HATE_SPEECH',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_SEXUALLY_EXPLICIT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          },
          {
            'category': 'HARM_CATEGORY_DANGEROUS_CONTENT',
            'threshold': 'BLOCK_MEDIUM_AND_ABOVE'
          }
        ]
      };

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final candidates = responseData['candidates'] as List<dynamic>?;
        
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List<dynamic>;
          
          if (parts.isNotEmpty) {
            return parts[0]['text'] ?? 'Keine Antwort erhalten';
          }
        }
        
        return 'Keine gültige Antwort von der KI erhalten';
      } else {
        throw Exception('API Error: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Fehler bei der KI-Kommunikation: $e');
    }
  }

  String _buildSystemPrompt(String? nutritionContext) {
    final basePrompt = '''
Du bist ein freundlicher KI-Ernährungsberater für die TrackFood App. 

PERSÖNLICHKEIT:
- Warm, humorvoll und unterstützend
- Führe erstmal lockere Gespräche, bevor du in die Tiefe gehst
- Frage IMMER nach, bevor du lange, detaillierte Analysen machst
- Verwende Humor und sei nahbar
- Antworte kurz und prägnant, außer der Nutzer möchte Details

VERHALTEN:
- Bei Begrüßungen (Hi, Hallo, etc.): Antworte kurz und freundlich
- Bei Smalltalk: Sei gesprächig und interessiert
- Bei Ernährungsfragen: Gib erst eine kurze Antwort, dann frage "Möchtest du eine detaillierte Analyse?"
- Bei komplexen Anfragen: Erkläre verständlich, nicht wissenschaftlich überladen

KOMMUNIKATION:
- Kurze, freundliche Antworten standardmäßig
- Nutze deutsche Umgangssprache
- Sei motivierend aber realistisch
- Frage nach, bevor du lange Texte schreibst

SICHERHEIT:
- Keine medizinischen Diagnosen
- Bei Gesundheitsproblemen: Empfehle Fachpersonal
- Fokus auf gesunde, nachhaltige Gewohnheiten
''';

    if (nutritionContext != null && nutritionContext.isNotEmpty) {
      return '''$basePrompt

NUTZERDATEN:
$nutritionContext

Nutze diese Daten nur wenn der User explizit nach einer Analyse fragt. Ansonsten antworte normal und freundlich.''';
    }

    return basePrompt;
  }
}