import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/components/lesson_open_screen.dart';
import 'package:provider/provider.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_view_model.dart';

class LessonOpenView extends StatelessWidget {
  const LessonOpenView({Key? key}) : super(key: key);

  static const routeName = '/lesson_open';

  @override
  Widget build(BuildContext context) {
    final int? id = ModalRoute.of(context)!.settings.arguments as int?;

    final lessonOpenViewModel = context.watch<LessonOpenViewModel>();
    if (id != null) {
      debugPrint("Here");
      lessonOpenViewModel.loadViewContent(id);
    }
    // final lessonSpecificationsViewModel =
    //     context.watch<LessonSpecificationsViewModel>();

    var regenerate = PrimaryButton(
      width: 150.0,
      handlePress: () {
        if (lessonOpenViewModel.done) {
          // lessonOpenViewModel.regenerate();
          // lessonOpenViewModel.loadViewContent();
        }
      },
      text: 'Save and Export',
      enabled: lessonOpenViewModel.done,
    );

    var finish = PrimaryButton(
      width: 150.0,
      handlePress: () {
        if (lessonOpenViewModel.done) {
          lessonOpenViewModel.returnToMenu(context);
        }
      },
      text: 'Save and Finish',
      enabled: lessonOpenViewModel.done,
    );

    var back = PrimaryButton(
      width: 150.0,
      handlePress: () {
        Navigator.pop(context);
      },
      text: 'Back',
      enabled: true,
    );

    return Scaffold(
      body: const LessonOpenScreen(),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(top: 20.0, right: 35.0, bottom: 35.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          // TODO: add functionality to buttons
          children: [
            back,
            const SizedBox(width: 30.0),
            regenerate,
            const SizedBox(width: 30.0),
            finish,
          ],
        ),
      ),
    );
  }
}
