import 'package:shared_preferences/shared_preferences.dart';

enum SPKeys {
 version,
 servers,
 gridFolder, 
 videoThumbnail
}

class PreferencesService {
  static late SharedPreferences _prefs;

  static Future<void> initialize() async => _prefs = await SharedPreferences.getInstance();
  void clear() => _prefs.clear();

  String getVersion() {
    return _prefs.getString(SPKeys.version.name) ?? '';
  }

  Future<void> setVersion(String value) async {
    await _prefs.setString(SPKeys.version.name, value);
  }

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

  bool getVideoThumbnail() {
    return _prefs.getBool(SPKeys.videoThumbnail.name) ?? false;
  }

  Future<void> setVideoThumbnail(bool value) async {
    await _prefs.setBool(SPKeys.videoThumbnail.name, value);
  }
}
