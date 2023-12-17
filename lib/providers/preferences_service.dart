import 'package:shared_preferences/shared_preferences.dart';

enum SPKeys {
 servers,
 gridFolder, 
}

class PreferencesService {
  static late SharedPreferences _prefs;

  static Future<void> initialize() async => _prefs = await SharedPreferences.getInstance();
  static SharedPreferences get prefs => _prefs;

  List<String> getServerList() {
    return prefs.getStringList(SPKeys.servers.name) ?? [];
  }

  Future<void> setServerList(List<String> value) async {
    await prefs.setStringList(SPKeys.servers.name, value);
  }

  bool getGridFolder() {
    return prefs.getBool(SPKeys.gridFolder.name) ?? true;
  }

  Future<void> setGridFolder(bool value) async {
    await prefs.setBool(SPKeys.gridFolder.name, value);
  }
}
