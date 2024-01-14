import 'dart:ffi';

import 'package:flutter/services.dart';
import 'package:lessonlab/messages/results/open_finished_lesson/open_lesson.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_model.dart';
import 'package:rinf/rinf.dart';
import 'dart:developer' as developer;

class LessonOpenConnectionOrchestrator {
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
    lessonOpenModel.lesson.title = responseMessage.title;
    lessonOpenModel.lesson.content = responseMessage.mdContent;
    lessonOpenModel.cssContents =
        Future.value(_loadFileContents('assets/styles/markdown.css'));

    return lessonOpenModel;
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
