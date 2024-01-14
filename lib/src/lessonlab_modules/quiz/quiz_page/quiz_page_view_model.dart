import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_models/question_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_view.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/dropdown_menu.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/input_field.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/messages/lesson/lesson_specifications.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:lessonlab/src/lessonlab_modules/quiz/components/number_field.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/text_area.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_connection_orchestrator.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_model.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_view.dart';
// import 'package:lessonlab/src/lessonlab_modules/results/lesson_result/lesson_result_view.dart';
import 'package:rinf/rinf.dart';

class QuizPageViewModel extends ChangeNotifier {
  QuizPageViewModel();
  final QuizPageConnectionOrchestrator orchestrator =
      QuizPageConnectionOrchestrator();
  final QuizPageModel model = QuizPageModel();

  List<QuestionModel?> get questions => model.quiz.questions;
  // get questions => _questions;

  Future<void> loadQuizModel() async {
    // orchestrator.getQuizModel().then((value) => model.quiz = value);
    model.quiz = await orchestrator.getQuizModel();
    developer.log("load quiz model", name: "function");
  }

  void shuffleQuestions() {
    questions.shuffle();
  }
}
