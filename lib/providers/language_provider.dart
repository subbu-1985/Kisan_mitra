import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  bool _isTelugu = false;

  bool get isTelugu => _isTelugu;

  LanguageProvider() {
    _loadLanguage();
  }

  void _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    _isTelugu = prefs.getBool('isTelugu') ?? false;
    notifyListeners();
  }

  void toggleLanguage() async {
    _isTelugu = !_isTelugu;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isTelugu', _isTelugu);
    notifyListeners();
  }

  String translate(Map<String, String> localizedString) {
    return _isTelugu ? (localizedString['te'] ?? localizedString['en']!) : localizedString['en']!;
  }
}
