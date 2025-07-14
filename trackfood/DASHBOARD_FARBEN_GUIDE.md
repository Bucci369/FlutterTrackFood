# 🎨 DASHBOARD FARBEN GUIDE

## 📱 **HAUPT-HINTERGRUND**
```dart
Color(0xFF000000) // Reines Schwarz (oben)
Color(0xFF0A0A0A) // Dunkelgrau (unten)
```

## 🃏 **KARTEN-HINTERGRÜNDE** 
```dart
// Alle Hauptkarten verwenden diesen Gradient:
Color(0xFF1A1A1A) // Dunkelgrau (oben/unten)
Color(0xFF2A2A2A) // Helleres Grau (mitte)
```

## 💬 **TEXTE**
```dart
CupertinoColors.white                    // Haupttexte: Weiß
CupertinoColors.white.withValues(alpha: 0.8)  // Sekundärtexte: Weiß 80%
CupertinoColors.white.withValues(alpha: 0.7)  // Tertiärtexte: Weiß 70%
CupertinoColors.white.withValues(alpha: 0.6)  // Labels: Weiß 60%
```

## 🔳 **RAHMEN & BORDERS**
```dart
CupertinoColors.white.withValues(alpha: 0.2)  // Hauptrahmen: Weiß 20%
CupertinoColors.white.withValues(alpha: 0.15) // Sekundärrahmen: Weiß 15%
```

## ✨ **SCHATTEN & GLOW-EFFEKTE**
```dart
CupertinoColors.white.withValues(alpha: 0.1)  // Hauptschatten: Weiß 10%
CupertinoColors.white.withValues(alpha: 0.05) // Sekundärschatten: Weiß 5%
CupertinoColors.black.withValues(alpha: 0.8)  // Tiefenschatten: Schwarz 80%
```

## 🎯 **SYSTEM-FARBEN (iOS Native)**
```dart
AppColors.systemBlue     // #007AFF - Hauptakzent
AppColors.systemRed      // #FF3B30 - Kalorien/Fehler
AppColors.systemGreen    // #34C759 - Erfolg/Bestätigung
AppColors.systemOrange   // #FF9500 - Warnung/Schritte
AppColors.systemPurple   // #AF52DE - Spezielle Aktionen
AppColors.systemYellow   // #FFCC00 - Info/Hinweise
```

## 🔄 **GRADIENT-KOMBINATIONEN**
```dart
// Standard Karten-Gradient:
[Color(0xFF1A1A1A), Color(0xFF2A2A2A), Color(0xFF1A1A1A)]

// Für Buttons/Badges mit Systemfarben:
[systemColor, systemColor.withValues(alpha: 0.8)]

// Für Container/Items:
[Color(0xFF2A2A2A), Color(0xFF1A1A1A), Color(0xFF2A2A2A)]
```

## 🎨 **SPEZIELLE KOMPONENTEN**

### Concentric Progress Rings:
- **Äußerer Ring (Kalorien)**: `CupertinoColors.systemRed.darkColor`
- **Mittlerer Ring (Wasser)**: `CupertinoColors.systemBlue` 
- **Innerer Ring (Verbrannt)**: `CupertinoColors.systemOrange`

### Macro Grid Farben:
- **Eiweiß**: `CupertinoColors.systemRed`
- **Kohlenhydrate**: `CupertinoColors.systemBlue`
- **Fett**: `CupertinoColors.systemGreen`
- **Ballaststoffe**: `CupertinoColors.systemOrange`
- **Zucker**: `CupertinoColors.systemPurple`
- **Natrium**: `CupertinoColors.systemYellow`

### Chart Grid Lines:
```dart
CupertinoColors.white.withValues(alpha: 0.3) // Sichtbare Gitterlinien
```

---

## 🛠️ **ANPASSUNGS-TIPPS**

1. **Helligkeit ändern**: Ändere die Alpha-Werte (0.1 = 10%, 0.5 = 50%, 1.0 = 100%)
2. **Hauptfarbe ändern**: Tausche `Color(0xFF1A1A1A)` und `Color(0xFF2A2A2A)` aus
3. **Akzentfarben**: Ändere die `AppColors.system*` Farben für andere Töne
4. **Kontrast**: Erhöhe Alpha-Werte für mehr Sichtbarkeit, verringere für subtilere Effekte

## 🔍 **SUCHEN & ERSETZEN**
- Alle Karten-Hintergründe: Suche nach `Color(0xFF1A1A1A)` und `Color(0xFF2A2A2A)`
- Alle Texte: Suche nach `CupertinoColors.white`
- Alle Rahmen: Suche nach `.withValues(alpha:`