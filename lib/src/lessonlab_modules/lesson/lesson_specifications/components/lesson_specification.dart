import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/components/dropdown_menu.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/components/input_field.dart';

class LessonSpecification {
  String _label;
  String _content;

  LessonSpecification(this._label, this._content);

  String get label => _label;
  set label(value) {
    _label = value;
  }

  String get content => _content;
  set content(value) {
    _content = value;
  }
}
