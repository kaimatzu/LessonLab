import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/components/text_editor.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_view_model.dart';
import 'package:provider/provider.dart';
import 'package:rinf/rinf.dart';
import 'package:lessonlab/messages/results/view_lesson_result/load_lesson.pb.dart'
    as streamMessage;

class LessonResultScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final lessonResultViewModel = context.watch<LessonResultViewModel>();
    
    return SingleChildScrollView(
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
                  style: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(120.0, 0.0, 120.0, 30.0),
            child: FutureBuilder<List<String>>(
              future: Future.wait(
                [
                  lessonResultViewModel.lessonResultModel.lesson.title,
                  lessonResultViewModel.lessonResultModel.lesson.content,
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
                  final String mdContent = contents[1];
                  final String cssContent = contents[2];

                  // developer.log(cssContent, name: 'info');
                  return TextEditor(
                      title: title,
                      mdContents: "",
                      cssContents: cssContent);
                }
              },
            ),
          ),
          // Padding(
          //   padding: const EdgeInsets.fromLTRB(120.0, 0.0, 120.0, 30.0),
          //   child: StreamBuilder<RustSignal>(
          //     stream: rustBroadcaster.stream.where((rustSignal) {
          //       return rustSignal.resource == streamMessage.ID;
          //     }),
          //     builder: (context, snapshot) {
          //       final rustSignal = snapshot.data;
          //       if (rustSignal == null) {
          //         return Text("Nothing received yet");
          //       } else {
          //         final signal = streamMessage.StateSignal.fromBuffer(
          //           rustSignal.message!,
          //         );
          //         final rinfMessage = signal.streamMessage;
          //         message += rinfMessage;
          //         return Text(message);
          //       }
          //     },
          //   ),
          // )
        ],
      ),
    );
  }
}

// return TextEditor(
//                       title: title,
//                       mdContents: message,
//                       cssContents: cssContent);