# Flutter Installation Guide für macOS

## Option 1: Flutter über Homebrew installieren (Empfohlen)

```bash
# Homebrew installieren (falls noch nicht installiert)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Flutter installieren
brew install --cask flutter

# Pfad zur Shell-Konfiguration hinzufügen
echo 'export PATH="$PATH:/opt/homebrew/bin/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

## Option 2: Manuelle Installation

```bash
# Flutter SDK herunterladen
curl -L https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_stable.zip -o flutter.zip

# Entpacken
unzip flutter.zip

# In ein dauerhaftes Verzeichnis verschieben
sudo mv flutter /opt/

# Pfad zur Shell hinzufügen
echo 'export PATH="$PATH:/opt/flutter/bin"' >> ~/.zshrc
source ~/.zshrc
```

## Nach der Installation

```bash
# Flutter-Installation überprüfen
flutter doctor

# Fehlende Abhängigkeiten installieren
flutter doctor --android-licenses  # für Android
```

## Xcode für iOS-Entwicklung

```bash
# Xcode aus dem App Store installieren
# Dann Kommandozeilen-Tools konfigurieren
sudo xcode-select --switch /Applications/Xcode.app/Contents/Developer
sudo xcodebuild -runFirstLaunch
```

## Android Studio (optional)

- Lade Android Studio herunter: https://developer.android.com/studio
- Installiere Flutter und Dart Plugins
- Konfiguriere Android SDK

## VS Code Extensions

Die folgenden Extensions wurden bereits installiert:
- Flutter (Dart-Code.flutter)
- Dart (Dart-Code.dart-code)

## Projekt ausführen

Nach der Flutter-Installation:

```bash
# Einfaches Dart-Beispiel
dart main.dart

# Für Flutter-Apps (in jeweiligem App-Verzeichnis)
flutter pub get
flutter run
```
