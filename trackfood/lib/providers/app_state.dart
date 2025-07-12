import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppState extends ChangeNotifier {
  // Beispiel: User-Session, Dashboard-Daten, etc.
  String? userId;
  // ...weitere State-Variablen

  void setUserId(String id) {
    userId = id;
    notifyListeners();
  }
}
