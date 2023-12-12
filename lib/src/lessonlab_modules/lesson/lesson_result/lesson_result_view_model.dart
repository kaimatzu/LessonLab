import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_connection_orchestrator.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_model.dart';

class LessonResultViewModel with ChangeNotifier {
  late final LessonResultModel _lessonResultModel;
  late final LessonResultConnectionOrchestrator
      _lessonResultConnectionOrchestrator;
  var _statusCode = 0;

  bool _done = false;
  bool get done => _done;
  set done(bool value) {
    _done = value;
    // notifyListeners();
  }

  LessonResultModel get lessonResultModel => _lessonResultModel;

  LessonResultViewModel() {
    _lessonResultModel = LessonResultModel.initialize();
    _lessonResultConnectionOrchestrator = LessonResultConnectionOrchestrator();
    loadViewContent();
  }

  // void regenerate() {
  //   developer.log(">>> regenerate");
  // }

  void returnToMenu(BuildContext context) {
    Navigator.restorablePushNamed(
      context,
      MenuView.routeName,
    );
  }

  Future<void> loadViewContent() async {
    try {
      final result =
          await _lessonResultConnectionOrchestrator.getLessonResultModel();

      _lessonResultModel.cssContents = result.cssContents;
      _lessonResultModel.lesson.title = result.lesson.title;
      _lessonResultModel.lesson.content = result.lesson.content;

      notifyListeners();
    } catch (error) {
      // Handle errors
      developer.log('Error loading contents: $error', name: 'Error');
    }
  }
}

// Future<String> _loadFileContents(String filePath) async {
//   return await rootBundle.loadString(filePath);
// }
