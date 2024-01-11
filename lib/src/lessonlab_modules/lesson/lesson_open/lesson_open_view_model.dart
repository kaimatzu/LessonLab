import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_import_export/lesson_export_connection_orchestrator.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_connection_orchestrator.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_model.dart';

class LessonOpenViewModel with ChangeNotifier {
  late final LessonOpenModel _lessonOpenModel;
  late final LessonOpenConnectionOrchestrator
      _lessonOpenConnectionOrchestrator;
  late final LessonExportConnectionOrchestrator
      _lessonExportConnectionOrchestrator;
  final _statusCode = 0;

  bool _done = true;
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
    _lessonExportConnectionOrchestrator = LessonExportConnectionOrchestrator();
    // loadViewContent();
  }

  // void regenerate() {
  //   developer.log(">>> regenerate");
  // }

  Future<void> returnToMenu(BuildContext context) async {
    // await _lessonOpenConnectionOrchestrator.saveLesson(lessonContent); // TODO: Fix later
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

  Future<void> exportLesson(String lessonTitle) async {
    final FileSaveLocation? result =
      await getSaveLocation(
        acceptedTypeGroups: [
          const XTypeGroup(
            label: "LessonLab file (.lela)",
            extensions: [".lela"]
          )  
        ],
        suggestedName: "$lessonTitle.lela"
      );
    if (result != null) {
      developer.log(result.path);
      _lessonExportConnectionOrchestrator.exportLesson(result.path);
    }
  }
}

// Future<String> _loadFileContents(String filePath) async {
//   return await rootBundle.loadString(filePath);
// }
