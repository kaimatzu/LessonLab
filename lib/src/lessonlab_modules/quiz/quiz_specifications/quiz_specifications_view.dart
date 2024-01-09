import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_specifications/quiz_specifications_view_model.dart';
// import 'package:lessonlab/src/lessonlab_modules/results/lesson_result/lesson_result_view.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as developer;

class QuizSpecificationsView extends StatelessWidget {
  const QuizSpecificationsView({
    Key? key,
  }) : super(key: key);

  static const routeName = '/quiz_specifications';

  @override
  Widget build(BuildContext context) {
    final quizSpecificationsViewModel =
        context.watch<QuizSpecificationsViewModel>();
    final quizPageViewModel = context.watch<QuizPageViewModel>();

    return Scaffold(
      appBar: const LessonLabAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(180.0, 32.0, 180.0, 32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: quizSpecificationsViewModel.formFields
                .map<Widget?>((formField) {
                  if (formField.inputField != null) {
                    return formField.inputField;
                  } else if (formField.textArea != null) {
                    return formField.textArea;
                  } else if (formField.dropdown != null) {
                    return formField.dropdown;
                  } else if (formField.numberField != null) {
                    return formField.numberField;
                  } else {
                    return null;
                  }
                })
                .whereType<Widget>() // Filter out null values
                .toList(),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 30.0, 180.0, 60.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SecondaryButton(
              handlePress: () {
                quizSpecificationsViewModel.cancelQuiz(context);
              },
              text: 'Cancel',
            ),
            // const SizedBox(width: 30.0),
            // PrimaryButton(
            //   handlePress: () {
            //     lessonSpecificationsViewModel.addCustomSpecifications();
            //   },
            //   text: 'Add',
            //   enabled: true,
            // ),
            const SizedBox(width: 30.0),
            PrimaryButton(
              handlePress: () {
                //quizSpecificationsViewModel.collectFormTextValues();
                quizPageViewModel.loadQuizModel();
                developer.log("quiz model loaded");
                quizSpecificationsViewModel.generateQuiz(
                    context, quizPageViewModel);
                // lessonSpecificationsViewModel.sendData();
                // lessonSpecificationsViewModel.getData();
              },
              text: 'Generate',
              enabled: true,
            ),
          ],
        ),
      ),
    );
  }
}
