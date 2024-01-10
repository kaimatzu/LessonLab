import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_controller.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/lesson_specifications_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_view.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_result/quiz_result_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_specifications/quiz_specifications_view_model.dart';
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

  await SettingsPreferences.init();
  await settingsViewModel.loadSettings();
  await settingsViewModel.sendData();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => OverlayController()),
        ChangeNotifierProvider(create: (context) => UploadSourcesViewModel()),
        ChangeNotifierProvider(
            create: (context) => LessonSpecificationsViewModel()),
        ChangeNotifierProvider(create: (context) => LessonResultViewModel()),
        ChangeNotifierProvider(create: (context) => LessonOpenViewModel()),
        ChangeNotifierProvider(create: (context) => MenuViewModel()),
        ChangeNotifierProvider(
            create: (context) => QuizSpecificationsViewModel()),
        ChangeNotifierProvider(create: (context) => QuizPageViewModel()),
        ChangeNotifierProvider(create: (context) => QuizResultViewModel()),
      ],
      child: MyApp(settingsViewModel: settingsViewModel),
    ),
  );
}
