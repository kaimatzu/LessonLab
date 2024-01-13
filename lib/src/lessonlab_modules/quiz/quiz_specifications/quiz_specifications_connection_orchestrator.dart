import 'package:lessonlab/messages/quiz/quiz_specifications.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_specifications/quiz_specifications_model.dart';
import 'package:rinf/rinf.dart';
import 'dart:developer' as developer;

class QuizSpecificationsConnectionOrchestrator {
  void sendData(List<String> specifications) async {
    final requestMessage =
        RinfInterface.CreateRequest(quizSpecifications: specifications);
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

    developer.log('${responseMessage.statusCode}', name: 'quizspec code');
  }
}
