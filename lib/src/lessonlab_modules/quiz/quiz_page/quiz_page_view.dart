import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/global_models/choice_model.dart';
import 'package:lessonlab/src/global_models/question_model.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/components/question.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/components/quiz_navigator.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/components/show_dialog.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_result/quiz_result_view_model.dart';
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

class _QuizPageViewState extends State<QuizPageView> {
  int _questionIndex = 0;

  int _totalItems = 0;

  late DateTime startTime;

  List<int> _selectedAnswers = [];
  List<TextEditingController> _identificationControllers = [];
  List<Map<String, dynamic>> results = [];

  _QuizPageViewState() {
    developer.log("constructor call quizpageviewstate");
  }

  int get questionIndex {
    return _questionIndex;
  }

  @override
  void initState() {
    super.initState();
    startTime = DateTime.now();

    Future.delayed(Duration.zero, () {
      final quizViewModel = context.read<QuizPageViewModel>();
      setState(() {
        _totalItems = quizViewModel.questions.length;

        _selectedAnswers = List.filled(_totalItems, -1);

        _identificationControllers = List.generate(
          _totalItems,
          (index) => TextEditingController(),
        );
      });
    });
  }

  void _handleItemTap(int index) {
    setState(() {
      _questionIndex = index; // Update _questionIndex in QuizPageView
    });
  }

  @override
  Widget build(BuildContext context) {
    final quizViewModel = context.watch<QuizPageViewModel>();
    _totalItems = quizViewModel.questions.length;

    developer.log("questions.length: ${quizViewModel.questions.length}",
        name: "build");

    return Scaffold(
        appBar: const LessonLabAppBar(),
        body: Column(
          children: [
            Align(
                alignment: Alignment.topLeft,
                child: Container(
                  margin: EdgeInsets.only(left: 125.0, top: 20.0),
                  child: const Text(
                    "Quiz Title",
                    style: TextStyle(
                        color: Color.fromARGB(255, 49, 51, 56),
                        fontSize: 25.0,
                        fontWeight: FontWeight.bold),
                  ),
                )),
            SingleChildScrollView(
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
                                Question(
                                    question: quizViewModel
                                        .questions[_questionIndex]!,
                                    questionNumber: _questionIndex + 1,
                                    index: _questionIndex,
                                    selectedAnswers: _selectedAnswers,
                                    identificationControllers:
                                        _identificationControllers),
                                const SizedBox(
                                  height: 20.0,
                                ),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 0.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      PrimaryButton(
                                          width: 100.0,
                                          handlePress: () {
                                            _prevQuestion();
                                          },
                                          text: 'Previous',
                                          enabled: true),
                                      Container(
                                        padding: const EdgeInsets.only(
                                            left: 20.0, right: 20.0),
                                        width: 75.0,
                                        child: Text(
                                          '${_questionIndex + 1}/$_totalItems',
                                          style: const TextStyle(
                                              color: Color.fromARGB(
                                                  255, 49, 51, 56),
                                              fontSize: 20.0,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      PrimaryButton(
                                          width: 100.0,
                                          handlePress: () {
                                            _nextQuestion();
                                          },
                                          text: 'Next',
                                          enabled: true),
                                    ],
                                  ),
                                ),
                              ],
                            ))),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(right: 125.0),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              QuizNavigator(
                                  totalItems: _totalItems,
                                  questionIndex: _questionIndex,
                                  tap: _handleItemTap),
                              Padding(
                                padding: const EdgeInsets.only(top: 20.0),
                                child: PrimaryButton(
                                  handlePress: () {
                                    ShowDialog.ShowConfirmDialog(context, () {
                                      _finishAttempt();
                                    });
                                    //_showConfirmationDialog();
                                  },
                                  text: 'Finish Attempt',
                                  enabled: true,
                                ),
                              )
                            ]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ));
  }

  void _prevQuestion() {
    if (_questionIndex > 0) {
      setState(() {
        _questionIndex--;
      });
    }
  }

  void _nextQuestion() {
    if (_questionIndex + 1 < _totalItems) {
      setState(() {
        _questionIndex++;
      });
    }
  }

  void _finishAttempt() {
    results.clear();
    _checkAllAnswers();

    Duration elapsedTime = DateTime.now().difference(startTime);

    Navigator.pushNamed(
      context, 
      '/quiz_result',
      arguments: {'elapsedTime': elapsedTime},
      );
  }

  void _checkAllAnswers() {
    final quizViewModel = context.read<QuizPageViewModel>();
    final quizResultViewModel =
        Provider.of<QuizResultViewModel>(context, listen: false);

    for (int i = 0; i < _totalItems; i++) {
      bool isCorrect = false;
      dynamic userAnswer;

      if (quizViewModel.questions[i]?.type == 1) {
        // Identification Checking
        String correctAnswer =
            (quizViewModel.questions[i] as IdentificationQuestionModel).answer;

        userAnswer = _identificationControllers[i].text;
        isCorrect = userAnswer.toLowerCase() == correctAnswer.toLowerCase();

        results.add({
          'question': quizViewModel.questions[i]?.question,
          'type': quizViewModel.questions[i]?.type,
          'userAnswer': userAnswer,
          'isCorrect': isCorrect,
          'correctAnswer': correctAnswer,
        });
      } else {
        //Multiple-Choice Checking
        List<ChoiceModel> choices =
            (quizViewModel.questions[i] as MultipleChoiceQuestionModel).choices;

        int selectedChoiceIndex = _selectedAnswers[i];
        bool hasSelectedChoice = selectedChoiceIndex >= 0;
        String selectedChoiceContent = hasSelectedChoice
            ? choices[selectedChoiceIndex].content
            : 'No Answer';

        isCorrect = hasSelectedChoice
            ? choices[selectedChoiceIndex].isCorrect == true
            : false;

        userAnswer = {
          'index': selectedChoiceIndex as int,
          'content': selectedChoiceContent,
        };

        List<Map<String, dynamic>> choicesData = choices
            .map((choice) => {
                  'index': choices.indexOf(choice),
                  'content': choice.content,
                })
            .toList();

        results.add({
          'question': quizViewModel.questions[i]?.question,
          'type': quizViewModel.questions[i]?.type,
          'userAnswer': userAnswer,
          'isCorrect': isCorrect,
          'choices': choicesData,
          'correctAnswer':
              choices.firstWhere((choice) => choice.isCorrect).content,
          'correctAnswerIndex':
              choices.indexWhere((choice) => choice.isCorrect),
        });
      }
    }

    quizResultViewModel.setResults(results);
  }

  int _calculateScore() {
    return results.where((result) => result['isCorrect']).length;
  }
}
