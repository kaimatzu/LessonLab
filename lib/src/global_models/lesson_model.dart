import 'package:lessonlab/messages/entry/menu/menu.pb.dart'
    // ignore: library_prefixes
    as AutogeneratedMenuModel;

class LessonModel {
  late int _id;

  late Future<String> _title;
  Future<String> get title => _title;
  set title(value) {
    _title = value;
  }

  late Future<String> _content;
  Future<String> get content => _content;
  set content(value) {
    _content = value;
  }

  LessonModel();

  LessonModel.fromAutogenerated(
      AutogeneratedMenuModel.LessonModel autogeneratedModel) {
    _id = 0;
    _title = Future.value(autogeneratedModel.title);
    _content = Future.value(autogeneratedModel.content);
  }

  void edit() {}
  void regenerate() {}
  void partialRegenerate() {}
  void appendToLesson() {}
}
