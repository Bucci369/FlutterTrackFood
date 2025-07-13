<!-- Use this file to provide workspace-specific custom instructions to Copilot. For more details, visit https://code.visualstudio.com/docs/copilot/copilot-customization#_use-a-githubcopilotinstructionsmd-file -->



# Flutter Example Apps Project

This workspace contains multiple Flutter example applications demonstrating various Flutter concepts and widgets.

## Development Guidelines

- This project contains Flutter/Dart code examples
- Follow Flutter coding conventions and best practices
- Use proper widget naming conventions (PascalCase for widget classes)
- Implement proper state management patterns
- Ensure responsive design principles
- Use appropriate Flutter widgets for each use case
- Follow Material Design guidelines
- Write clean, readable, and well-commented code
- Use proper error handling and null safety
- Optimize for performance and user experience

## Project Structure

- Each example should be self-contained and demonstrate a specific Flutter concept
- Use meaningful file and class names
- Group related functionality together
- Maintain consistent code formatting using `dart format`

## Testing

- Write unit tests for business logic
- Include widget tests for UI components
- Ensure all examples compile and run without errors



# Copilot Custom Instructions for TrackFood Migration

Dieses Projekt ist eine Migration der TrackFood Next.js/React WebApp nach Flutter. Ziel ist es, alle Features der WebApp in Flutter zu übertragen und zu optimieren:

## Architektur & Features aus der WebApp
- Modularer Aufbau: Jede Funktion (Onboarding, Dashboard, Diary, Activities, Scanner, Chat, Recipes, Profile) ist ein eigener Screen/Widget.
- Multi-Step-Onboarding: Name, Alter, Geschlecht, Größe, Gewicht, Ziel, Ernährungsweise, Zielgewicht, Zusammenfassung. Status wird in Supabase gespeichert und geprüft.
- Dashboard: Zeigt Makros, Aktivitäten, Fasten, Challenges, Trends. Pull-to-Refresh und Swiper für Übersicht.
- Diary & Activities: Mahlzeiten und Aktivitäten werden mit Supabase gespeichert. Berechnung von Kalorien, Makros, MET etc.
- Barcode-Scanner: Produktdaten werden per Barcode und API geladen. Produktinformationen und Nährwerte werden angezeigt.
- KI-Chat: Chat mit Rollen (user/assistant), Markdown-Rendering, API-Anbindung.
- Rezepte: Rezept-Suche, Kategorien, Favoriten, Supabase als Backend.
- Profil: Profilbearbeitung, BMI-Berechnung, Ziel- und Unverträglichkeiten.
- State-Management: Zustand wird mit Provider/Riverpod verwaltet.
- Authentifizierung: Supabase Auth, Google Login, Onboarding-Status-Check.

## Flutter-Migrationsstrategie
- Übernehme die Struktur: Jeder Bereich als eigener Screen/Widget.
- Nutze Provider oder Riverpod für State-Management.
- Baue das Onboarding als Multi-Step-Form.
- Implementiere Barcode-Scanner, Chat, Dashboard, Diary, Activities analog zur WebApp.
- Nutze Supabase für Auth, Daten und Storage.
- UI: Material Design, Responsive, Animationen wie Swiper, Pull-to-Refresh, Progress-Rings.


## Flutter Best Practices & Additional Coding Guidelines
- Klare Projektstruktur: lib/screens, lib/widgets, lib/models, lib/services, lib/state oder lib/providers.
- Trenne UI, Logik und Datenzugriff (MVVM oder Clean Architecture empfohlen).
- State-Management: Provider für einfache Apps, Riverpod oder Bloc für komplexe Apps.
- Navigation: Nutze go_router für deklarative Navigation und Deep Links.
- Fehlerbehandlung: Immer try/catch bei Netzwerk- und Datenbankoperationen.
- Dart Null Safety überall nutzen.
- Responsive Design: MediaQuery, LayoutBuilder, ggf. flutter_screenutil.
- Material Design Widgets und Themes konsequent verwenden.
- Performance: const-Widgets, Lazy Loading, cached_network_image, rebuilds minimieren.
- Security: Keine sensiblen Daten im Klartext, flutter_secure_storage für Tokens.
- Codequalität: dart format, dart analyze, very_good_analysis für Linting.
- Dokumentation und Kommentare für alle wichtigen Klassen und Methoden.
- Push-Benachrichtigungen: firebase_messaging oder onesignal_flutter.
- Schrittzähler: pedometer oder health-Paket verwenden.
- Folge allen Anweisungen in .github/copilot-instructions.md.
- Schreibe sauberen, kommentierten und performanten Code.
- Fehlerbehandlung und Null-Safety beachten.

### UI/UX Best Practices für Flutter (2025)
- Material 3 (`useMaterial3: true`) und Cupertino-Widgets für modernes, plattformgerechtes Design
- Konsistentes Farbschema mit ColorScheme, Light/Dark Mode
- Moderne Typografie mit Google Fonts
- Klare Abstände und Layouts mit Padding, SizedBox, GridView, SliverList
- Sanfte Animationen mit flutter_animate, Hero, AnimatedContainer, AnimatedSwitcher
- Micro-Interactions: Button-Feedback, Lade-Animationen (shimmer), Progress-Rings
- Navigation: BottomNavigationBar, NavigationRail, Floating Action Button
- Cards, Schatten, abgerundete Ecken für visuelle Tiefe
- Icons aus font_awesome_flutter, MaterialIcons, lucide_icons
- Adaptive Layouts für Tablet/Desktop mit MediaQuery, LayoutBuilder
- Barrierefreiheit: semanticsLabel, hohe Kontraste, große Touch-Flächen, dynamische Schriftgrößen
- Klare User-Flows, sofortiges Feedback (SnackBar, Dialog, Toast)
- Wiederverwendbare Custom Widgets für Buttons, Cards, Inputs
- Bilder: cached_network_image, Animationen mit rive oder lottie
- Design-Inspiration: Google Fit, Apple Health, Notion, Revolut, Headspace
- Design-Tools: Figma, Adobe XD, FlutterFlow für Mockups und Prototyping

## Testing
- Schreibe Unit-Tests für Logik (flutter_test, mockito, riverpod_test).
- Widget-Tests für UI-Komponenten.
- Integrationstests für User-Flows.
- Alle Beispiele müssen fehlerfrei kompilieren und laufen.

---

Für Details siehe .github/copilot-instructions.md und die WebApp-Quellen.
