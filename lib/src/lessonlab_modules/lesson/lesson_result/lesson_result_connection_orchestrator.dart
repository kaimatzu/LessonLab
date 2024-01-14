import 'package:flutter/services.dart';
import 'package:lessonlab/messages/results/view_lesson_result/load_lesson.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_model.dart';
import 'package:rinf/rinf.dart';
import 'dart:developer' as developer;

class LessonResultConnectionOrchestrator {
  Future<void> saveLesson(String content, int lessonId, String newLessonTitle) async {
    final requestMessage = RinfInterface.CreateRequest(lessonContent: content, lessonId: lessonId, newLessonTitle: newLessonTitle);
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
    lessonResultModel.lesson.title = responseMessage.title;
    lessonResultModel.lesson.content = responseMessage.mdContent;
    lessonResultModel.cssContents =
        Future.value(_loadFileContents('assets/styles/markdown.css'));
    lessonResultModel.lesson.id = responseMessage.lessonId;
    
    return lessonResultModel;
  }

  Future<void> reopenLessonStream(String additionalCommands, int lessonId, {String content = ''}) async {
    final requestMessage = RinfInterface.UpdateRequest(contentToRegenerate: content, additionalCommands: additionalCommands, lessonId: lessonId);
    final rustRequest = RustRequest(
      resource: RinfInterface.ID,
      operation: RustOperation.Update,
      message: requestMessage.writeToBuffer(),
      // blob: NO BLOB
    );
    final rustResponse =
        await requestToRust(rustRequest, timeout: const Duration(minutes: 10));
    final responseMessage = RinfInterface.UpdateResponse.fromBuffer(
      rustResponse.message!,
    );

    developer.log("Reopen lesson stream status: ${responseMessage.statusCode}");
  }
}

Future<String> _loadFileContents(String filePath) async {
  return await rootBundle.loadString(filePath);
}
