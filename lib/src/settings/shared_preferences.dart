import 'package:shared_preferences/shared_preferences.dart';

class SettingsPreferences{
  static SharedPreferences? _preferences;

  static const _keyDirectory = 'directory';

  static Future init()async => 
    _preferences = await SharedPreferences.getInstance();

  static Future setDirectory(String directory) async =>
    await _preferences?.setString(_keyDirectory, directory);

  static String? getDirectory() => _preferences?.getString(_keyDirectory);
}