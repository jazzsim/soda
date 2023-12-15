import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static late SharedPreferences _prefs;

  static Future<void> initialize() async => _prefs = await SharedPreferences.getInstance();
  static SharedPreferences get prefs => _prefs;
}
