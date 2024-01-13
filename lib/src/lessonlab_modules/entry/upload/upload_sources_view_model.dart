// ignore_for_file: unnecessary_getters_setters

import 'package:flutter/material.dart';
// import 'package:lessonlab/messages/entry/upload/uploaded_content.pb.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_connection_orchestrator.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_model.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/lesson_specifications_view.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_specifications/quiz_specifications_view.dart';
// import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_view.dart';
import 'package:cross_file/cross_file.dart';
// import 'dart:developer' as developer;

// import 'package:lessonlab/messages/entry/upload/uploaded_content.pb.dart'
//     // ignore: library_prefixes
//     as RinfInterface;
// import 'package:rinf/rinf.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_controller.dart';

class UploadSourcesViewModel with ChangeNotifier {
  final UploadSourcesModel _uploadModel = UploadSourcesModel();
  final UploadSourcesConnectionOrchestrator _uploadConnectionOrchestrator =
      UploadSourcesConnectionOrchestrator();

  UploadSourcesViewModel () {
    debugPrint("UploadSourcesViewModel created!");
  }

  bool _hasFiles = false;
  bool get hasFiles => _hasFiles;
  set hasFiles(bool value) {
    _hasFiles = value;
  }

  void reset() {
    _uploadModel.pdfFilePaths.clear();
    _uploadModel.urls.clear();
    _uploadModel.texts.clear();
    _hasFiles = false;
    notifyListeners();
  }

  void getData() {
    _uploadConnectionOrchestrator.getData();
  }

  void sendData() {
    _uploadConnectionOrchestrator.sendData(_uploadModel);
  }

  void addPdf(XFile pdf) {
    _uploadModel.pdfFilePaths.add(pdf);
    notifyListeners();
  }

  void addUrl(String url) {
    _uploadModel.urls.add(url);
    notifyListeners();
  }

  void addText(TextFile text) {
    _uploadModel.texts.add(text);
    notifyListeners();
  }

  void removePdf(XFile pdf) {
    _uploadModel.pdfFilePaths.remove(pdf);
    notifyListeners();
  }

  void removeUrl(String url) {
    _uploadModel.urls.remove(url);
    notifyListeners();
  }

  void removeText(TextFile text) {
    _uploadModel.texts.remove(text);
    notifyListeners();
  }

  void cancelUpload(BuildContext context) {
    Navigator.restorablePushNamed(
      context,
      MenuView.routeName,
    );
  }

  void newLesson(BuildContext context) {
    if (_hasFiles) {
      sendData();
      getData();
      reset();
      Navigator.restorablePushNamed(
        context,
        LessonSpecificationsView.routeName,
      );
    }
  }

  void newQuiz(BuildContext context) {
    if (_hasFiles) {
      sendData();
      getData();
      reset();
      Navigator.restorablePushNamed(
        context,
        QuizSpecificationsView.routeName,
      );
    }
  }

  List<XFile> getFilePaths() {
    return _uploadModel.pdfFilePaths;
  }

  List<String> getUrls() {
    return _uploadModel.urls;
  }

  List<TextFile> getTexts() {
    return _uploadModel.texts;
  }
}
