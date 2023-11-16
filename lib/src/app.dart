// import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/material_selection/material_selection_view.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_type/quiz_type_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/specifications_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/specifications_view.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:lessonlab/src/global_components/route_animation.dart';
// import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay_provider.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_view.dart';
import 'package:lessonlab/src/lessonlab_modules/results/lesson_result/lesson_result_view.dart';

import 'lessonlab_modules/entry/menu/menu_view.dart';
import 'settings/settings_controller.dart';
import 'settings/settings_view.dart';

/// The Widget that configures your application.
class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.settingsController,
  });

  final SettingsController settingsController;

  @override
  Widget build(BuildContext context) {
    // Glue the SettingsController to the MaterialApp.
    //
    // The ListenableBuilder Widget listens to the SettingsController for changes.
    // Whenever the user updates their settings, the MaterialApp is rebuilt.
    return ListenableBuilder(
      listenable: settingsController,
      builder: (BuildContext context, Widget? child) {
        return MaterialApp(
          // Providing a restorationScopeId allows the Navigator built by the
          // MaterialApp to restore the navigation stack when a user leaves and
          // returns to the app after it has been killed while running in the
          // background.
          restorationScopeId: 'app',

          // Provide the generated AppLocalizations to the MaterialApp. This
          // allows descendant Widgets to display the correct translations
          // depending on the user's locale.
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('en', ''), // English, no country code
          ],

          // Use AppLocalizations to configure the correct application title
          // depending on the user's locale.
          //
          // The appTitle is defined in .arb files found in the localization
          // directory.
          onGenerateTitle: (BuildContext context) =>
              AppLocalizations.of(context)!.appTitle,

          // Define a light and dark color theme. Then, read the user's
          // preferred ThemeMode (light, dark, or system default) from the
          // SettingsController to display the correct theme.
          theme: ThemeData(
            // useMaterial3: true,
            colorScheme: ColorScheme.fromSwatch(primarySwatch: Colors.amber),
            // * colors from figma
            // primary color: (241, 196, 149)
            // secondary color: (255, 242, 148)
          ),
          darkTheme: ThemeData.dark(),
          themeMode: settingsController.themeMode,

          // Define a function to handle named routes in order to support
          // Flutter web url navigation and deep linking.
          onGenerateRoute: (RouteSettings routeSettings) {
            return FadePageRoute(
              builder: (BuildContext context) {
                switch (routeSettings.name) {
                  case '/settings':
                    return SettingsView(controller: settingsController);
                  case '/menu':
                    return const MenuView();
                  case '/upload':
                    return const UploadView();
                  case '/materialselection':
                    return const MaterialSelectionView();
                  case '/lesson_result':
                  return const LessonResultView();  
                  case '/quiztype':
                    return const QuizTypeView();
                  case '/specifications':
                    return const SpecificationsView();
                default:
                    return const MenuView();
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
