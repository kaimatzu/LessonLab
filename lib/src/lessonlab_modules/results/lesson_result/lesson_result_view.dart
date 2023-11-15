import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lessonlab/src/lessonlab_modules/results/lesson_result/components/text_editor.dart';
import 'package:lessonlab/src/lessonlab_modules/results/lesson_result/lesson_result_view_model.dart';
import 'dart:developer' as developer;

Future<String> loadFileContents(String filePath) async {
  return await rootBundle.loadString(filePath);
}

class LessonResultView extends StatefulWidget {
  const LessonResultView({Key? key}) : super(key: key);

  static const routeName = '/lesson_result';

  @override
  State<LessonResultView> createState() => _LessonResultView();
}

class _LessonResultView extends State<LessonResultView> {
  late Future<String> mdContents;
  late Future<String> cssContent;

  @override
  void initState() {
    super.initState();
    mdContents = loadFileContents('assets/test.md');
    cssContent = loadFileContents('assets/styles/markdown.css');
  }

  @override
  Widget build(BuildContext context) {
    final lessonResultViewModel = context.watch<LessonResultViewModel>;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(90.0, 45.0, 45.0, 45.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Lesson',
                    style:
                        TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(120.0, 0.0, 120.0, 30.0),
              child: FutureBuilder<List<String>>(
                future: Future.wait([mdContents, cssContent]), // Pass in css as well
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text('Error loading lesson content');
                  } else {
                    final List<String> contents = snapshot.data!;
                    final String mdContent = contents[0];
                    final String cssContent = contents[1];

                    // developer.log(cssContent, name: 'info');
                    return TextEditor(
                      title: 'Title',
                      mdContents: mdContent,
                      cssContents: cssContent
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 30.0, 180.0, 60.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {

              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150.0, 50.0), 
              ),
              child: const Text('Regenerate'),
            ),
            const SizedBox(width: 30.0),
            ElevatedButton(
              onPressed: () { 
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150.0, 50.0),
              ),
              child: const Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }
}
