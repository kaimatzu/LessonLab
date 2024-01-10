import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_connection_orchestrator.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_model.dart';

class LessonOpenViewModel with ChangeNotifier {
  late final LessonOpenModel _lessonOpenModel;
  late final LessonOpenConnectionOrchestrator
      _lessonOpenConnectionOrchestrator;
  final _statusCode = 0;

  bool _done = false;
  bool get done => _done;
  set done(bool value) {
    _done = value;
    // notifyListeners();
  }

  bool _instantiated = false;
  bool get instantiated => _instantiated;
  set instantiated(bool value) {
    _instantiated = value;
    // notifyListeners();
  }

  String _lessonContent = "";
  String get lessonContent => _lessonContent;
  set lessonContent(String value) {
    _lessonContent = value;
  }
  LessonOpenModel get lessonOpenModel => _lessonOpenModel;

  LessonOpenViewModel() {
    _lessonOpenModel = LessonOpenModel.initialize();
    _lessonOpenConnectionOrchestrator = LessonOpenConnectionOrchestrator();
    // loadViewContent();
  }

  // void regenerate() {
  //   developer.log(">>> regenerate");
  // }

  Future<void> returnToMenu(BuildContext context) async {
    await _lessonOpenConnectionOrchestrator.saveLesson(lessonContent);
    developer.log("Lesson content: $lessonContent");
    // ignore: use_build_context_synchronously
    Navigator.restorablePushNamed(
      context,
      MenuView.routeName,
    );
  }

  Future<void> loadViewContent(int id) async {
    if(!instantiated){
      instantiated = true;
      try {
        final result =
            await _lessonOpenConnectionOrchestrator.getLessonOpenModel(id);

        _lessonOpenModel.cssContents = result.cssContents;
        _lessonOpenModel.lesson.title = result.lesson.title;
        _lessonOpenModel.lesson.content = result.lesson.content;

        notifyListeners();
      } catch (error) {
        // Handle errors
        developer.log('Error loading contents: $error', name: 'Error');
      }
    }
  }
}

// Future<String> _loadFileContents(String filePath) async {
//   return await rootBundle.loadString(filePath);
// }
