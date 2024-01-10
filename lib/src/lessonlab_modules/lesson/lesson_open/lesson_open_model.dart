import 'package:lessonlab/src/global_models/lesson_model.dart';

class LessonOpenModel {
  LessonModel lesson = LessonModel.initialize();
  // late LessonModel lesson = LessonModel(1, 'Test-title', 'Test-content');

  LessonOpenModel();

  LessonOpenModel.initialize() 
    : _cssContents = Future.value("");

  late Future<String> _cssContents;
  Future<String> get cssContents => _cssContents;
  set cssContents(Future<String> value) {
    _cssContents = value;
  }
}
