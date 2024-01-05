import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
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

    var paddingBetweenButtons = const SizedBox(height: 5.0);

    return Scaffold(
      appBar: const LessonLabAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 30.0),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Left
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                child: Container(
                    width: 200,
                    height: 200,
                    padding: const EdgeInsets.only(top: 30.0),
                    child: const Column(
                      children: [
                        Text(
                          'Your Score:',
                          style: TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        Expanded(
                          child: Stack(children: [
                            Positioned(
                                top: 10.0,
                                right: 100.0,
                                child: Text(
                                  // User's Score
                                  '8',
                                  style: TextStyle(fontSize: 60),
                                )),
                            Align(
                                alignment: Alignment.center,
                                child: Text(
                                  '/',
                                  style: TextStyle(
                                    fontSize: 70,
                                    fontWeight: FontWeight.w100,
                                    fontStyle: FontStyle.italic,
                                  ),
                                )),
                            Positioned(
                              bottom: 10.0,
                              left: 100.0,
                              child: Text(
                                // Total Score
                                '10',
                                style: TextStyle(fontSize: 60),
                              ),
                            ),
                          ]),
                        ),
                      ],
                    )),
              ),
              // Line
              Container(
                width: 1,
                height: 250,
                color: Color.fromARGB(255, 126, 126, 126),
              ),
              // Right
              Padding(
                padding: const EdgeInsets.fromLTRB(40.0, 20.0, 20.0, 20.0),
                child: Container(
                    width: 300,
                    height: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Percentage: 80%',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Color.fromRGBO(49, 51, 56, 1),
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          'Time: 5m 23s',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Color.fromRGBO(49, 51, 56, 1),
                              fontWeight: FontWeight.w500),
                        ),
                        const Spacer(),
                        Column(
                          children: [
                            paddingBetweenButtons,
                            PrimaryButton(
                                handlePress: () {
                                  // handle
                                },
                                text: 'Save and Export Quiz',
                                enabled: true,
                                width: 180.0),
                            paddingBetweenButtons,
                            SecondaryButton(
                                handlePress: () {
                                  // handle
                                },
                                text: 'Back to Dashboard',
                                width: 180.0),
                          ],
                        )
                      ],
                    )),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
