import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/messages/results/view_lesson_result/load_lesson.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:rinf/rinf.dart';

class LessonResultViewModel with ChangeNotifier {
  late Future<String> _mdContents;
  Future<String> get mdContents => _mdContents;
  set mdContents(value) {
    _mdContents = value;
  }

  late Future<String> _cssContents;
  Future<String> get cssContents => _cssContents;
  set cssContents(value) {
    _cssContents = value;
  }

  var _statusCode = 0;

  LessonResultViewModel() {
    // Load data when the view model is created
    loadContents();
  }

  Future<void> loadContents() async {
    try {
      cssContents = _loadFileContents('assets/styles/markdown.css');
      mdContents = getData();

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
}

Future<String> _loadFileContents(String filePath) async {
  return await rootBundle.loadString(filePath);
}
