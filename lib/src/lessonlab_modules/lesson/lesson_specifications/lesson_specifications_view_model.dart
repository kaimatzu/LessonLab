import 'package:file_selector/file_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lessonlab/src/global_models/lesson_model.dart';
import 'package:lessonlab/src/global_models/quiz_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/components/dropdown_menu.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/components/input_field.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/components/lesson_specification.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/components/text_area.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/lesson_specifications_connection_orchestrator.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/lesson_specifications_model.dart';
import 'package:lessonlab/src/settings/shared_preferences.dart';

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
      titleField,
      InputField(label: 'Focus Topic', hintLabel: 'Enter focus of the lesson'),
      InputField(label: 'Timeframe', hintLabel: 'Enter timeframe'),
      TextArea(
          label: 'Learning Outcomes', hintLabel: 'Enter learning outcomes'),
      Dropdown(
        label: 'Grade Level',
        list: const <String>[
          'Elementary',
          'Junior High School',
          'Senior High School',
          'College',
        ],
        stateNotifier: DropdownStateNotifier(),
      ),
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

  final InputField titleField =
      InputField(label: 'Title', hintLabel: 'Enter lesson title');

  final lessonSpecsModel = LessonSpecificationModel();
  final LessonSpecificationsConnectionOrchestrator
      _lessonSpecificationsConnectionOrchestrator =
      LessonSpecificationsConnectionOrchestrator();
  final _formFields = <FormField>[];
  List<FormField> get formFields => _formFields;

  final _lessonSpecifications = <String>[];
  List<String> get lessonSpecifications => _lessonSpecifications;

  var _targetPath = SettingsPreferences.getDirectory();
  String? get targetPath => _targetPath;

  final TextEditingController _saveTargetController =
      TextEditingController(text: SettingsPreferences.getDirectory());
  TextEditingController get saveTargetController => _saveTargetController;

  final _statusCode = 0;

  void sendData() {
    _lessonSpecificationsConnectionOrchestrator.sendData(
        _lessonSpecifications, _statusCode);
  }

  void getData() {
    _lessonSpecificationsConnectionOrchestrator.getData();
  }

  void collectFormTextValues() {
    lessonSpecsModel.lessonSpecs.clear();

    for (var formField in formFields) {
      if (formField.inputField != null) {
        lessonSpecsModel.lessonSpecs.add(LessonSpecification(
            formField.inputField!.label,
            formField.inputField!.controller.text));
      } else if (formField.textArea != null) {
        lessonSpecsModel.lessonSpecs.add(LessonSpecification(
            formField.textArea!.label, formField.textArea!.controller.text));
      } else if (formField.dropdown != null) {
        lessonSpecsModel.lessonSpecs.add(LessonSpecification(
            formField.dropdown!.label,
            formField.dropdown!.stateNotifier.selectedValue));
      } else {
        developer.log('Null error', name: 'generate-lesson');
        // TODO: Handle uninitialized null values, just in case.
      }
    }

    buildLessonSpecificationsMessage();

    notifyListeners();

    developer.log(_lessonSpecifications.toString(), name: 'collect');
  }

  void buildLessonSpecificationsMessage() {
    _lessonSpecifications.clear();

    for (var specification in lessonSpecsModel.lessonSpecs) {
      _lessonSpecifications
          .add("${specification.label} - ${specification.content}");
    }
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
    Navigator.restorablePushNamed(context, UploadSourcesView.routeName);
  }

  void navigateToLessonGeneration(BuildContext context) {
    Navigator.restorablePushNamed(context, LessonResultView.routeName);
  }

  void selectLessonSavePath(
      BuildContext context, TextEditingController controller) async {
    final String? directoryPath = await getDirectoryPath();

    if (directoryPath == null) {
      // Operation was canceled by the user.
      return;
    } else {
      controller.text = directoryPath;
      _targetPath = directoryPath;
    }
  }

  // This will check if there are no same title in the existing items
  bool checkTitleAvailability(MenuViewModel menu) {
    var titleFieldValue = titleField.controller.text;

    List<LessonModel> lessons = [];
    List<QuizModel> quizzes = [];
    lessons = menu.menuModel.lessons;
    quizzes = menu.menuModel.quizzes;

    for (LessonModel lesson in lessons) {
      String tempTitle = '';
      tempTitle = lesson.title;
      if (tempTitle == titleFieldValue) {
        return false;
      }
    }
    for (QuizModel quiz in quizzes) {
      if (quiz.title == titleFieldValue) {
        return false;
      }
    }

    return true;
  }
}
