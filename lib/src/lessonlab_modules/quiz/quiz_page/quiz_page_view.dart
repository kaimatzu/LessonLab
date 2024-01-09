import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/global_models/choice_model.dart';
import 'package:lessonlab/src/global_models/question_model.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/components/answer.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_view_model.dart';
import 'package:provider/provider.dart';

import 'dart:developer' as developer;

class QuizPageView extends StatefulWidget {
  const QuizPageView({
    Key? key,
  }) : super(key: key);

  static const routeName = '/quiz_page';

  @override
  State<QuizPageView> createState() => _QuizPageViewState();
}

// TODO: MAKE IDENTIFICATION TYPE QUIZ

// THIS IS MULTIPLE CHOICE QUIZ
class _QuizPageViewState extends State<QuizPageView> {
  int _questionIndex = 0;

  int _totalItems = 0;
  int _currentItem = 0;

  List<bool?> _selectedAnswers = List.filled(10, null);

  @override
  Widget build(BuildContext context) {
    final quizViewModel = context.watch<QuizPageViewModel>();
    _totalItems = quizViewModel.questions.length;

    developer.log("questions.length: ${quizViewModel.questions.length}",
        name: "build");

    return Scaffold(
        appBar: const LessonLabAppBar(),
        body: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: const EdgeInsets.only(left: 10.0, bottom: 20.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: const EdgeInsets.only(
                        left: 50.0, top: 20.0, right: 20.0),
                    height: 200.0,
                    width: 150,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 253, 237, 183),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Container(
                      margin: const EdgeInsets.only(top: 20.0),
                      child: Text('Question ${_questionIndex + 1}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15.0,
                            fontWeight: FontWeight.bold,
                            color: Color.fromARGB(255, 49, 51, 56),
                          )),
                    )),
                Expanded(
                    child: Padding(
                        padding: const EdgeInsets.only(top: 20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildQuestionWidget(
                              quizViewModel.questions[_questionIndex]!,
                              // questionsMap[_questionIndex],
                              _questionIndex + 1,
                              _questionIndex,
                            ),
                            const SizedBox(
                              height: 20.0,
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 0.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  PrimaryButton(
                                      handlePress: () {
                                        _prevQuestion();
                                      },
                                      text: 'prev',
                                      enabled: true),
                                  const SizedBox(
                                    width: 20.0,
                                  ),
                                  PrimaryButton(
                                      handlePress: () {
                                        _nextQuestion();
                                      },
                                      text: 'next',
                                      enabled: true),
                                ],
                              ),
                            ),
                          ],
                        ))),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40.0),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            margin: const EdgeInsets.only(top: 20.0),
                            width: 350.0,
                            constraints: const BoxConstraints(minHeight: 200.0),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 253, 237, 183),
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 23.5, top: 36.0, bottom: 36.0),
                              child: Wrap(
                                spacing: 10.0,
                                runSpacing: 11.0,
                                alignment: WrapAlignment.start,
                                children: [
                                  ...List.generate(
                                    _totalItems,
                                    (index) => InkWell(
                                      onTap: () {
                                        setState(() {
                                          _questionIndex = index;
                                        });
                                      },
                                      child: Container(
                                        height: 50.0,
                                        width: 35.0,
                                        decoration: BoxDecoration(
                                            color: _questionIndex == index
                                                ? const Color.fromARGB(
                                                    255, 49, 51, 56)
                                                : Colors.amber,
                                            border: Border.all(
                                                color: Colors.amber)),
                                        child: Align(
                                          alignment: Alignment.center,
                                          child: Text(
                                            '${index + 1}',
                                            style: TextStyle(
                                                color: _questionIndex == index
                                                    ? Colors.amber
                                                    : const Color.fromARGB(
                                                        255, 49, 51, 56),
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: PrimaryButton(
                                handlePress: () {
                                  Navigator.restorablePushNamed(
                                      context, '/quiz_result');
                                },
                                text: 'Finish Attempt',
                                enabled: true),
                          )
                        ]),
                  ),
                ),
              ],
            ),
          ),
        ));
  }

  void _selectAnswer(bool? answer, int questionIndex) {
    setState(() {
      _selectedAnswers[questionIndex] = answer;
    });
  }

  void _prevQuestion() {
    if (_questionIndex > 0) {
      setState(() {
        _questionIndex--;
        _currentItem--;
      });
    }
  }

  void _nextQuestion() {
    if (_questionIndex + 1 < _totalItems) {
      setState(() {
        _questionIndex++;
        _currentItem++;
      });
    }

    if (_questionIndex >= _totalItems) _resetQuiz();
  }

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _totalItems = 0;
      _selectedAnswers = List.filled(_totalItems, null);
    });
  }

  double _calculateHorizontalPadding(String questionText) {
    // Adjust this logic based on your requirements
    // You might consider calculating padding based on the length of the text
    return max(20.0, min(questionText.length.toDouble(), 50.0));
  }

  Widget _buildQuestionWidget(
      QuestionModel question, int questionNumber, int index) {
    // Map<String, Object> question, int questionNumber, int index) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.only(
            bottom: 10.0,
          ),
          height: 350.0,
          width: 600.0,
          constraints: const BoxConstraints(
            minHeight: 350.0,
            maxHeight: 350.0,
            maxWidth: 600.0,
          ),
          padding: EdgeInsets.symmetric(
            horizontal: _calculateHorizontalPadding(question.question),
            vertical: 20.0,
          ),
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 253, 237, 183),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 20.0,
                ),
                Text(
                  question.question,
                  textAlign: TextAlign.left,
                  style: const TextStyle(
                    fontSize: 15.0,
                    color: Color.fromARGB(255, 49, 51, 56),
                  ),
                  softWrap: true,
                  maxLines: null,
                ),
                const SizedBox(
                  height: 40.0,
                ),
                for (ChoiceModel choice
                    in (question as MultipleChoiceQuestionModel).choices)
                  // for (Map<String, Object> answer
                  // in (question['answers'] as List<Map<String, Object>>))
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Answer(
                      answerText: choice.content,
                      isSelected: false,
                      answerTap: (bool? selected) {
                        _selectAnswer(selected, index);
                      },
                    ),
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
