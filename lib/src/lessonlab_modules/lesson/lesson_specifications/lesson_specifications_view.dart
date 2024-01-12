import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
import 'package:lessonlab/src/global_models/lesson_model.dart';
import 'package:lessonlab/src/global_models/quiz_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/components/input_field.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/lesson_specifications_view_model.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as developer;

class LessonSpecificationsView extends StatelessWidget {
  const LessonSpecificationsView({
    Key? key,
  }) : super(key: key);

  static const routeName = '/specifications';

  @override
  Widget build(BuildContext context) {
    final lessonSpecificationsViewModel =
        context.watch<LessonSpecificationsViewModel>();
    final menuViewModel = context.watch<MenuViewModel>();

    return Scaffold(
      appBar: const LessonLabAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 20.0, 30.0, 0.0),
        child: Row(
          children: [
            // Left side (scrollable form)
            Expanded(
              child: Container(
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20.0),
                    topRight: Radius.circular(20.0),
                  ),
                  color: Color.fromARGB(255, 244, 245, 247),
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(40.0, 32.0, 30.0, 32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ...lessonSpecificationsViewModel.formFields
                            .map<Widget?>((formField) {
                              if (formField.inputField != null) {
                                return formField.inputField;
                              } else if (formField.textArea != null) {
                                return formField.textArea;
                              } else if (formField.dropdown != null) {
                                return formField.dropdown;
                              } else {
                                developer.log("lesson spec has null");
                                return null;
                              }
                            })
                            .whereType<Widget>()
                            .toList(),
                        const SizedBox(height: 8.0),
                        PrimaryButton(
                          handlePress: () {
                            lessonSpecificationsViewModel
                                .addCustomSpecifications();
                          },
                          text: 'Add Custom',
                          enabled: true,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            // Right side (static buttons)
            Padding(
              padding: const EdgeInsets.fromLTRB(0.0, 170.0, 0.0, 30.0),
              child: SizedBox(
                width: 420,
                child: Align(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const SizedBox(width: 50.0),
                          PrimaryButton(
                            handlePress: () async {
                              lessonSpecificationsViewModel
                                  .selectLessonSavePath(
                                context,
                                lessonSpecificationsViewModel
                                    .saveTargetController,
                              );
                            },
                            text: 'Save Path',
                            enabled: true,
                            width: 100.0,
                            topRightRadius: 0.0,
                            bottomRightRadius: 0.0,
                          ),
                          const SizedBox(width: 2.0),
                          SizedBox(
                            width: 240,
                            height: 50,
                            child: TextField(
                              controller: lessonSpecificationsViewModel
                                  .saveTargetController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(255, 49, 51, 56),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.only(
                                    topRight: Radius.circular(15.0),
                                    bottomRight: Radius.circular(15.0),
                                  ),
                                ),
                                hintText: 'No save directory',
                                hintStyle: TextStyle(
                                  fontFamily: 'Roboto, Inter, Arial',
                                  color: Colors.grey,
                                ),
                              ),
                              enabled: false,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20.0),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SecondaryButton(
                                  handlePress: () {
                                    lessonSpecificationsViewModel
                                        .cancelLesson(context);
                                  },
                                  text: 'Cancel',
                                  width: 120.0,
                                ),
                                const SizedBox(width: 8.0),
                                PrimaryButton(
                                    handlePress: () {
                                      // check first if there are same title
                                      if (checkTitleAvailability(menuViewModel,
                                          lessonSpecificationsViewModel)) {
                                        lessonSpecificationsViewModel
                                            .collectFormTextValues();
                                        lessonSpecificationsViewModel
                                            .sendData();
                                        lessonSpecificationsViewModel.getData();
                                        lessonSpecificationsViewModel
                                            .navigateToLessonGeneration(
                                                context);
                                      }
                                    },
                                    text: 'Generate',
                                    enabled: true,
                                    width: 120.0),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // This will check if there are no same title in the existing items
  bool checkTitleAvailability(
      MenuViewModel menu, LessonSpecificationsViewModel lessonSpecifications) {
    var titleFieldValue = lessonSpecifications.titleField.controller.text;

    // menu.menuModel.lessons.then((value) {
    //   for (LessonModel lesson in value) {
    //     lesson.title.then((value) {
    //       if (value == titleFieldValue) {
    //         return false;
    //       }
    //     });
    //   }
    // });

    List<LessonModel> lessons = [];
    List<QuizModel> quizzes = [];
    // menu.menuModel.lessons.then((value) {
    //   developer.log("length: ${value.length}");
    //   developer.log("id: ${value[0].id}");
    //   developer.log("title: ${value[0].title}");
    // });
    // menu.menuModel.lessons.then((value) => lessons = value);
    // menu.menuModel.quizzes.then((value) => quizzes = value);
    lessons = menu.menuModel.lessons;
    quizzes = menu.menuModel.quizzes;

    for (LessonModel lesson in lessons) {
      String tempTitle = '';
      // lesson.title.then((value) => tempTitle = value);
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
