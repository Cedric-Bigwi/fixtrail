import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Remembers the light/dark choice with SharedPreferences. Default: light.
class ThemeProvider extends ChangeNotifier {
  ThemeProvider._(this._prefs, this._dark);

  static const _key = 'is_dark_theme_v2'; // v2: everyone starts in light mode
  final SharedPreferences _prefs;
  bool _dark;

  bool get isDark => _dark;

  static Future<ThemeProvider> load() async {
    final prefs = await SharedPreferences.getInstance();
    return ThemeProvider._(prefs, prefs.getBool(_key) ?? false);
  }

  Future<void> setDark(bool value) async {
    if (value == _dark) return;
    _dark = value;
    notifyListeners();
    await _prefs.setBool(_key, value);
  }
}
