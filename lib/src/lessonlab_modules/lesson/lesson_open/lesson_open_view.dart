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
    if(id != null) {
      debugPrint("Here");
      lessonOpenViewModel.loadViewContent(id);
    }
    // final lessonSpecificationsViewModel =
    //     context.watch<LessonSpecificationsViewModel>();

    var export = FutureBuilder<String>(
      future: lessonOpenViewModel.lessonOpenModel.lesson.title,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return PrimaryButton(
            handlePress: () {
              debugPrint("Title not yet loaded");
            },
            text: 'Save and Export Lesson',
            enabled: lessonOpenViewModel.done,
          );
        } else if (snapshot.hasError) {
          return PrimaryButton(
            handlePress: () {
              debugPrint("Error loading lesson title");
            },
            text: 'Save and Export Lesson',
            enabled: lessonOpenViewModel.done,
          );
        } else {
          final String lessonTitle = snapshot.data!;

          return PrimaryButton(
            handlePress: () {
              if (lessonOpenViewModel.done) {
                lessonOpenViewModel.exportLesson(lessonTitle);
              }
            },
            text: 'Save and Export Lesson',
            enabled: lessonOpenViewModel.done,
          );
        }
      }
    );

    var finish = PrimaryButton(
      handlePress: () {
        if (lessonOpenViewModel.done) {
          lessonOpenViewModel.returnToMenu(context);
        }
      },
      text: 'Save and Finish',
      enabled: lessonOpenViewModel.done,
    );

    return Scaffold(
      body: const LessonOpenScreen(),
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
