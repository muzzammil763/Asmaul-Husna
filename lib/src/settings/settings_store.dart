import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// App preferences and favourites, kept on the device.
class SettingsStore extends ChangeNotifier {
  SettingsStore._();
  static final instance = SettingsStore._();

  late SharedPreferences _prefs;

  ThemeMode themeMode = ThemeMode.system;
  bool showTransliteration = true;
  bool showEnglish = true;
  bool showUrdu = true;
  bool gridLayout = true;
  double arabicScale = 1;
  Set<int> favourites = {};

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    themeMode = ThemeMode.values[_prefs.getInt('themeMode') ?? 0];
    showTransliteration = _prefs.getBool('showTransliteration') ?? true;
    showEnglish = _prefs.getBool('showEnglish') ?? true;
    showUrdu = _prefs.getBool('showUrdu') ?? true;
    gridLayout = _prefs.getBool('gridLayout') ?? true;
    arabicScale = _prefs.getDouble('arabicScale') ?? 1;
    favourites = {
      for (final s in _prefs.getStringList('favourites') ?? const <String>[])
        ?int.tryParse(s),
    };
  }

  void setThemeMode(ThemeMode mode) {
    themeMode = mode;
    _prefs.setInt('themeMode', mode.index);
    notifyListeners();
  }

  void setShowTransliteration(bool v) {
    showTransliteration = v;
    _prefs.setBool('showTransliteration', v);
    notifyListeners();
  }

  void setShowEnglish(bool v) {
    showEnglish = v;
    _prefs.setBool('showEnglish', v);
    notifyListeners();
  }

  void setShowUrdu(bool v) {
    showUrdu = v;
    _prefs.setBool('showUrdu', v);
    notifyListeners();
  }

  void setGridLayout(bool v) {
    gridLayout = v;
    _prefs.setBool('gridLayout', v);
    notifyListeners();
  }

  void setArabicScale(double v) {
    arabicScale = v;
    _prefs.setDouble('arabicScale', v);
    notifyListeners();
  }

  bool isFavourite(int number) => favourites.contains(number);

  void toggleFavourite(int number) {
    favourites = {...favourites}..toggle(number);
    _prefs.setStringList('favourites', [for (final n in favourites) '$n']);
    notifyListeners();
  }
}

extension on Set<int> {
  void toggle(int n) => contains(n) ? remove(n) : add(n);
}
