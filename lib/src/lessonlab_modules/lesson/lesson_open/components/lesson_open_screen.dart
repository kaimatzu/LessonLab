import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/components/text_editor.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/components/title_bar.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_view_model.dart';
import 'package:provider/provider.dart';

class LessonOpenScreen extends StatelessWidget {
  const LessonOpenScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lessonOpenViewModel = context.watch<LessonOpenViewModel>();

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
    var textEditorContainer = FutureBuilder<List<String>>(
      // The data sent from rust
      future: Future.wait(
        [
          Future.value(lessonOpenViewModel.lessonOpenModel.lesson.title),
          Future.value(lessonOpenViewModel.lessonOpenModel.lesson.content),
          lessonOpenViewModel.lessonOpenModel.cssContents,
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
          final String mdContent = contents[1];
          debugPrint("Titlexz: $title");
          debugPrint("Contentsx: $mdContent");
          // developer.log(cssContent, name: 'info');
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              header,
              Padding(
                padding: const EdgeInsets.only(left: 20.0, right: 20.0),
                child: TitleBar(title: title),
              ),
              Padding(
                padding: const EdgeInsets.only(
                    left: 20.0, right: 20.0, bottom: 20.0),
                child: TextEditor(contents: mdContent),
              )
            ],
          );
        }
      },
    );

    return SingleChildScrollView(child: textEditorContainer);
  }
}

// return TextEditor(
//                       title: title,
//                       mdContents: message,
//                       cssContents: cssContent);
