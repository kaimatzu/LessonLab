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
      width: 150.0,
      handlePress: () {
        if (lessonResultViewModel.done) {
          // run loadViewContent() function to regenerate
          lessonResultViewModel.loadViewContent();
        }
      },
      text: 'Save and Export',
      enabled: lessonResultViewModel.done,
    );

    var finish = PrimaryButton(
      width: 150.0,
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
        padding: const EdgeInsets.only(top: 20.0, right: 35.0, bottom: 35.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          // TODO: add functionality to buttons
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
