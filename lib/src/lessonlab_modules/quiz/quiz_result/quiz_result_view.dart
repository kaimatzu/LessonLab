import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/components/answer.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_result/quiz_result_view_model.dart';
import 'package:provider/provider.dart';

class QuizResultView extends StatelessWidget {
  const QuizResultView({super.key});

  static const routeName = '/quiz_result';

  @override
  Widget build(BuildContext context) {
    final quizResultViewModel = context.watch<QuizResultViewModel>();
    return const Align(
      alignment: Alignment.center,
      child: const Text("FLUTTER GAY"),
    );
  }
}
