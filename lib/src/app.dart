import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:lessonlab/src/global_components/route_animation.dart';
import 'package:lessonlab/src/settings/settings_view_model.dart';

import 'lessonlab_modules/entry/menu/menu_view.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/lesson_specifications_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_view.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_result/quiz_result_view.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_specifications/quiz_specifications_view.dart';
import 'settings/settings_view.dart';

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsViewModel,
  });

  final SettingsViewModel settingsViewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: settingsViewModel,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          scaffoldMessengerKey: rootScaffoldMessengerKey,
          restorationScopeId: 'app',
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(
            useMaterial3: false,
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber),
            scaffoldBackgroundColor: Colors.white,
          ),
          darkTheme: ThemeData.dark(),
          themeMode: settingsViewModel.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return FadePageRoute(
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case '/settings':
                    return SettingsView(settingsViewModel: settingsViewModel);
                  case '/menu':
                    return MenuView();
                  case '/upload':
                    return const UploadSourcesView();
                  case '/lesson_open':
                    return const LessonOpenView();
                  case '/lesson_result':
                    return const LessonResultView();
                  case '/specifications':
                    return const LessonSpecificationsView();
                  case '/quiz_specifications':
                    return const QuizSpecificationsView();
                  case '/quiz_page':
                    return const QuizPageView();
                  case '/quiz_result':
                    return const QuizResultView();
                  default:
                    return MenuView();
                }
              },
              settings: routeSettings,
            );
          },
        );
      },
    );
  }
}
