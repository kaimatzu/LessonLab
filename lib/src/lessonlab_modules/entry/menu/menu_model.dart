import 'package:lessonlab/src/global_models/lesson_model.dart';
import 'package:lessonlab/src/global_models/quiz_model.dart';

class MenuModel {
  late List<LessonModel> _lessons;
  late List<QuizModel> _quizzes;

  MenuModel();

  MenuModel.initialize()
      : _lessons = [],
        _quizzes = [];
  // MenuModel.initialize()
  //     : _lessons = Future.value([]),
  //       _quizzes = Future.value([]);

  List<LessonModel> get lessons => _lessons;
  set lessons(List<LessonModel> value) {
    _lessons = value;
  }

  List<QuizModel> get quizzes => _quizzes;
  set quizzes(List<QuizModel> value) {
    _quizzes = value;
  }
}
