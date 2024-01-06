import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/lesson_specifications_view_model.dart';
import 'package:provider/provider.dart';

class LessonSpecificationsView extends StatelessWidget {
  const LessonSpecificationsView({
    Key? key,
  }) : super(key: key);

  static const routeName = '/specifications';

  @override
  Widget build(BuildContext context) {
    final lessonSpecificationsViewModel =
        context.watch<LessonSpecificationsViewModel>();

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
                            width: 200,
                            height: 50,
                            child: TextField(
                              controller: lessonSpecificationsViewModel
                                  .saveTargetController,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                filled: true,
                                fillColor: Color.fromARGB(255, 49, 51, 56),
                                border: OutlineInputBorder(),
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
                                      lessonSpecificationsViewModel
                                          .collectFormTextValues();
                                      lessonSpecificationsViewModel.sendData();
                                      lessonSpecificationsViewModel.getData();
                                      lessonSpecificationsViewModel
                                          .navigateToLessonGeneration(context);
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
}
