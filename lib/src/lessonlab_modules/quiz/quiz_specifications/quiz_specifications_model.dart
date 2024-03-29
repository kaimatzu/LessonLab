class QuizSpecificationsModel {
  late List<QuizSpecification> quizSpecs;
}

class QuizSpecification {
  String _label;
  String _content;

  QuizSpecification(this._label, this._content);

  String get label => _label;
  set label(value) {
    _label = value;
  }

  String get content => _content;
  set content(value) {
    _content = value;
  }
}
