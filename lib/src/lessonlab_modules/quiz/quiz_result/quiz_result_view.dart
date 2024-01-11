import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view_model.dart';
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
    final List<Map<String, dynamic>> quizResult = quizResultViewModel.results;
    int totalCorrectAnswers =
        quizResult.where((result) => result['isCorrect'] == true).length;

    var paddingBetweenButtons = const SizedBox(height: 5.0);

    print('Results: $quizResult');

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const LessonLabAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20.0, 0.0, 20.0, 30.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Container(
            margin:
                EdgeInsets.only(left: (screenWidth / 2) - (screenWidth / 5)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left
                Row(
                  children: [
                    Padding(
                      padding:
                          const EdgeInsets.fromLTRB(20.0, 20.0, 20.0, 20.0),
                      child: Container(
                          width: 200,
                          height: 200,
                          padding: const EdgeInsets.only(top: 30.0),
                          child: Column(
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
                                        '$totalCorrectAnswers',
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
                                      '${quizResult.length}',
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
                      padding:
                          const EdgeInsets.fromLTRB(40.0, 20.0, 20.0, 20.0),
                      child: Container(
                          width: 300,
                          height: 250,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Percentage: ${((totalCorrectAnswers / quizResult.length) * 100).toStringAsFixed(2)}%',
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
                                        Navigator.restorablePushNamed(
                                            context, MenuView.routeName);
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
                Container(
                  margin: EdgeInsets.only(left: (screenWidth / 10)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (int i = 0; i < quizResult.length; i++)
                        _buildResultItem(quizResult[i], i),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultItem(Map<String, dynamic> result, int index) {
    String userAnswerText = '';
    String correctAnswerText = '';

    if (result['type'] == 1) {
      // Identification question
      userAnswerText = result['userAnswer'] ?? 'No Answer';
      correctAnswerText =
          (result['correctAnswer'] != null) ? result['correctAnswer'] : '';
    } else if (result['type'] == 2) {
      // Multiple choice question
      List<Map<String, dynamic>> choices = result['choices'];

      userAnswerText =
          (result['userAnswer'] != null && result['userAnswer']['index'] >= 0)
              ? choices[result['userAnswer']['index']]['content']
              : 'No Answer';
      correctAnswerText = choices[result['correctAnswerIndex']]['content'];
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${index + 1}: ${result['question']}',
            style: TextStyle(
              fontSize: 16.0,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (result['type'] == 2) // Check if it's a multiple-choice question
            _buildMultipleChoiceResult(result),
          if (result['type'] == 1)
            Text(
              'Your Answer: $userAnswerText',
              style: TextStyle(
                fontSize: 14.0,
              ),
            ),
          Text(
            'Correct Answer: $correctAnswerText',
            style: TextStyle(
              fontSize: 14.0,
              color: result['isCorrect']
                  ? Colors.green
                  : Colors.red, // You can customize the color
            ),
          ),
          Text(
            '${result['isCorrect'] ? 'Correct' : 'Incorrect'}',
            style: TextStyle(
              fontSize: 14.0,
              color: result['isCorrect'] ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleChoiceResult(Map<String, dynamic> result) {
    List<Map<String, dynamic>> choices = result['choices'];
    int correctAnswerIndex = result['correctAnswerIndex'];

    int? selectedChoiceIndex = result['userAnswer']?['index'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < choices.length; i++)
          Row(
            children: [
              Radio(
                value: i,
                groupValue: selectedChoiceIndex,
                onChanged: (value) {},
              ),
              Text(
                choices[i]['content'] ?? '',
                style: TextStyle(
                  color: (i == correctAnswerIndex && i == selectedChoiceIndex)
                      ? Colors.green
                      : (i == selectedChoiceIndex)
                          ? Colors.red
                          : null,
                ),
              ),
            ],
          ),
      ],
    );
  }
}
