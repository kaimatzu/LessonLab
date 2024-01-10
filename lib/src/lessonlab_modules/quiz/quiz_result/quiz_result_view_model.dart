import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_view.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/dropdown_menu.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/input_field.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/messages/lesson/lesson_specifications.pb.dart'
    as RinfInterface;
import 'package:lessonlab/src/lessonlab_modules/quiz/components/number_field.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/text_area.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_view.dart';
import 'package:rinf/rinf.dart';

class QuizResultViewModel extends ChangeNotifier {
  QuizResultViewModel();

  List<Map<String, dynamic>> _results = [];

  List<Map<String, dynamic>> get results => _results;

  void setResults(List<Map<String, dynamic>> results) {
    _results = results;
    notifyListeners();
  }
}
