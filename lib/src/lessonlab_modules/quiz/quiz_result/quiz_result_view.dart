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

class QuizResultView extends StatefulWidget {
  const QuizResultView({super.key});

  static const routeName = '/quiz_result';

  @override
  State<QuizResultView> createState() => _QuizResultViewState();
}

class _QuizResultViewState extends State<QuizResultView> {
  bool isResultVisible = false;

  @override
  Widget build(BuildContext context) {
    final quizResultViewModel = context.watch<QuizResultViewModel>();
    final List<Map<String, dynamic>> quizResult = quizResultViewModel.results;

    int totalCorrectAnswers =
        quizResult.where((result) => result['isCorrect'] == true).length;

    var paddingBetweenButtons = const SizedBox(height: 5.0);

    //print('Results: $quizResult');

    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: const LessonLabAppBar(),
      body: Center(
        child: Padding(
          //padding: const EdgeInsets.fromLTRB(200.0, 0.0, 20.0, 30.0),
          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.275),
          child: SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Left
                    Center(
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                20.0, 20.0, 20.0, 20.0),
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
                          SizedBox(
                            height: 20.0,
                          ),
                          // Right
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                                40.0, 20.0, 20.0, 20.0),
                            child: Container(
                                height: 250,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Quiz Title',
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          color: Color.fromRGBO(49, 51, 56, 1),
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 20.0,
                                    ),
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
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: 150.0, top: 20.0, bottom: 20.0),
                  child: PrimaryButton(
                    handlePress: () {
                      setState(() {
                        isResultVisible = !isResultVisible;
                      });
                    },
                    text: isResultVisible ? 'Hide Result' : 'Show Result',
                    enabled: true,
                    width: 180.0,
                  ),
                ),
                if (isResultVisible)
                  Container(
                    // margin:
                    //     EdgeInsets.only(left: (screenWidth / 10), bottom: 20.0),
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
      height: 200.0,
      decoration: BoxDecoration(
          color: result['isCorrect']
              ? Color.fromARGB(255, 223, 255, 219)
              : Color.fromARGB(255, 255, 219, 219),
          borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.only(bottom: 20.0, right: 40.0),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${result['question']}',
              style: TextStyle(
                color: Color.fromARGB(255, 49, 51, 56),
                fontSize: 18.0,
              ),
            ),
            if (result['type'] == 2) _buildMultipleChoiceResult(result),
            if (result['type'] == 1)
              Container(
                margin: EdgeInsets.only(top: 20.0),
                child: Row(
                  children: [
                    Text(
                      'Your Answer: ',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color.fromARGB(255, 49, 51, 56),
                      ),
                    ),
                    Text(
                      '$userAnswerText',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Color.fromARGB(255, 49, 51, 56),
                      ),
                    ),
                    if (result['isCorrect'])
                      Text(
                        '  ✔',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.green,
                        ),
                      ),
                    if (result['userAnswer'] == '')
                      Text(
                        '  N/A',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Color.fromARGB(255, 49, 51, 56),
                        ),
                      ),
                    if (!result['isCorrect'] && result['userAnswer'] != '')
                      Text(
                        '  ❌',
                        style: TextStyle(
                          fontSize: 16.0,
                          color: Colors.red,
                        ),
                      ),
                  ],
                ),
              ),
            Container(
              margin: EdgeInsets.only(top: 25.0),
              child: Text(
                'Correct Answer: $correctAnswerText',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 49, 51, 56),
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
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
              Row(
                children: [
                  Text(
                    choices[i]['content'] ?? '',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color.fromARGB(255, 49, 51, 56),
                    ),
                  ),
                  if (i == correctAnswerIndex && i == selectedChoiceIndex)
                    Text(
                      '  ✔',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.green,
                      ),
                    ),
                  if (i == selectedChoiceIndex && i != correctAnswerIndex)
                    Text(
                      '  ❌',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
