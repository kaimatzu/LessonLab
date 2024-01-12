import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/components/lesson_open_screen.dart';
import 'package:provider/provider.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_view_model.dart';

class LessonOpenView extends StatelessWidget {
  const LessonOpenView({Key? key}) : super(key: key);

  static const routeName = '/lesson_open';

  @override
  Widget build(BuildContext context) {
    final int? id = ModalRoute.of(context)!.settings.arguments as int?;

    final lessonOpenViewModel = context.watch<LessonOpenViewModel>();
    final menuViewModel = context.watch<MenuViewModel>();

    if (id != null) {
      debugPrint("Here");
      lessonOpenViewModel.loadViewContent(id);
    }
    // final lessonSpecificationsViewModel =
    //     context.watch<LessonSpecificationsViewModel>();

    var export = FutureBuilder<String>(
        future: Future.value(lessonOpenViewModel.lessonOpenModel.lesson.title),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return PrimaryButton(
              width: 150.0,
              handlePress: () {
                debugPrint("Title not yet loaded");
              },
              text: 'Save and Export',
              enabled: lessonOpenViewModel.done,
            );
          } else if (snapshot.hasError) {
            return PrimaryButton(
              width: 150.0,
              handlePress: () {
                debugPrint("Error loading lesson title");
              },
              text: 'Save and Export',
              enabled: lessonOpenViewModel.done,
            );
          } else {
            final String lessonTitle = snapshot.data!;

            return PrimaryButton(
              width: 150.0,
              handlePress: () {
                if (lessonOpenViewModel.done) {
                  lessonOpenViewModel.exportLesson(lessonTitle);
                }
              },
              text: 'Save and Export',
              enabled: lessonOpenViewModel.done,
            );
          }
        });

    var finish = PrimaryButton(
      width: 150.0,
      handlePress: () {
        if (lessonOpenViewModel.done) {
          menuViewModel.loadViewContent();
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
          children: [
            back,
            const SizedBox(width: 30.0),
            export,
            const SizedBox(width: 30.0),
            finish,
          ],
        ),
      ),
    );
  }
}
