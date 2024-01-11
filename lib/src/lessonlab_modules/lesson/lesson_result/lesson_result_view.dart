import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/components/lesson_result_screen.dart';
import 'package:provider/provider.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_view_model.dart';

class LessonResultView extends StatelessWidget {
  const LessonResultView({Key? key}) : super(key: key);

  static const routeName = '/lesson_result';

  @override
  Widget build(BuildContext context) {
    final lessonResultViewModel = context.watch<LessonResultViewModel>();
    // final lessonSpecificationsViewModel =
    //     context.watch<LessonSpecificationsViewModel>();

    var regenerate = PrimaryButton(
      handlePress: () {
        if (lessonResultViewModel.done) {
          // run loadViewContent() function to regenerate
          lessonResultViewModel.loadViewContent();
        }
      },
      text: 'Save and Export Lesson',
      enabled: lessonResultViewModel.done,
    );

    var finish = PrimaryButton(
      handlePress: () {
        if (lessonResultViewModel.done) {
          lessonResultViewModel.returnToMenu(context);
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
            regenerate,
            const SizedBox(width: 30.0),
            finish,
          ],
        ),
      ),
    );
  }
}
