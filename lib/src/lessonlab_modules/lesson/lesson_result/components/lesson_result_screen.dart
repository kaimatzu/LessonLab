import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/components/text_editor.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/components/title_bar.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_view_model.dart';
import 'package:provider/provider.dart';

class LessonResultScreen extends StatelessWidget {
  const LessonResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lessonResultViewModel = context.watch<LessonResultViewModel>();

    // This is the "Lesson" text at the top left of the screen
    const header = Padding(
      padding: EdgeInsets.fromLTRB(100.0, 30.0, 45.0, 30.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lesson',
            style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );

    // This is the div for holding the title bar and the text box
    var textEditorContainer = Padding(
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: FutureBuilder<List<String>>(
        // The data sent from rust
        future: Future.wait(
          [
            Future.value(lessonResultViewModel.lessonResultModel.lesson.title),
            Future.value(
                lessonResultViewModel.lessonResultModel.lesson.content),
            lessonResultViewModel.lessonResultModel.cssContents,
          ],
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          } else if (snapshot.hasError) {
            return const Text('Error loading lesson content');
          } else {
            final List<String> contents = snapshot.data!;
            final String title = contents[0];

            // developer.log(cssContent, name: 'info');
            return TitleBar(title: title);
          }
        },
      ),
    );

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          header,
          textEditorContainer,
          Padding(
            padding: const EdgeInsets.only(left: 20.0, right: 20.0),
            child: TextEditor(),
          )
        ],
      ),
    );
  }
}
