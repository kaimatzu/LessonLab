import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/components/dropdown_menu.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/components/input_field.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/messages/lesson/lesson_specifications.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:lessonlab/src/lessonlab_modules/lesson/components/text_area.dart';
import 'package:lessonlab/src/lessonlab_modules/results/lesson_result/lesson_result_view.dart';
import 'package:rinf/rinf.dart';

// This class holds all the input fields in the view
class FormField {
  final InputField? inputField;
  final TextArea? textArea;
  final Dropdown? dropdown;
  // final String? dropdownValue;

  FormField({this.inputField, this.dropdown, this.textArea})
      : assert(
            (inputField != null && dropdown == null && textArea == null) ||
                (inputField == null && dropdown != null && textArea == null) ||
                (inputField == null && dropdown == null && textArea != null),
            'Either provide an InputField or a Dropdown or a TextArea.');
}

class LessonSpecificationsViewModel extends ChangeNotifier {
  LessonSpecificationsViewModel() {
    final initializeFields = [
      InputField(label: 'Title', hintLabel: 'Enter lesson title'),
      InputField(label: 'Focus Topic', hintLabel: 'Enter focus of the lesson'),
      InputField(label: 'Timeframe', hintLabel: 'Enter timeframe'),
      TextArea(
          label: 'Learning Outcomes', hintLabel: 'Enter learning outcomes'),
      const Dropdown(label: 'Grade Level', list: <String>[
        'Elementary',
        'Junior High School',
        'Senior High School',
        'College',
      ]),
    ];

    for (var formField in initializeFields) {
      if (formField is InputField) {
        formFields.add(FormField(inputField: formField));
      } else if (formField is TextArea) {
        formFields.add(FormField(textArea: formField));
      } else if (formField is Dropdown) {
        formFields.add(FormField(dropdown: formField));
      }
    }
  }

  final _formFields = <FormField>[];
  get formFields => _formFields;

  final _lessonSpecifications = <String>[];
  get lessonSpecifications => _lessonSpecifications;

  var _statusCode = 0;

  Future<void> sendData() async {
    final requestMessage = RinfInterface.CreateRequest(
        lessonSpecifications: _lessonSpecifications);
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
    _statusCode = responseMessage.statusCode;
    developer.log(_statusCode.toString(), name: 'response-code');
  }

  Future<void> getData() async {
    // Debug purposes. Just to check if the lesson specs are stored in rust main().
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
    var content = responseMessage.lessonSpecifications;
    developer.log(content.toString(), name: 'content');
  }

  void collectFormTextValues() {
    _lessonSpecifications.clear();

    for (var formField in formFields) {
      if (formField.inputField != null) {
        _lessonSpecifications.add(formField.inputField!.controller.text);
      } else if (formField.textArea != null) {
        _lessonSpecifications.add(formField.textArea!.controller.text);
      } else if (formField.dropdown != null) {
        _lessonSpecifications.add(formField.dropdown!.getSelectedValue);
      } else {
        developer.log('Null error', name: 'generate-lesson');
        // TODO: Handle uninitialized null values, just in case.
      }
    }

    notifyListeners();

    developer.log(_lessonSpecifications.toString(), name: 'collect');
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

  void cancelLesson(BuildContext context) {
    Navigator.restorablePushNamed(context, UploadView.routeName);
  }

  void generateLesson(BuildContext context) {
    Navigator.restorablePushNamed(context, LessonResultView.routeName);
  }
}
