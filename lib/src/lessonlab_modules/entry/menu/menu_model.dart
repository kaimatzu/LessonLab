import 'package:lessonlab/src/global_models/lesson_model.dart';
import 'package:lessonlab/src/global_models/quiz_model.dart';

class MenuModel {
  late Future<List<LessonModel>> _lessons;
  late Future<List<QuizModel>> _quizzes;

  MenuModel();

  MenuModel.initialize() 
    : _lessons = Future.value([]),
      _quizzes = Future.value([]);

  Future<List<LessonModel>> get lessons => _lessons;
  set lessons(Future<List<LessonModel>> value) {
    _lessons = value;
  }

  Future<List<QuizModel>> get quizzes => _quizzes;
  set quizzes(Future<List<QuizModel>> value) {
    _quizzes = value;
  }
}
