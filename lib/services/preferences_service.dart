import 'package:shared_preferences/shared_preferences.dart';

enum SPKeys {
 servers,
 gridFolder, 
}

class PreferencesService {
  static late SharedPreferences _prefs;

  static Future<void> initialize() async => _prefs = await SharedPreferences.getInstance();
  void clear() => _prefs.clear();

  List<String> getServerList() {
    return _prefs.getStringList(SPKeys.servers.name) ?? [];
  }

  Future<void> setServerList(List<String> value) async {
    await _prefs.setStringList(SPKeys.servers.name, value);
  }

  bool getGridFolder() {
    return _prefs.getBool(SPKeys.gridFolder.name) ?? true;
  }

  Future<void> setGridFolder(bool value) async {
    await _prefs.setBool(SPKeys.gridFolder.name, value);
  }
}
