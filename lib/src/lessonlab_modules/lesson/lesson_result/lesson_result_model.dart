import 'package:lessonlab/src/global_models/lesson_model.dart';

class LessonResultModel {
  final LessonModel lesson = LessonModel();
  // late LessonModel lesson = LessonModel(1, 'Test-title', 'Test-content');

  late Future<String> _cssContents;
  Future<String> get cssContents => _cssContents;
  set cssContents(value) {
    _cssContents = value;
  }
}
