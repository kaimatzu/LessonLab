import 'package:flutter/services.dart';
import 'package:lessonlab/messages/results/open_finished_lesson/open_lesson.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_model.dart';
import 'package:rinf/rinf.dart';
import 'dart:developer' as developer;

class LessonOpenConnectionOrchestrator {
  Future<void> saveLesson(String content) async {
    final requestMessage = RinfInterface.UpdateRequest(lessonContent: content);
    final rustRequest = RustRequest(
      resource: RinfInterface.ID,
      operation: RustOperation.Create,
      message: requestMessage.writeToBuffer(),
      // blob: NO BLOB
    );
    final rustResponse =
        await requestToRust(rustRequest, timeout: const Duration(minutes: 10));
    final responseMessage = RinfInterface.UpdateResponse.fromBuffer(
      rustResponse.message!,
    );
    
    developer.log("Save lesson status: ${responseMessage.statusCode}");
  }

  Future<LessonOpenModel> getLessonOpenModel(int id) async {
    developer.log("Fired");
    final requestMessage = RinfInterface.ReadRequest(req: true, id: id);
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
    
    final lessonOpenModel = LessonOpenModel();
    lessonOpenModel.lesson.title = Future.value(responseMessage.title);
    lessonOpenModel.lesson.content = Future.value(responseMessage.mdContent);
    lessonOpenModel.cssContents = Future.value(_loadFileContents('assets/styles/markdown.css'));

    return lessonOpenModel;
  }

}

Future<String> _loadFileContents(String filePath) async {
  return await rootBundle.loadString(filePath);
}