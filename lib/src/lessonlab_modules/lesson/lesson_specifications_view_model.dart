import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/components/dropdown_menu.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/components/input_field.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/messages/lesson/lesson_specifications.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:rinf/rinf.dart';

class FormField {
  final InputField? inputField;
  final Dropdown? dropdown;
  // final String? dropdownValue;

  FormField(
      {this.inputField, this.dropdown})
      : assert(
            (inputField != null &&
                    dropdown == null) ||
                (inputField == null &&
                    dropdown != null),
            'Either provide an InputField or a Dropdown.');
}

class LessonSpecificationsViewModel extends ChangeNotifier {
  LessonSpecificationsViewModel() {
    final initializeFields = [
      InputField(label: 'Title', hintLabel: 'Enter lesson title'),
      InputField(
          label: 'Focus Topic', hintLabel: 'Enter focus of the lesson'),
      InputField(label: 'Timeframe', hintLabel: 'Enter timeframe'),
      InputField(
          label: 'Learning Outcomes', hintLabel: 'Enter learning outcomes'),
      const Dropdown(),
    ];

    for (var formField in initializeFields) {
      if (formField is InputField) {
        formFields.add(FormField(inputField: formField));
      } 
      else if (formField is Dropdown) {
        formFields.add(FormField(dropdown: formField));
      }
    }
  }

  var formFields = <FormField>[];

  var lessonSpecifications = <String>[];
  var statusCode = 0;

  Future<void> sendData() async {
    final requestMessage = RinfInterface.CreateRequest(
      lessonSpecifications: lessonSpecifications
    );
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
    developer.log(statusCode.toString(), name: 'rinf-info');
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
    developer.log(content.toString(), name: 'rinf-info');
  }

  void collectFormTextValues() {
    lessonSpecifications.clear();

    for(var formField in formFields) {
      if (formField.inputField != null) {
        lessonSpecifications.add(formField.inputField!.controller.text);
      }
      else if (formField.dropdown != null) {
        lessonSpecifications.add(formField.dropdown!.getSelectedValue);
      } 
      else {
        // TODO: Handle uninitialized null values, just in case.
      }
    }

    notifyListeners();

    developer.log(lessonSpecifications.toString());
  }
}
