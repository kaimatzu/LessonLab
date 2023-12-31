import 'package:flutter/services.dart';
import 'package:lessonlab/messages/results/view_lesson_result/load_lesson.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_model.dart';
import 'package:rinf/rinf.dart';
import 'dart:developer' as developer;

class LessonResultConnectionOrchestrator {
  Future<void> saveLesson(String content) async {
    final requestMessage = RinfInterface.CreateRequest(lessonContent: content);
    final rustRequest = RustRequest(
      resource: RinfInterface.ID,
      operation: RustOperation.Create,
      message: requestMessage.writeToBuffer(),
      // blob: NO BLOB
    );
    final rustResponse =
        await requestToRust(rustRequest, timeout: const Duration(minutes: 10));
    final responseMessage = RinfInterface.CreateResponse.fromBuffer(
      rustResponse.message!,
    );
    
    developer.log("Save lesson status: ${responseMessage.statusCode}");
  }

  Future<LessonResultModel> getLessonResultModel() async {
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
    
    final lessonResultModel = LessonResultModel();
    lessonResultModel.lesson.title = Future.value(responseMessage.title);
    lessonResultModel.lesson.content = Future.value(responseMessage.mdContent);
    lessonResultModel.cssContents = Future.value(_loadFileContents('assets/styles/markdown.css'));

    return lessonResultModel;
  }

}

Future<String> _loadFileContents(String filePath) async {
  return await rootBundle.loadString(filePath);
}