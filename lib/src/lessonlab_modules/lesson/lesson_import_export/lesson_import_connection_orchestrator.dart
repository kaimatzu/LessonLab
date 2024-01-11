import 'package:flutter/services.dart';
import 'package:lessonlab/messages/import/import_material.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_model.dart';
import 'package:rinf/rinf.dart';
import 'dart:developer' as developer;

class LessonImportConnectionOrchestrator {
  Future<void> importLesson(String filePath, String folderName) async {
    final requestMessage = RinfInterface.CreateRequest(filePath: filePath, folderName: folderName);
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
    
    developer.log("Export lesson status: ${responseMessage.statusCode}");
  }
}