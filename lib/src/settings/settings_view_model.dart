import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:lessonlab/messages/entry/upload/uploaded_content.pb.dart'
//     // ignore: library_prefixes
//     as RinfInterface;
import 'package:lessonlab/messages/settings/save_directory.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'settings_service.dart';
import 'package:file_selector/file_selector.dart';
import 'package:lessonlab/src/settings/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';
import 'package:rinf/rinf.dart';
import 'dart:developer' as developer;

class SettingsViewModel with ChangeNotifier{
  SettingsViewModel(this._settingsService);

  final SettingsService _settingsService;

  late ThemeMode _themeMode;

  ThemeMode get themeMode => _themeMode;

  Future<void> loadSettings() async {
    _themeMode = await _settingsService.themeMode();
    loadPreferences(null);
    notifyListeners();
  }

  Future<void> updateThemeMode(ThemeMode? newThemeMode) async {
    if (newThemeMode == null) return;

    if (newThemeMode == _themeMode) return;

    _themeMode = newThemeMode;

    notifyListeners();

    await _settingsService.updateThemeMode(newThemeMode);
  }

  final String _saveFilePath = '';
  String get saveFilePath => _saveFilePath;

  String _configPath = '';
  // ignore: unnecessary_getters_setters
  String get configPath => _configPath;
  set configPath (String value){
    _configPath = value;
  }

  var statusCode = 0;

  void loadPreferences(TextEditingController? directoryController) async{
    _configPath = SettingsPreferences.getDirectory() ?? await getDefaultConfigPath();
    if(directoryController != null) {
      directoryController.text = _configPath;
    }
  }

  void selectDirectory(BuildContext context, TextEditingController directoryController) async{
    final String? directoryPath = await getDirectoryPath();

    if (directoryPath == null) {
      // Operation was canceled by the user.
      return;
    }
    else
    {
      directoryController.text = directoryPath;
      await SettingsPreferences.setDirectory(directoryPath);
      await sendData();
    }
  }

  Future<String> getDefaultConfigPath() async {
    String username = Platform.environment['USERNAME'] ?? 'default';
    Directory appDataDir = await getApplicationSupportDirectory();
    return "${appDataDir.path}\\LessonLab\\$username";
  }

  void resetConfigPath(TextEditingController directoryController) async {
    _configPath = await getDefaultConfigPath();
    directoryController.text = _configPath;
    SettingsPreferences.setDirectory(_configPath);
  }

  Future<void> sendData() async{
    final requestMessage =
        RinfInterface.CreateRequest(saveDirectory: _configPath);
    final rustRequest = RustRequest(
      resource: RinfInterface.ID,
      operation: RustOperation.Create,
      message: requestMessage.writeToBuffer(),
      // blob: NO BLOB
    );
    final rustResponse = await requestToRust(rustRequest);
    final responseMessage = RinfInterface.CreateResponse.fromBuffer(
      rustResponse.message!,
    );
    statusCode = responseMessage.statusCode;
    developer.log(statusCode.toString(), name: 'response-code');
  }
}