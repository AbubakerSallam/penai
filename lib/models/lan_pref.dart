import 'package:shared_preferences/shared_preferences.dart';

class LanguagePreferences {
  static const String _keyLanguageCode = 'languageCode';

  static Future<void> saveLanguageCode(String languageCode) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLanguageCode, languageCode);
  }

  static Future<String> getLanguageCode() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLanguageCode) ?? 'ar'; // Default to English if not set
  }
}
