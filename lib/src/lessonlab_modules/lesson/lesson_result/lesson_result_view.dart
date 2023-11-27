import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/components/lesson_result_screen.dart';
import 'package:provider/provider.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/components/text_editor.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_view_model.dart';

class LessonResultView extends StatelessWidget {
  const LessonResultView({Key? key}) : super(key: key);

  static const routeName = '/lesson_result';

  @override
  Widget build(BuildContext context) {
    final lessonResultViewModel = context.watch<LessonResultViewModel>();

    return Scaffold(
      body: LessonResultScreen(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 30.0, 180.0, 60.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          // TODO: add functionality to buttons
          children: [
            PrimaryButton(
              handlePress: () {
                // if generation done then enable regenerate
              },
              text: 'Regenerate',
              enabled: true,
            ),
            const SizedBox(width: 30.0),
            PrimaryButton(
              handlePress: () {},
              text: 'Finish',
              enabled: true,
            ),
          ],
        ),
      ),
    );
  }
}
