import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_model.dart';
import 'package:lessonlab/messages/results/view_lesson_result/load_lesson.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:rinf/rinf.dart';

class LessonResultViewModel with ChangeNotifier {
  final lessonResultModel = LessonResultModel();
  var _statusCode = 0;

  LessonResultViewModel() {
    // Load data when the view model is created
    loadContents();
  }

  Future<void> loadContents() async {
    try {
      lessonResultModel.cssContents =
          _loadFileContents('assets/styles/markdown.css');

      // await getData();
      // final data = await getData();
      // mdContents = data[0];
      lessonResultModel.lesson.title = getTitleData();
      lessonResultModel.lesson.content = getData();

      // Notify listeners that the data has been loaded
      // Notify (View)
      notifyListeners();
    } catch (error) {
      // Handle errors
      developer.log('Error loading contents: $error', name: 'Error');
    }
  }

  Future<void> sendData() async {
    // TODO: Handle saving lesson
  }

  Future<String> getData() async {
    final requestMessage = RinfInterface.ReadRequest(req: true);
    final rustRequest = RustRequest(
      resource: RinfInterface.ID,
      operation: RustOperation.Read,
      message: requestMessage.writeToBuffer(),
      // blob: NO BLOB
    );
    final rustResponse =
        await requestToRust(rustRequest, timeout: const Duration(minutes: 10));
    final responseMessage = RinfInterface.ReadResponse.fromBuffer(
      rustResponse.message!,
      // TODO: handle this could be a null
    );
    _statusCode = responseMessage.statusCode;
    developer.log(_statusCode.toString(), name: 'status code');
    developer.log(responseMessage.errorString.toString(),
        name: 'error message');
    return responseMessage.mdContent;
  }

  Future<String> getTitleData() async {
    final requestMessage = RinfInterface.ReadRequest(req: true);
    final rustRequest = RustRequest(
      resource: RinfInterface.ID,
      operation: RustOperation.Read,
      message: requestMessage.writeToBuffer(),
      // blob: NO BLOB
    );
    final rustResponse =
        await requestToRust(rustRequest, timeout: const Duration(minutes: 10));
    final responseMessage = RinfInterface.ReadResponse.fromBuffer(
      rustResponse.message!,
      // TODO: handle this could be a null
    );
    _statusCode = responseMessage.statusCode;
    developer.log(_statusCode.toString(), name: 'status code');
    developer.log(responseMessage.errorString.toString(),
        name: 'error message');
    return responseMessage.title;
  }
}

Future<String> _loadFileContents(String filePath) async {
  return await rootBundle.loadString(filePath);
}
