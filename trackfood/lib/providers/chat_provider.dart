import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import '../models/chat_message.dart';
import '../services/gemini_service.dart';
import '../services/nutrition_context_service.dart';

// This list is now a top-level constant, making it accessible without a class instance.
const List<String> kQuickActions = [
  "📊 7-Tage-Analyse",
  "⚠️ Problemstellen",
  "💪 Protein & Nährstoffe",
  "🍬 Zucker & Snacks",
  "🥗 Gesunde Alternativen",
  "📋 Wochenplan",
  "🎯 Ziel erreichen",
  "⚖️ Kalorien-Check",
  "🏋️ Fitness-Plan",
  "🍽️ Meal Prep",
  "⏰ Intermittent Fasting",
  "🥤 Hydration-Check",
];

class ChatProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final NutritionContextService _nutritionService = NutritionContextService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _error;
  ChatMessage? _lastUserMessage; // Store the last user message for retry

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get isLoading => _isLoading;
  String? get error => _error;

  ChatProvider() {
    _initializeChat();
  }

  void _initializeChat() {
    final welcomeMessage = ChatMessage(
      id: const Uuid().v4(),
      role: 'assistant',
      content: '''Hallo! 👋 Ich bin dein persönlicher KI-Ernährungsberater.

Ich helfe dir dabei:
• Deine Ernährungsgewohnheiten zu analysieren
• Gesunde Alternativen zu finden  
• Deine Ziele zu erreichen
• Motivation zu bleiben

Was kann ich heute für dich tun? Du kannst mir eine Frage stellen oder eine der Schnellaktionen nutzen! 😊''',
      timestamp: DateTime.now(),
    );

    _messages.add(welcomeMessage);
  }

  Future<void> sendMessage(String content, {String? nutritionContext}) async {
    if (content.trim().isEmpty || _isLoading) return;

    _error = null;

    // Add user message
    final userMessage = ChatMessage(
      id: const Uuid().v4(),
      role: 'user',
      content: content.trim(),
      timestamp: DateTime.now(),
    );

    _messages.add(userMessage);
    _isLoading = true;
    notifyListeners();

    try {
      // Get current user's nutrition context if not provided
      String? contextToUse = nutritionContext;
      if (contextToUse == null) {
        final user = Supabase.instance.client.auth.currentUser;
        if (user != null) {
          contextToUse = await _nutritionService.generateNutritionContext(
            user.id,
          );
        }
      }

      // Get AI response
      final response = await _geminiService.sendMessage(
        message: content.trim(),
        chatHistory: _messages
            .where((msg) => msg.role == 'user' || msg.role == 'assistant')
            .toList(),
        nutritionContext: contextToUse,
      );

      // Add AI response
      final aiMessage = ChatMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: response,
        timestamp: DateTime.now(),
      );

      _messages.add(aiMessage);
    } catch (e) {
      _lastUserMessage = userMessage; // Save the failed message
      final errorMessageText = e.toString().toLowerCase();
      if (errorMessageText.contains('503') || errorMessageText.contains('overloaded')) {
        _error = 'Der KI-Assistent ist gerade sehr gefragt. Bitte versuche es in ein paar Momenten erneut.';
      } else {
        _error = 'Ein unerwarteter Fehler ist aufgetreten. Bitte überprüfe deine Verbindung.';
      }

      // Add error message to chat
      final errorMessage = ChatMessage(
        id: const Uuid().v4(),
        role: 'assistant',
        content: 'Entschuldigung, es gab ein Problem bei der Kommunikation. Bitte versuche es erneut. 🤖',
        isError: true, // Mark this message as an error
        timestamp: DateTime.now(),
      );
      _messages.add(errorMessage);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> retryLastMessage() async {
    if (_lastUserMessage != null) {
      // Remove the last two messages (the user's failed message and the AI's error response)
      if (_messages.length >= 2) {
        _messages.removeRange(_messages.length - 2, _messages.length);
      }
      final messageToSend = _lastUserMessage!;
      _lastUserMessage = null; // Clear after retrying
      await sendMessage(messageToSend.content);
    }
  }

  void clearChat() {
    _messages.clear();
    _error = null;
    _initializeChat();
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Future<void> sendQuickAction(
    String action, {
    String? nutritionContext,
  }) async {
    // Always fetch fresh nutrition context for quick actions to ensure latest data
    String? contextToUse = nutritionContext;
    if (contextToUse == null) {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        try {
          contextToUse = await _nutritionService.generateNutritionContext(
            user.id,
          );
        } catch (e) {
          // Continue without context if there's an error
        }
      }
    }
    String prompt;

    switch (action) {
      case "📊 7-Tage-Analyse":
        prompt =
            "Führe eine umfassende 7-Tage-Analyse meiner Ernährung durch. Analysiere Muster, Verhaltenstrends und gib mir wissenschaftlich fundierte Verbesserungsvorschläge.";
        break;
      case "⚠️ Problemstellen":
        prompt =
            "Identifiziere die kritischen Problemstellen in meiner Ernährung durch Verhaltensanalyse. Zeige mir konkrete Lösungsstrategien auf.";
        break;
      case "💪 Protein & Nährstoffe":
        prompt =
            "Analysiere meine Protein- und Mikronährstoffaufnahme im Detail. Bewerte die Timing-Optimierung und gib mir Supplementierungs-Empfehlungen.";
        break;
      case "🍬 Zucker & Snacks":
        prompt =
            "Führe eine Zucker- und Snack-Analyse durch. Erkenne emotionale Trigger und erstelle einen Plan für gesunde Alternativen.";
        break;
      case "🥗 Gesunde Alternativen":
        prompt =
            "Basierend auf meinen häufigsten Lebensmitteln, erstelle eine Liste mit gesünderen Alternativen inklusive Zubereitungstipps.";
        break;
      case "📋 Wochenplan":
        prompt =
            "Erstelle einen detaillierten 7-Tage-Meal-Plan mit Einkaufsliste, Meal-Prep-Strategien und Makronährstoff-Optimierung basierend auf meinen Daten.";
        break;
      case "🎯 Ziel erreichen":
        prompt =
            "Analysiere meine Fortschritte und erstelle einen präzisen Action-Plan für die nächsten 14 Tage mit messbaren Zielen.";
        break;
      case "⚖️ Kalorien-Check":
        prompt =
            "Führe eine vollständige Kalorienbilanz-Analyse durch inklusive BMR-Berechnung, Aktivitätslevel und Optimierungsvorschläge.";
        break;
      case "🏋️ Fitness-Plan":
        prompt =
            "Erstelle einen personalisierten Fitness- und Trainingsplan der optimal zu meiner Ernährung passt. Berücksichtige Pre/Post-Workout Nutrition.";
        break;
      case "🍽️ Meal Prep":
        prompt =
            "Entwickle eine Meal-Prep-Strategie für die nächste Woche mit effizienten Rezepten, Einkaufsliste und Zeitmanagement.";
        break;
      case "⏰ Intermittent Fasting":
        prompt =
            "Analysiere mein Essverhalten und empfehle ein optimales Intermittent Fasting Protokoll. Erkläre die Implementierung Schritt für Schritt.";
        break;
      case "🥤 Hydration-Check":
        prompt =
            "Bewerte meine Hydratation im Verhältnis zu Training, Ernährung und Zielen. Gib mir einen optimierten Hydration-Plan.";
        break;
      default:
        prompt = action;
    }

    await sendMessage(prompt, nutritionContext: contextToUse);
  }
}
