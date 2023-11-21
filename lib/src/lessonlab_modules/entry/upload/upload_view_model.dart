// ignore_for_file: unnecessary_getters_setters

import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications_view.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_specifications_view.dart';
import 'package:lessonlab/src/lessonlab_modules/results/lesson_result/lesson_result_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_controller.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/messages/entry/upload/uploaded_content.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:rinf/rinf.dart';

class UploadViewModel with ChangeNotifier {
  final _files = <XFile>[];
  List<XFile> get files => _files;

  final _urls = <String>[];
  List<String> get urls => _urls;

  final _textFiles = <TextFile>[];
  List<TextFile> get textFiles => _textFiles;

  var _statusCode = 0;

  bool _hasFiles = false;
  bool get hasFiles => _hasFiles;
  set hasFiles(bool value) {
    _hasFiles = value;
  }

  Future<void> sendData() async {
    final requestMessage = RinfInterface.CreateRequest(
      filePaths: _files.map((file) => file.path).toList(),
      urls: _urls,
      texts: _textFiles
          .map((textFile) => RinfInterface.TextFile(
                title: textFile.title,
                content: textFile.content,
              ))
          .toList(),
    );
    final rustRequest = RustRequest(
      resource: RinfInterface.ID,
      operation: RustOperation.Create,
      message: requestMessage.writeToBuffer(),
      // blob: NO BLOB
    );
    final rustResponse = await requestToRust(rustRequest);
    final responseMessage = RinfInterface.CreateResponse.fromBuffer(
      rustResponse.message!,
    );
    _statusCode = responseMessage.statusCode;
    developer.log(_statusCode.toString(), name: 'rinf-info');
  }

  Future<void> getData() async {
    // Debug purposes. Just to check if the uploaded files are stored in rust main().
    final requestMessage = RinfInterface.ReadRequest(req: true);
    final rustRequest = RustRequest(
      resource: RinfInterface.ID,
      operation: RustOperation.Read,
      message: requestMessage.writeToBuffer(),
      // blob: NO BLOB
    );
    final rustResponse = await requestToRust(rustRequest);
    final responseMessage = RinfInterface.ReadResponse.fromBuffer(
      rustResponse.message!,
    );
    var content = responseMessage.filePaths;
    developer.log(content.join(), name: 'rinf-info');
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
      Navigator.restorablePushNamed(
        context,
        LessonSpecificationsView.routeName,
      );
    } else {
      null;
    }
  }

  void newQuiz(BuildContext context) {
    if (_hasFiles) {
      sendData();
      getData();
      Navigator.restorablePushNamed(
        context,
        QuizSpecificationsView.routeName,
      );
    } else {
      null;
    }
  }
}
