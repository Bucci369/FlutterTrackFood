Vorteil: Die App fühlt sich ganzheitlicher an. Die neuen Features sind präsent, aber stören nicht den Hauptfokus des Dashboards auf die Makro- und Kalorienübersicht.

Zusammenfassung der neuen Struktur:
Feature	Integration in Screen	UI-Element
Eigene Rezepte erstellen	RecipesScreen	Button / ListTile
Einkaufsliste	RecipesScreen	Button / ListTile
"Was ist im Kühlschrank?"	RecipesScreen	Button / ListTile
Körpermaße & Fortschrittsfotos	ProfileScreen	Neuer "Fortschritt"-Tab
Erfolge & Abzeichen	ProfileScreen	Neuer "Erfolge"-Tab
Stimmungs- & Energie-Tracking	DashboardScreen	Neue "Wohlbefinden"-Karte
Meditationen	DashboardScreen	Button in der "Wohlbefinden"-Karte
Mikronährstoff-Tracking	DiaryScreen	Erweiterung der Nährwert-Zusammenfassung
Apple Health / Google Fit	ProfileScreen	Neuer "Verbindungen"-Tab oder Einstellungs-Eintrag


# TrackFood App: Zukünftige Features & To-Do-Liste

Hier ist eine Liste potenzieller neuer Features, die auf einer Analyse führender Ernährungs- und Fitness-Apps basieren. Wir können diese Liste als Roadmap für die Weiterentwicklung verwenden.

## 📋 To-Do

### Kategorie 1: Intelligente Alltagshelfer (Hoher Mehrwert)
- [ ] **Eigene Rezepte & Mahlzeiten erstellen:** Nutzern erlauben, ihre eigenen Rezepte und Mahlzeiten zu speichern.
- [ ] **Automatische Einkaufsliste:** Basierend auf ausgewählten Rezepten eine Einkaufsliste generieren.
- [ ] **"Was ist im Kühlschrank?"-Rezeptvorschläge:** Nutzern basierend auf vorhandenen Zutaten Rezepte vorschlagen.

### Kategorie 2: Ganzheitliches Wohlbefinden (Mind & Body)
- [ ] **Geführte Meditationen & Achtsamkeitsübungen:** Eine Bibliothek mit Audio-Meditationen zu Themen wie "Achtsam essen" oder "Stressabbau" integrieren.
- [ ] **Stimmungs- & Energie-Tracking:** Tägliche Abfrage von Stimmung und Energielevel, um Korrelationen zur Ernährung aufzuzeigen.

### Kategorie 3: Detailliertes Tracking & Analyse (Für Power-User)
- [ ] **Mikronährstoff-Tracking:** Tracking von Vitaminen und Mineralstoffen zusätzlich zu Makros implementieren.
- [ ] **Körpermaße aufzeichnen:** Nutzern ermöglichen, neben dem Gewicht auch Umfänge (Taille, Hüfte etc.) zu speichern.
- [ ] **Fortschrittsfotos:** Eine private Galerie für Vorher-Nachher-Bilder implementieren.

### Kategorie 4: Soziale Features & Community
- [ ] **Freundeslisten & Community-Feed:** Nutzern erlauben, Freunde hinzuzufügen und deren Fortschritte zu sehen.
- [ ] **Herausforderungen (Challenges):** Wöchentliche/monatliche Challenges erstellen, an denen Nutzer teilnehmen und sich messen können.
- [ ] **Erfolge & Abzeichen (Achievements):** Nutzer für erreichte Meilensteine mit digitalen Abzeichen belohnen.

### Kategorie 5: Konnektivität
- [ ] **Integration von Apple Health & Google Fit:** Automatische Synchronisierung von Schritten, Workouts und Gewicht von Wearables.

---

## ✅ Erledigt

- [x] **Schrittzähler:** Implementiert mit `pedometer`-Package, Supabase-Backend und UI-Integration auf dem Dashboard.
- [x] **Rezept-Browser:** Implementiert mit Anbindung an die Supabase-DB, Suche, Filter und Weiterleitung.
- [x] **Barcode-Scanner:** Implementiert mit `mobile_scanner` für Live- und Foto-Scans.
- [x] **Profil-Verwaltung:** Umfassend implementiert und mit allen App-Bereichen verknüpft.
