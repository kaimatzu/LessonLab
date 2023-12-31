import 'package:lessonlab/messages/entry/menu/menu.pb.dart'
    // ignore: library_prefixes
    as AutogeneratedMenuModel;

class LessonModel {
  late Future<int> _id;
  late Future<String> _title;
  late Future<String> _content;
  late Future<String> _location;

  Future<int> get id => _id;
  set id(Future<int> value) {
    _id = value;
  }

  Future<String> get title => _title;
  set title(Future<String> value) {
    _title = value;
  }

  Future<String> get content => _content;
  set content(Future<String> value) {
    _content = value;
  }

  Future<String> get location => _location;
  set location(Future<String> value) {
    _location = value;
  }

  LessonModel();

  LessonModel.initialize()
      : _id = Future.value(0),
        _title = Future.value(""),
        _content = Future.value(""),
        _location = Future.value("");

  LessonModel.fromAutogenerated(
      AutogeneratedMenuModel.LessonModel autogeneratedModel) {
    _id = Future.value(autogeneratedModel.id);
    _title = Future.value(autogeneratedModel.title);
    _content = Future.value(autogeneratedModel.content);
    _location = Future.value(autogeneratedModel.location);
  }

  void edit() {}
  void regenerate() {}
  void partialRegenerate() {}
  void appendToLesson() {}
}
