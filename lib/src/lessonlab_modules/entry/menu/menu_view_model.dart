import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_models/lesson_model.dart';
import 'package:lessonlab/src/global_models/quiz_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/components/menu_card.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_connection_orchestrator.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_view.dart';
import 'dart:developer' as developer;

class MenuViewModel with ChangeNotifier {
  late final MenuModel _menuModel;
  late final MenuConnectionOrchestrator _menuConnectionOrchestrator;

  MenuModel get menuModel => _menuModel;

  MenuViewModel() {
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
    _menuConnectionOrchestrator = MenuConnectionOrchestrator();

    _menuModel = MenuModel();

    _menuModel.lessons = loadMenuModelLessons();
    _menuModel.quizzes = loadMenuModelQuizzes();
  }

  Future<List<LessonModel>> loadMenuModelLessons() async {
    final result = await _menuConnectionOrchestrator.getData();
    return result.lessons;
  }

  Future<List<QuizModel>> loadMenuModelQuizzes() async {
    final result = await _menuConnectionOrchestrator.getData();
    return result.quizzes;
  }
}
