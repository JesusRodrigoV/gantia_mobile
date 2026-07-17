import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeService extends ChangeNotifier {
  static const _key = 'theme';

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  static Future<ThemeService> init() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    final service = ThemeService();
    if (stored != null) {
      service._isDarkMode = stored == 'dark';
    }
    return service;
  }

  Future<void> toggleTheme() async {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _isDarkMode ? 'dark' : 'light');
  }
}
