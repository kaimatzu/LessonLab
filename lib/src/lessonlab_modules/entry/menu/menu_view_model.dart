import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_models/lesson_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_connection_orchestrator.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_view.dart';
import 'package:file_selector/file_selector.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_import_export/lesson_import_connection_orchestrator.dart';

class MenuViewModel with ChangeNotifier {
  late final MenuModel _menuModel;
  late final MenuConnectionOrchestrator _menuConnectionOrchestrator;
  late final LessonImportConnectionOrchestrator
      _lessonImportConnectionOrchestrator;
  MenuModel get menuModel => _menuModel;

  MenuViewModel() {
    _menuModel = MenuModel.initialize();
    _menuConnectionOrchestrator = MenuConnectionOrchestrator();
    _lessonImportConnectionOrchestrator = LessonImportConnectionOrchestrator();
    loadViewContent();
    // for (int i = 0; i < 4; i++) {
    //   lesson.add(LessonModel(i, 'Title $i', 'Content $i'));
    // }

    // _menuModel = MenuModel(lesson, quiz);
    //_menuModel = _menuConnectionOrchestrator.getData();
    // _menuModel = MenuModel(_menuConnectionOrchestrator.loadLessons(),
    //     _menuConnectionOrchestrator.loadQuizzes());
  }

  void navigateToUploadScreen(BuildContext context) {
    Navigator.restorablePushNamed(
      context,
      UploadSourcesView.routeName,
    );
  }

  Future<void> loadViewContent() async {
    final result = await _menuConnectionOrchestrator.getMenuModel();

    // _menuModel = MenuModel();

    _menuModel.lessons = result.lessons;
    _menuModel.quizzes = result.quizzes;

    notifyListeners();
  }

  void delete(String title) {
    _menuModel.lessons.then((List<LessonModel> lessons) {
      for (LessonModel lesson in lessons) {
        lesson.title.then((String elementTitle) {
          // TODO: add ID for each lesson
          // id to check for equality here (currently title)
          //               |
          //               V
          if (elementTitle == title) {
            _deleteLesson(lesson);
          }
        });
      }
    });
  }

  void deleteId(int id) {
    _menuModel.lessons.then((List<LessonModel> lessons) {
      for (LessonModel lesson in lessons) {
        lesson.id.then((int elementId) {
          if (elementId == id) {
            _deleteLesson(lesson);
          }
        });
      }
    });
  }

  void _deleteLesson(LessonModel lesson) {
    _menuModel.lessons.then((List<LessonModel> lessons) {
      lessons.remove(lesson);
    });

    lesson.id.then((id) => _menuConnectionOrchestrator.deleteLesson(id));

    notifyListeners();
  }

  Future<void> importLesson() async {
    const XTypeGroup typeGroup =
        XTypeGroup(label: "LessonLab file (.lela)", extensions: [".lela"]);

    final XFile? file =
        await openFile(acceptedTypeGroups: <XTypeGroup>[typeGroup]);
    if (file != null) {
      debugPrint(file.path);
      debugPrint(file.name);
      _lessonImportConnectionOrchestrator.importLesson(file.path, file.name);
    }
  }
}
