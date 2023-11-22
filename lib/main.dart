import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/results/lesson_result/lesson_result_view_model.dart';
import 'package:lessonlab/src/settings/settings_view_model.dart';
import 'package:lessonlab/src/settings/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/settings/settings_service.dart';
import 'package:rinf/rinf.dart';

void main() async {
  await Rinf.ensureInitialized();
  WidgetsFlutterBinding.ensureInitialized();

  final settingsViewModel = SettingsViewModel(SettingsService());

  await settingsViewModel.loadSettings();

  await SettingsPreferences.init();

  await settingsViewModel.sendData();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OverlayViewModel()),
        ChangeNotifierProvider(create: (context) => UploadViewModel()),
        ChangeNotifierProvider(create: (context) => LessonSpecificationsViewModel()),
        ChangeNotifierProvider(create: (context) => LessonResultViewModel()),
        ChangeNotifierProvider(create: (context) => MenuViewModel()),
      ],
      child: MyApp(settingsViewModel: settingsViewModel),
    ),
  );
}
