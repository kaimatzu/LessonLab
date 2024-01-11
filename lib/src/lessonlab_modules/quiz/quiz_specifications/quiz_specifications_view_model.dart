import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/dropdown_menu.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/input_field.dart';

import 'package:lessonlab/messages/quiz/quiz_specifications.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:lessonlab/src/lessonlab_modules/quiz/components/number_field.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/components/text_area.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_view.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_specifications/quiz_specifications_connection_orchestrator.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_specifications/quiz_specifications_model.dart';
import 'package:rinf/rinf.dart';

import 'dart:developer' as developer;

// This class holds all the input fields in the view
class FormField {
  final InputField? inputField;
  final TextArea? textArea;
  final Dropdown? dropdown;
  final NumberField? numberField;
  // final String? dropdownValue;

  FormField({this.inputField, this.dropdown, this.textArea, this.numberField})
      : assert(
            (inputField != null &&
                    dropdown == null &&
                    textArea == null &&
                    numberField == null) ||
                (inputField == null &&
                    dropdown != null &&
                    textArea == null &&
                    numberField == null) ||
                (inputField == null &&
                    dropdown == null &&
                    textArea != null &&
                    numberField == null) ||
                (inputField == null &&
                    dropdown == null &&
                    textArea == null &&
                    numberField != null),
            'Either provide an InputField or a Dropdown or a TextArea or a NumberField');
}

class QuizSpecificationsViewModel extends ChangeNotifier {
  QuizSpecificationsViewModel() {
    final initializeFields = [
      InputField(label: 'Title', hintLabel: 'Enter quiz title'),
      const Dropdown(
          label: "Type",
          list: <String>['Identification', 'Multiple Choice', 'Both']),
      const Dropdown(label: "Difficulty", list: <String>[
        'any',
        'easy',
        'medium',
        'hard',
      ]),
      NumberField(label: 'Number of Items', hintLabel: 'Enter number of items'),
      InputField(label: 'Timeframe', hintLabel: 'Enter timeframe'),
    ];

    for (var formField in initializeFields) {
      if (formField is InputField) {
        formFields.add(FormField(inputField: formField));
      } else if (formField is TextArea) {
        formFields.add(FormField(textArea: formField));
      } else if (formField is Dropdown) {
        formFields.add(FormField(dropdown: formField));
      } else if (formField is NumberField) {
        formFields.add(FormField(numberField: formField));
      }
    }
  }

  var model = QuizSpecificationsModel();
  var orchestrator = QuizSpecificationsConnectionOrchestrator();
  var formFields = <FormField>[];
  var quizSpecifications = <String>[];
  var statusCode = 0;

  Future<void> sendData() async {
    final requestMessage =
        RinfInterface.CreateRequest(quizSpecifications: quizSpecifications);
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
    statusCode = responseMessage.statusCode;
    developer.log(statusCode.toString(), name: 'response-code');
  }

  Future<void> getData() async {
    // Debug purposes. Just to check if the quiz specs are stored in rust main().
    final requestMessage = RinfInterface.ReadRequest(req: true);
    final rustRequest = RustRequest(
      resource: RinfInterface.ID,
      operation: RustOperation.Read,
      message: requestMessage.writeToBuffer(),
      // blob: NO BLOB
    );
    final rustResponse = await requestToRust(rustRequest);
    final responseMessage = RinfInterface.ReadResponse.fromBuffer(
      rustResponse.message!,
    );
    var content = responseMessage.quizSpecifications;
    developer.log(content.toString(), name: 'content');
  }

  void collectFormTextValues() {
    quizSpecifications.clear();

    for (var formField in formFields) {
      if (formField.inputField != null) {
        quizSpecifications.add(formField.inputField!.controller.text);
      } else if (formField.textArea != null) {
        quizSpecifications.add(formField.textArea!.controller.text);
      } else if (formField.dropdown != null) {
        quizSpecifications.add(formField.dropdown!.getSelectedValue);
      } else {
        developer.log('Null error', name: 'generate-quiz');
        // TODO: Handle uninitialized null values, just in case.
      }
    }

    notifyListeners();

    developer.log(quizSpecifications.toString(), name: 'collect');
  }

  void addCustomSpecifications() {
    formFields.add(
      FormField(
        inputField: InputField(
          label: 'Custom specifications',
          hintLabel: 'Enter custom specifications',
        ),
      ),
    );
    notifyListeners();
    developer.log('Added new custom spec', name: 'custom specs');
  }

  void cancelQuiz(BuildContext context) {
    Navigator.pop(context);
  }

  void generateQuiz(
      BuildContext context, QuizPageViewModel quizPageViewModel) async {
    // Navigator.restorablePushNamed(context, quizResultView.routeName);
    // TODO: send quiz specs to backend using orchestrator
    // developer.log("generate quiz clicked");
    // quizPageViewModel.loadQuizModel();
    // developer.log("quiz model loaded");
    await quizPageViewModel.loadQuizModel();
    // orchestrator.sendQuizSpecs(model.specifications);
    if (!context.mounted) return;
    Navigator.restorablePushNamed(context, QuizPageView.routeName);
    developer.log("page changed");
  }
}
