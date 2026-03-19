import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const String _keyDarkMode = 'darkMode';
  static const String _keySaveLoginInfo = 'saveLoginInfo';
  static const String _keySavedEmail = 'savedEmail';
  static const String _keySavedPassword = 'savedPassword';

  Future<SharedPreferences> _getPrefs() async {
    return await SharedPreferences.getInstance();
  }

  Future<bool> getDarkMode() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keyDarkMode) ?? false;
  }

  Future<void> setDarkMode(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keyDarkMode, value);
  }

  Future<bool> getSaveLoginInfo() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_keySaveLoginInfo) ?? false;
  }

  Future<void> setSaveLoginInfo(bool value) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_keySaveLoginInfo, value);
  }

  Future<Map<String, String>> getSavedCredentials() async {
    final prefs = await _getPrefs();
    return {
      'email': prefs.getString(_keySavedEmail) ?? '',
      'password': prefs.getString(_keySavedPassword) ?? '',
    };
  }

  Future<void> saveCredentials(String email, String password) async {
    final prefs = await _getPrefs();
    await prefs.setString(_keySavedEmail, email);
    await prefs.setString(_keySavedPassword, password);
  }

  Future<void> clearCredentials() async {
    final prefs = await _getPrefs();
    await prefs.remove(_keySavedEmail);
    await prefs.remove(_keySavedPassword);
  }

  Future<void> clearAll() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}

final PreferencesService preferencesService = PreferencesService();
