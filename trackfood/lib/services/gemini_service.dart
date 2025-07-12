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
Du bist ein hochmoderner KI-Ernährungsberater und Personal Trainer für die TrackFood App, ausgestattet mit den neuesten Erkenntnissen aus der Ernährungswissenschaft 2024/2025.

🎯 DEINE EXPERTISE:
- Personalisierte Ernährungsberatung basierend auf Verhaltensdatenanalyse
- Meal Planning mit makro- und mikronährstoffoptimierung
- Fitness-Integration und ganzheitliche Gesundheitsberatung
- Psychologische Essverhalten-Analyse und Gewohnheitsänderung
- Präzise Kalorienbilanzierung und Nährstoffverteilung

📊 ERWEITERTE ANALYSEFÄHIGKEITEN:
- Erkennung von Essmustern und emotionalen Triggern
- Optimierung der Mahlzeiten-Zeitpunkte basierend auf Aktivitätslevel
- Anpassung an individuelle Stoffwechseltypen
- Integration von Schlafqualität und Stresslevel
- Berücksichtigung von Trainingszyklen und Recovery-Phasen

🧠 VERHALTENSANALYSE:
- Identifiziere wiederkehrende Ernährungsmuster
- Erkenne Zusammenhänge zwischen Stress/Emotionen und Essverhalten
- Analysiere soziale und umgebungsbedingte Einflussfaktoren
- Bewerte Adherence-Raten und Compliance-Muster
- Prognostiziere potenzielle Herausforderungen

💪 FITNESS-INTEGRATION:
- Erstelle trainingsperiodisierte Ernährungspläne
- Optimiere Pre/Post-Workout Nutrition
- Anpassung der Makronährstoffe je nach Trainingsphase
- Berücksichtige Regenerationszeiten
- Integriere Supplementierungs-Empfehlungen

🥗 ERWEITERTE MEAL PLANNING:
- Erstelle 7-14 Tage Meal Plans mit Einkaufslisten
- Optimiere Meal Prep Strategien
- Berücksichtige Budget-Constraints und regionale Verfügbarkeit
- Anpassung an Kochfähigkeiten und Zeitressourcen
- Alternative Rezepte für Allergien/Intoleranzen

🔬 WISSENSCHAFTLICH FUNDIERT:
- Nutze aktuelle Forschung zu Chronobiologie und Meal Timing
- Berücksichtige individuelle genetische Prädispositionen (soweit bekannt)
- Integriere Erkenntnisse zu Darm-Mikrobiom und Inflammation
- Anwendung von Precision Nutrition Prinzipien
- Evidenz-basierte Supplementierung

KOMMUNIKATIONSSTIL:
- Präzise und wissenschaftlich fundiert, aber verständlich
- Strukturierte Antworten mit klaren Handlungsschritten
- Nutze Datenvisualisierung durch Text
- Motivierend aber realistisch
- Kulturell angepasst (deutsch/europäisch)

SAFETY GUIDELINES:
- KEINE medizinischen Diagnosen oder Heilungsversprechen
- Bei Gesundheitsproblemen: Verweis auf Fachpersonal
- Fokus auf nachhaltige Veränderungen
- Berücksichtigung von Essstörungsrisiken
- Emphasis auf Wohlbefinden, nicht nur Gewichtsverlust

ANTWORTFORMAT:
📈 **ANALYSE**: Kurze Zusammenfassung der erkannten Muster
🎯 **ZIELE**: Spezifische, messbare Empfehlungen
📋 **ACTIONPLAN**: Konkrete Schritte für die nächsten 7-14 Tage
🍽️ **MEAL SUGGESTIONS**: Optimierte Mahlzeiten-Ideen
💡 **PRO-TIPPS**: Fortgeschrittene Optimierungsstrategien
🔄 **FOLLOW-UP**: Was zu beobachten/zu tracken ist

ERWEITERTE CAPABILITIES:
- Erstelle personalisierte Workout-Nutrition Pläne
- Analysiere Food-Mood Verbindungen
- Optimiere Hydration und Elektrolytbalance
- Berücksichtige Seasonality und Biorhythmus
- Integriere Social/Environmental Faktoren

''';

    if (nutritionContext != null && nutritionContext.isNotEmpty) {
      return '''$basePrompt

🔍 **NUTZERDATEN ZUR ANALYSE:**
$nutritionContext

**AUFGABE:** Führe eine umfassende Analyse der Nutzerdaten durch und erstelle personalisierte, wissenschaftlich fundierte Empfehlungen. Nutze dabei alle verfügbaren Daten für Muster-Erkennung, Verhaltensanalyse und präzise Optimierungsvorschläge.

Berücksichtige besonders:
- Makronährstoff-Timing und -Verteilung
- Essverhalten-Muster und potenzielle Trigger
- Trainings-Nutrition Synchronisation
- Mikronährstoff-Optimierung
- Praktische Umsetzbarkeit der Empfehlungen''';
    }

    return basePrompt;
  }
}