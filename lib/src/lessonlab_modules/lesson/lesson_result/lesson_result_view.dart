import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/components/lesson_result_screen.dart';
import 'package:provider/provider.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_view_model.dart';

import 'dart:developer' as developer;

class LessonResultView extends StatelessWidget {
  const LessonResultView({Key? key}) : super(key: key);

  static const routeName = '/lesson_result';

  @override
  Widget build(BuildContext context) {
    final lessonResultViewModel = context.watch<LessonResultViewModel>();
    final menuViewModel = context.watch<MenuViewModel>();
    // final lessonSpecificationsViewModel =
    //     context.watch<LessonSpecificationsViewModel>();

    var export = FutureBuilder<String>(
        future: lessonResultViewModel.lessonResultModel.lesson.title,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return PrimaryButton(
              handlePress: () {
                debugPrint("Title not yet loaded");
              },
              text: 'Save and Export Lesson',
              enabled: lessonResultViewModel.done,
            );
          } else if (snapshot.hasError) {
            return PrimaryButton(
              handlePress: () {
                debugPrint("Error loading lesson title");
              },
              text: 'Save and Export Lesson',
              enabled: lessonResultViewModel.done,
            );
          } else {
            final String lessonTitle = snapshot.data!;

            return PrimaryButton(
              handlePress: () {
                if (lessonResultViewModel.done) {
                  lessonResultViewModel.exportLesson(lessonTitle);
                }
              },
              text: 'Save and Export Lesson',
              enabled: lessonResultViewModel.done,
            );
          }
        });

    var finish = PrimaryButton(
      handlePress: () {
        debugPrint("Finished");
        debugPrint(lessonResultViewModel.done.toString());
        if (lessonResultViewModel.done) {
          debugPrint("Return");
          lessonResultViewModel.returnToMenu(context, menuViewModel);
        }
      },
      text: 'Save and Finish',
      enabled: lessonResultViewModel.done,
    );

    return Scaffold(
      body: const LessonResultScreen(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 30.0, 180.0, 60.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            export,
            const SizedBox(width: 30.0),
            finish,
          ],
        ),
      ),
    );
  }
}
