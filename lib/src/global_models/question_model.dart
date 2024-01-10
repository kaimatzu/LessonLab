import 'package:lessonlab/src/global_models/choice_model.dart';
import 'package:lessonlab/messages/quiz/quiz_page.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;

// Type 1 = Identification
// Type 2 = Multiple Choice
class QuestionModel {
  late String question;
  late int type;

  // QuestionModel.fromAutogenerated(RinfInterface.QuestionModel pbQuestionModel) {
  //   question = pbQuestionModel.question;
  //   type = pbQuestionModel.type;
  // }

  void edit() {}
}

class IdentificationQuestionModel implements QuestionModel {
  late String answer;

  IdentificationQuestionModel.fromAutogenerated(
      RinfInterface.QuestionModel pbQuestionModel) {
    answer = pbQuestionModel.identification.answer;
    question = pbQuestionModel.question;
    type = pbQuestionModel.type;
  }

  @override
  late String question;

  @override
  late int type;

  @override
  void edit() {
    // TODO: implement edit
  }
}

class MultipleChoiceQuestionModel implements QuestionModel {
  late List<ChoiceModel> choices;

  MultipleChoiceQuestionModel.fromAutogenerated(
      RinfInterface.QuestionModel pbQuestionModel) {
    question = pbQuestionModel.question;
    type = pbQuestionModel.type;
    choices = pbQuestionModel.multipleChoice.choices
        .map((choice) => ChoiceModel.fromAutogenerated(choice))
        .toList();
  }

  // MultipleChoiceQuestionModel.fromAutogenerated(
  //     super.pbQuestionModel, List<RinfInterface.ChoiceModel> pbChoiceModel)
  //     : super.fromAutogenerated() {}

  @override
  late String question;

  @override
  late int type;

  @override
  void edit() {
    // TODO: implement edit
  }
}
