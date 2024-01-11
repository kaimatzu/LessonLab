import 'package:flutter/services.dart';
import 'package:lessonlab/messages/export/export_material_as_custom_type.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_model.dart';
import 'package:rinf/rinf.dart';
import 'dart:developer' as developer;

class LessonExportConnectionOrchestrator {
  Future<void> exportLesson(String filePath) async {
    final requestMessage = RinfInterface.CreateRequest(filePath: filePath);
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