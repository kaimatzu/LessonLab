import 'package:lessonlab/messages/quiz/quiz_specifications.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:rinf/rinf.dart';
import 'dart:developer' as developer;

class QuizSpecificationsConnectionOrchestrator {
  QuizSpecificationsConnectionOrchestrator() {}

  void sendQuizSpecs(List<String> specifications) async {
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
      // TODO: handle this could be a null
    );

    developer.log('${responseMessage.statusCode}', name: 'quiz-spec code');
  }
}
