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


Flutter-Anfänger-Tutorial: Von den Grundlagen zur App-Entwicklung
Einführung
Hey, was geht? Willkommen zum Flutter-Anfängerkurs! Ich bin Mitch und ich bring dir als kompletter Anfänger, der noch nie programmiert hat, bei, wie man mit Flutter richtig coole Apps baut. Warum ich den Kurs gemacht hab? Weil ich mir genau so was gewünscht hätte, als ich mit Flutter angefangen hab. Kein Witz – der Kurs könnte fast ein Informatikstudium ersetzen, weil ich dir alles von Grund auf erkläre, ganz ohne Vorkenntnisse. Ich versetz mich voll in deine Lage!
Du brauchst keine Programmiererfahrung, aber eins solltest du haben: Flutter auf deinem Rechner installiert und wissen, wie man ein neues Flutter-Projekt öffnet. Wenn du das kannst, übernehme ich den Rest.
Kursübersicht
Wir fangen ganz von vorne an, mit den Basics der Programmiergrundlagen. In Flutter ist nämlich alles ein Widget, deshalb zeige ich dir die wichtigsten Widgets, die jeder Entwickler kennen muss. Danach schauen wir uns:
 * Navigation: Wie man zwischen verschiedenen Bildschirmen hin und her wechselt.
 * Widget-Typen: Den Unterschied zwischen Stateless und Stateful Widgets – ein super wichtiges Thema!
 * Nutzer-Eingabe: Wie man Benutzereingaben verarbeitet.
 * To-Do-App: Wie du das alles zusammensetzt und eine funktionierende To-Do-App baust.
 * Lokale Datenspeicherung: Wie du die Daten lokal auf dem Handy speichern kannst.
 * E-Commerce-App: Zum Schluss machen wir noch eine Art E-Commerce-App mit einem richtig schicken Design und den nötigen Funktionen, wie zum Beispiel Sachen in den Warenkorb legen.
Das ist also der Plan für den Kurs.
Allgemeine Tipps
Bevor wir loslegen, noch ein paar allgemeine Tipps:
 * Nutze das Internet: Denk dran, du hast das ganze Internet zur Hand. Wenn du also auf etwas stößt, das du nicht verstehst, ist es wichtig, die Frage zu formulieren und nach der Antwort zu suchen – genau so lernt man.
 * Praktische Erfahrung: Was noch wichtiger ist als den Kurs zu machen, ist einfach, dich hinzusetzen, vor den Computer zu setzen und zu programmieren. Es gibt viele kleine Feinheiten, die schwierig sind, nur durch Lesen oder Zuschauen zu lernen, also sorg dafür, dass du echt Zeit und Stunden reinsteckst, um das zu checken.
Flutter-Projekt einrichten
So, jetzt ist der ganze Kram geklärt, ich bin bereit, wenn du es bist. Also fangen wir ganz von vorne an. Ich hab ein nagelneues Flutter-Projekt aufgemacht, und du solltest jetzt diese Demo-Umgebung sehen. Ich lösche jetzt einfach alles unterhalb der main-Funktion, damit ich dir zeigen kann, wie man das von Grund auf macht – so läuft das bei jedem Code-Setup.
Alles startet immer mit dieser Hauptfunktion, und du siehst, wir starten einfach unsere App. Also lass uns schnell unsere App erstellen. In Flutter gibt’s zwei Arten von Widgets: Stateless und Stateful. Ich nehme erstmal das Stateless Widget, später erkläre ich dir den Unterschied genauer. Das erste, was du immer machen musst, ist, ein MaterialApp zurückzugeben, das bildet die Grundlage für alles.
Wenn du das speicherst, wird es einfach ein dunkler Bildschirm, weil da nix drin ist, und im home legen wir einfach ein Scaffold fest, also wird das 'ne leere App sein, die die Grundlage für alles andere ist, was wir noch machen. Eine Sache: Man sieht dieses Debug-Banner, das zeigt halt, dass die App noch in Entwicklung ist. Das mag ich nicht, also setze ich das einfach auf false. So haben wir 'ne saubere App. Und die blauen Wellenlinien siehst du, weil sie wollen, dass wir noch ein const-Tag einfügen, aber mach dir erstmal keine großen Sorgen deswegen, ich erkläre das später noch genauer.
Programmiergrundlagen
Bevor wir uns mit App-Entwicklung beschäftigen, sollten wir uns zuerst die Programmier-Grundlagen anschauen. Ich bring das so rüber, als ob du noch gar keine Ahnung vom Coden hast, und ich mach dich mit allen Basics vertraut, die wir zum Programmieren brauchen.
Variablen
Die allererste Idee ist eine Variable – damit können wir verschiedene Arten von Informationen speichern.
 * String: Ein String ist einfach eine Zeichenkette, also kurz gesagt Text. Zum Beispiel: String meinName = "Mitch Coco";
 * Integer (int): Das sind ganze Zahlen. Zum Beispiel: int meinAlter = 27;
 * Double: Für Zahlen mit Nachkommastellen, also Dezimalzahlen. Zum Beispiel: double pi = 3.14;
 * Boolean (bool): Bedeutet einfach, dass der Wert entweder true (wahr) oder false (falsch) ist. Zum Beispiel: bool istAnfaenger = true;
Das sind die Hauptvariablen, die du kennen solltest. Es gibt noch andere Variablen, die du unterwegs lernen wirst, aber diese vier sind die wichtigsten.
Operatoren
Jetzt, wo wir Informationen in verschiedenen Variablen gespeichert haben, können wir uns ein paar grundlegende Operatoren anschauen.
Mathematische Operatoren
 * Addition: + (z.B. 1 + 1 ist 2)
 * Subtraktion: - (z.B. 4 - 1 ist 3)
 * Multiplikation: * (z.B. 2 * 3 ist 6)
 * Division: / (z.B. 6 / 2 ist 3)
 * Modulo (Rest): % (z.B. 9 % 4 ist 1, da 9 geteilt durch 4 2 Rest 1 ist)
 * Inkrementieren: ++ (z.B. i++ erhöht i um 1)
 * Dekrementieren: -- (z.B. i-- verringert i um 1)
Du kannst print()-Befehle in deiner main-Funktion verwenden, um diese Operationen in der Konsole zu testen, z.B. print(1 + 5); oder print(9 % 4);.
Vergleichsoperatoren
Diese Operatoren prüfen, ob zwei Werte gleich oder ungleich sind oder in welcher Beziehung sie zueinander stehen. Sie geben immer einen boolean-Wert (true oder false) zurück.
 * Gleich: == (z.B. 5 == 5 ist true)
 * Ungleich: != (z.B. 2 != 3 ist true)
 * Größer als: > (z.B. 3 > 2 ist true)
 * Kleiner als: < (z.B. 2 < 3 ist true)
 * Größer oder gleich: >= (z.B. 5 >= 5 ist true)
 * Kleiner oder gleich: <= (z.B. 2 <= 3 ist true)
Logische Operatoren
Diese Operatoren kombinieren boolean-Werte.
 * UND (AND): && Gibt nur dann true zurück, wenn beide Seiten true sind.
   * Beispiel: (istAnfaenger && meinAlter < 18)
     * Wenn istAnfaenger true ist und meinAlter 27 ist, dann ist meinAlter < 18 false. Das Gesamtergebnis ist false.
 * ODER (OR): || Gibt true zurück, wenn mindestens eine Seite true ist.
   * Beispiel: (istAnfaenger || meinAlter < 18)
     * Wenn istAnfaenger true ist und meinAlter 27 ist, dann ist meinAlter < 18 false. Da istAnfaenger true ist, ist das Gesamtergebnis true.
 * NICHT (NOT): ! Kehrt den Wert um.
   * Beispiel: !istAnfaenger
     * Wenn istAnfaenger true ist, dann ist !istAnfaenger false.
Kontrollfluss
Kontrollfluss sagt dem Computer, wie er Sachen erledigen soll.
If-Anweisung
Die if-Anweisung führt Code nur aus, wenn eine Bedingung true ist.
if (meinAlter >= 18) {
  print("Du bist volljährig");
}

If-Else-Anweisung
Die if-else-Anweisung deckt alle anderen Fälle ab, wenn die if-Bedingung false ist.
if (meinAlter >= 18) {
  print("Du bist volljährig");
} else {
  print("Du bist nicht volljährig");
}

Else-If-Anweisung
Mit else if kannst du weitere Bedingungen prüfen.
if (meinAlter < 13) {
  print("Du darfst nur Filme mit G-Freigabe gucken.");
} else if (meinAlter < 18) {
  print("Du kannst dir Filme mit G- und PG-13-Freigabe anschauen.");
} else {
  print("Du darfst dir G-, PG- und R-Filme anschauen.");
}

Switch-Anweisung
Eine switch-Anweisung ist oft übersichtlicher als viele verschachtelte if-else if-Anweisungen, wenn du einen einzelnen Wert mit mehreren möglichen Fällen vergleichen möchtest.
String note = "B";

switch (note) {
  case "A":
    print("Ausgezeichnet");
    break;
  case "B":
    print("Gut");
    break;
  case "C":
    print("Befriedigend");
    break;
  default:
    print("Ungültige Note");
}

Schleifen (Loops)
Schleifen werden verwendet, um einen Codeblock wiederholt auszuführen.
For-Schleife
Eine for-Schleife wird verwendet, wenn du weißt, wie oft du schleifen möchtest. Sie hat eine Initialisierung, eine Bedingung und eine Iteration.
for (int i = 0; i <= 5; i++) {
  print(i); // Gibt 0, 1, 2, 3, 4, 5 aus
}

 * break: Beendet die Schleife sofort.
   for (int i = 0; i <= 8; i++) {
  if (i == 6) {
    break; // Die Schleife stoppt, wenn i 6 ist.
  }
  print(i); // Gibt 0, 1, 2, 3, 4, 5 aus
}

 * continue: Überspringt die aktuelle Iteration und fährt mit der nächsten fort.
   for (int i = 0; i <= 8; i++) {
  if (i == 6) {
    continue; // Überspringt die Ausgabe von 6
  }
  print(i); // Gibt 0, 1, 2, 3, 4, 5, 7, 8 aus
}

While-Schleife
Eine while-Schleife wird verwendet, wenn du nicht genau weißt, wie oft du schleifen musst. Sie wiederholt sich, solange eine Bedingung true ist.
int zaehler = 5;
while (zaehler > 0) {
  print(zaehler); // Gibt 5, 4, 3, 2, 1 aus
  zaehler--;
}

Funktionen (Methods)
Funktionen organisieren Codeblöcke, um sie später leicht wiederverwenden zu können.
Void-Funktion (gibt nichts zurück)
Eine void-Funktion führt einfach Code aus und gibt keinen Wert zurück.
void grussNachricht() {
  print("Hallo Mitch");
}

// Aufruf:
// grussNachricht();

Funktionen mit Parametern
Funktionen können Parameter akzeptieren, um flexibler zu sein.
void grussPerson(String name, int alter) {
  print("Hallo $name, du bist $alter Jahre alt.");
}

// Aufruf:
// grussPerson("Steve", 27);

Funktionen mit Rückgabetyp
Eine Funktion kann einen Wert eines bestimmten Typs zurückgeben.
int addiere(int a, int b) {
  int summe = a + b;
  return summe;
}

// Aufruf und Speicherung des Ergebnisses:
// int meineSumme = addiere(3, 5);
// print(meineSumme); // Gibt 8 aus

Datenstrukturen
Datenstrukturen speichern Variablen auf organisierte Weise.
Liste (List)
Eine Liste ist eine geordnete Sammlung von Elementen. Sie kann Duplikate enthalten.
List<int> zahlen = [1, 2, 3];
List<String> namen = ["Mitch", "Sharon", "Vince"];

// Zugriff über den Index (beginnt bei 0):
// print(zahlen[0]); // Gibt 1 aus
// print(namen[1]); // Gibt Sharon aus

// Iteration mit einer For-Schleife:
// for (int i = 0; i < namen.length; i++) {
//   print(namen[i]);
// }

Set
Ein Set ist eine ungeordnete Sammlung von einzigartigen Elementen (keine Duplikate).
Set<String> einzigartigeNamen = {"Mitch", "Sharon", "Mitch"};
// print(einzigartigeNamen); // Gibt {Mitch, Sharon} aus (Reihenfolge kann variieren)

Map
Eine Map speichert Schlüssel-Wert-Paare.
Map<String, dynamic> benutzer = {
  "name": "Mitch Coco",
  "alter": 27,
  "groesse": 180
};

// Zugriff über den Schlüssel:
// print(benutzer["name"]); // Gibt Mitch Coco aus
// print(benutzer["alter"]); // Gibt 27 aus

Widgets in Flutter
Alles in Flutter ist ein Widget.
Scaffold
Das Scaffold ist ein grundlegendes Layout-Widget, das eine App-Struktur wie eine AppBar, einen Body, einen FloatingActionButton usw. bereitstellt.
Scaffold(
  backgroundColor: Colors.blue[200], // Hintergrundfarbe
  appBar: AppBar(
    title: Text("Meine App"),
    elevation: 0, // Kein Schatten unter der AppBar
  ),
  body: Center(
    child: Text("Hallo Welt"),
  ),
  // debugShowCheckedModeBanner: false, // Debug-Banner ausblenden
);

Container
Ein Container ist ein sehr flexibles Widget, das zum Layout, zur Positionierung und zum Styling verwendet wird.
Container(
  height: 300,
  width: 300,
  color: Colors.green, // Farbe direkt im Container
  padding: EdgeInsets.all(25), // Innenabstand
  decoration: BoxDecoration( // Für komplexere Dekorationen
    color: Colors.green, // Farbe muss hierher verschoben werden
    borderRadius: BorderRadius.circular(20), // Abgerundete Ecken
  ),
  child: Text("Mitch Coco"),
);

Center
Das Center-Widget zentriert sein Kind-Widget.
Center(
  child: Container(...), // Der Container wird zentriert
);

Text
Das Text-Widget zeigt Text an und kann gestylt werden.
Text(
  "Mitch Coco",
  style: TextStyle(
    color: Colors.white,
    fontSize: 28,
    fontWeight: FontWeight.bold,
  ),
);

Icon
Das Icon-Widget zeigt Icons an, die in Flutter standardmäßig verfügbar sind.
Icon(
  Icons.favorite, // Ein Herz-Icon
  color: Colors.red,
  size: 50,
);

AppBar
Die AppBar ist die obere Leiste einer App.
AppBar(
  title: Text("Meine App"),
  backgroundColor: Colors.yellow,
  elevation: 0,
  leading: Icon(Icons.menu), // Icon links
  actions: [
    IconButton(
      icon: Icon(Icons.settings), // Icon rechts
      onPressed: () {},
    ),
  ],
);

Column und Row
 * Column: Ordnet Widgets vertikal an.
 * Row: Ordnet Widgets horizontal an.
Beide haben mainAxisAlignment (Ausrichtung entlang der Hauptachse) und crossAxisAlignment (Ausrichtung entlang der Querachse).
Column(
  mainAxisAlignment: MainAxisAlignment.center, // Vertikal zentrieren
  crossAxisAlignment: CrossAxisAlignment.start, // Horizontal links ausrichten
  children: [
    Container(height: 200, width: 200, color: Colors.deepPurple),
    Container(height: 150, width: 150, color: Colors.deepPurpleAccent),
  ],
);

Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Gleichmäßiger Abstand
  children: [
    Container(height: 100, width: 100, color: Colors.red),
    Container(height: 100, width: 100, color: Colors.green),
  ],
);

Expanded
Das Expanded-Widget füllt den restlichen verfügbaren Platz in einer Column oder Row aus. Es ist sehr nützlich für responsive Layouts.
Column(
  children: [
    Expanded(
      flex: 2, // Nimmt doppelt so viel Platz ein wie andere mit flex: 1
      child: Container(color: Colors.red),
    ),
    Expanded(
      flex: 1,
      child: Container(color: Colors.green),
    ),
  ],
);

ListView
Ein ListView ist im Grunde eine scrollbare Column. Es ist ideal, wenn deine Inhalte den Bildschirm übersteigen könnten.
ListView(
  scrollDirection: Axis.vertical, // Standardmäßig vertikal
  children: [
    Container(height: 350, color: Colors.red),
    Container(height: 350, color: Colors.green),
    Container(height: 350, color: Colors.blue),
  ],
);

ListView.builder
Der ListView.builder ist effizienter für große Listen, da er nur die Widgets erstellt, die gerade sichtbar sind.
List<String> meineNamen = ["Alice", "Bob", "Charlie", "David"];

ListView.builder(
  itemCount: meineNamen.length,
  itemBuilder: (context, index) {
    return ListTile(
      title: Text(meineNamen[index]),
    );
  },
);

GridView
Ein GridView ordnet Widgets in einem Raster an.
GridView.builder(
  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
    crossAxisCount: 4, // 4 Elemente pro Reihe
  ),
  itemCount: 64, // Z.B. für ein Schachbrett
  itemBuilder: (context, index) {
    return Container(
      color: Colors.grey,
      margin: EdgeInsets.all(4),
    );
  },
);

Stack
Ein Stack stapelt Widgets übereinander.
Stack(
  alignment: Alignment.center, // Alle Kinder zentrieren
  children: [
    Container(height: 300, width: 300, color: Colors.red),
    Container(height: 200, width: 200, color: Colors.blue),
    Container(height: 100, width: 100, color: Colors.green),
  ],
);

GestureDetector
Ein GestureDetector erkennt Gesten wie Tippen, langes Drücken oder Doppeltippen auf einem Widget.
GestureDetector(
  onTap: () {
    print("Benutzer hat getippt!");
  },
  child: Container(
    padding: EdgeInsets.all(20),
    color: Colors.blue,
    child: Text("Tippe mich"),
  ),
);

Navigation in Flutter
Seiten erstellen
Erstelle separate Dateien (z.B. first_page.dart, second_page.dart) für jede Seite deiner App.
// first_page.dart
class FirstPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Erste Seite")),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Navigation zur zweiten Seite
          },
          child: Text("Gehe zur zweiten Seite"),
        ),
      ),
    );
  }
}

Navigator.push
Navigator.push fügt eine neue Route zum Stack hinzu.
// Im onPressed-Callback:
Navigator.push(
  context,
  MaterialPageRoute(builder: (context) => SecondPage()),
);

Benannte Routen (Named Routes)
Für komplexere Navigationen kannst du benannte Routen in deiner MaterialApp definieren.
MaterialApp(
  home: FirstPage(),
  routes: {
    '/secondPage': (context) => SecondPage(),
    '/settingsPage': (context) => SettingsPage(),
  },
);

// Navigation mit benannten Routen:
// Im onPressed-Callback:
Navigator.pushNamed(context, '/secondPage');

Drawer (Seitenleiste)
Ein Drawer ist eine Seitenleiste, die von der Seite des Bildschirms ausfährt.
Scaffold(
  appBar: AppBar(title: Text("Home")),
  drawer: Drawer(
    child: Column(
      children: [
        DrawerHeader(
          child: Icon(Icons.flutter_dash, size: 48),
        ),
        ListTile(
          leading: Icon(Icons.home),
          title: Text("Home"),
          onTap: () {
            Navigator.pop(context); // Drawer schließen
            Navigator.pushNamed(context, '/homePage');
          },
        ),
        ListTile(
          leading: Icon(Icons.settings),
          title: Text("Einstellungen"),
          onTap: () {
            Navigator.pop(context); // Drawer schließen
            Navigator.pushNamed(context, '/settingsPage');
          },
        ),
      ],
    ),
  ),
);

BottomNavigationBar (Untere Navigationsleiste)
Eine BottomNavigationBar ist eine Leiste am unteren Bildschirmrand mit mehreren Tabs.
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Aktueller Index des ausgewählten Tabs

  List<Widget> _pages = [
    ShopPage(),
    CartPage(),
    SettingsPage(),
  ];

  void _navigateBottomBar(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex], // Zeigt die ausgewählte Seite an
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _navigateBottomBar,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: "Warenkorb"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "Einstellungen"),
        ],
      ),
    );
  }
}

Stateful vs. Stateless Widgets (Zähler-App)
 * StatelessWidget: Widgets, deren Zustand sich nie ändert, nachdem sie erstellt wurden. Sie sind statisch.
 * StatefulWidget: Widgets, deren Zustand sich während der Lebensdauer der App ändern kann. Sie können neu aufgebaut werden, um Änderungen widerzuspiegeln.
Die Zähler-App
Eine einfache Zähler-App demonstriert den Unterschied:
 * Variable: int _counter = 0; (Speichert den Zählerstand)
 * Methode: void _incrementCounter() { setState(() { _counter++; }); } (Erhöht den Zähler und aktualisiert die UI)
 * UI: Text("$_counter"), ElevatedButton (Zeigt den Zähler an und hat einen Button zum Inkrementieren)
Wichtig: setState(() { ... }); ist entscheidend für StatefulWidgets. Es teilt Flutter mit, dass sich der Zustand geändert hat und das Widget neu aufgebaut werden muss, um die Änderung auf dem Bildschirm anzuzeigen. Ohne setState würde sich der Wert der Variable zwar ändern, aber die Benutzeroberfläche würde nicht aktualisiert.
Benutzereingabe (To-Do-App)
TextField
Das TextField-Widget ermöglicht es dem Benutzer, Text einzugeben.
TextField(
  decoration: InputDecoration(
    border: OutlineInputBorder(), // Rahmen um das Textfeld
    hintText: "Gib deinen Namen ein", // Platzhaltertext
  ),
);

TextEditingController
Um auf den vom Benutzer eingegebenen Text zuzugreifen, verwendest du einen TextEditingController.
TextEditingController _myController = TextEditingController();

TextField(
  controller: _myController, // Controller mit dem Textfeld verbinden
);

// Zugriff auf den Text:
// String eingegebenerText = _myController.text;

To-Do-App: Funktionalität und Datenpersistenz
To-Do-App-Funktionen
 * Aufgaben abhaken: Mit Checkbox und setState den Status einer Aufgabe ändern.
 * Neue Aufgaben erstellen: Über ein Dialogfeld (showDialog) mit einem TextField neue Aufgaben eingeben.
 * Aufgaben löschen: Mit dem flutter_slidable-Paket (muss in pubspec.yaml hinzugefügt werden) Aufgaben durch Wischen löschen.
Lokale Datenspeicherung mit Hive
Um Daten lokal auf dem Gerät zu speichern (damit sie nach dem Schließen der App nicht verloren gehen), wird Hive verwendet.
 * Abhängigkeiten hinzufügen: Füge hive und hive_flutter zu deiner pubspec.yaml hinzu.
 * Hive initialisieren: In der main-Funktion deiner App:
   import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
  var box = await Hive.openBox('myBox'); // Eine Box öffnen
  runApp(MyApp());
}

 * Datenbank-Klasse erstellen: Trenne die Datenbanklogik von der UI.
   // data/database.dart
import 'package:hive_flutter/hive_flutter.dart';

class ToDoDatabase {
  List toDoList = [];
  final _myBox = Hive.box('myBox');

  // Methode, die beim ersten Öffnen der App ausgeführt wird
  void createInitialData() {
    toDoList = [
      ["Tutorial machen", false],
      ["Sport machen", false],
    ];
  }

  // Daten aus der Datenbank laden
  void loadData() {
    toDoList = _myBox.get("TODOLIST"); // "TODOLIST" ist der Schlüssel
  }

  // Datenbank aktualisieren
  void updateDatabase() {
    _myBox.put("TODOLIST", toDoList);
  }
}

 * Datenbank in der Home-Seite verwenden:
   * Erstelle eine Instanz der Datenbankklasse.
   * Im initState der StatefulWidget-Seite prüfen, ob es das erste Mal ist, dass die App geöffnet wird, und entsprechend createInitialData() oder loadData() aufrufen.
   * Rufe updateDatabase() auf, wann immer sich die toDoList ändert (z.B. beim Hinzufügen, Löschen oder Abhaken einer Aufgabe).
E-Commerce-App: Zustand und Provider
Eine E-Commerce-App benötigt ein komplexeres Zustandsmanagement, da Daten (verfügbare Produkte, Warenkorb) über mehrere Seiten hinweg geteilt und aktualisiert werden müssen.
Modelle erstellen
Definiere Datenmodelle (z.B. Shoe-Klasse) für deine Produkte.
// models/shoe.dart
class Shoe {
  final String name;
  final String price;
  final String imagePath;
  final String description;

  Shoe({
    required this.name,
    required this.price,
    required this.imagePath,
    required this.description,
  });
}

Warenkorb-Modell und Provider
Verwende das provider-Paket für das Zustandsmanagement.
 * Abhängigkeit hinzufügen: Füge provider zu deiner pubspec.yaml hinzu.
 * Cart Modell erstellen:
   // models/cart.dart
import 'package:flutter/material.dart';
import 'shoe.dart'; // Dein Schuh-Modell

class Cart extends ChangeNotifier {
  // Liste der zum Verkauf stehenden Schuhe
  List<Shoe> _shoeShop = [
    Shoe(name: "Zoom Freak", price: "236", imagePath: "lib/images/shoe1.png", description: "Beschreibung 1"),
    // ... weitere Schuhe
  ];

  // Liste der Artikel im Warenkorb des Benutzers
  List<Shoe> _userCart = [];

  List<Shoe> getShoeList() {
    return _shoeShop;
  }

  List<Shoe> getUserCart() {
    return _userCart;
  }

  // Artikel zum Warenkorb hinzufügen
  void addItemToCart(Shoe shoe) {
    _userCart.add(shoe);
    notifyListeners(); // Informiert alle Listener über die Änderung
  }

  // Artikel aus dem Warenkorb entfernen
  void removeItemFromCart(Shoe shoe) {
    _userCart.remove(shoe);
    notifyListeners();
  }
}

 * ChangeNotifierProvider in main.dart: Wickle deine App in einen ChangeNotifierProvider, um das Cart-Modell in der gesamten App verfügbar zu machen.
   // main.dart
import 'package:provider/provider.dart';
import 'models/cart.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Cart(),
      child: MyApp(),
    ),
  );
}

 * Consumer Widgets verwenden: Auf den Seiten, die auf die Daten zugreifen oder sie ändern müssen (z.B. ShopPage, CartPage), verwende Consumer Widgets.
   // shop_page.dart (Beispiel für den Zugriff auf die Schuhliste und das Hinzufügen zum Warenkorb)
class ShopPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, value, child) => Column(
        children: [
          // ... Suchleiste, Nachrichten
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: value.getShoeList().length,
              itemBuilder: (context, index) {
                Shoe shoe = value.getShoeList()[index];
                return ShoeTile(
                  shoe: shoe,
                  onTap: () {
                    value.addItemToCart(shoe);
                    // Optional: Snackbar oder Dialog anzeigen
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text("Erfolgreich hinzugefügt!"),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
```dart
// cart_page.dart (Beispiel für die Anzeige des Warenkorbs und das Entfernen von Artikeln)
class CartPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<Cart>(
      builder: (context, value, child) => Column(
        children: [
          Text("Mein Warenkorb", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          Expanded(
            child: ListView.builder(
              itemCount: value.getUserCart().length,
              itemBuilder: (context, index) {
                Shoe individualShoe = value.getUserCart()[index];
                return ListTile(
                  leading: Image.asset(individualShoe.imagePath),
                  title: Text(individualShoe.name),
                  subtitle: Text(individualShoe.price),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () => value.removeItemFromCart(individualShoe),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

Letzte Gedanken
 * Konstantes Codieren: Übe täglich, um Expertise zu erlangen.
 * Klein anfangen und aufbauen: Setze dir erreichbare Ziele, um motiviert zu bleiben.
 * Internet und KI nutzen: Die Fähigkeit, Dinge selbst herauszufinden, ist die wichtigste Programmierfähigkeit.
 * Weitere Ressourcen: Schau dir Mitch Cocos YouTube-Kanal für mehr Flutter-Inhalte an.
Viel Glück auf deiner Coding-Reise!
