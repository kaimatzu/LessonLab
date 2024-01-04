import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/components/answer.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/quiz_page_view_model.dart';
import 'package:provider/provider.dart';

class QuizPageView extends StatefulWidget {
  const QuizPageView({
    Key? key,
  }) : super(key: key);

  static const routeName = '/quiz_page';

  @override
  State<QuizPageView> createState() => _QuizPageViewState();
}

//TODO: MAKE IDENTIFICATION TYPE QUIZ

//THIS IS MULTIPLE CHOICE QUIZ
class _QuizPageViewState extends State<QuizPageView> {
  int _questionIndex = 0;

  int _totalItem = 0;
  int _currentItem = 1;

  List<bool?> _selectedAnswers = List.filled(10, null);

  @override
  Widget build(BuildContext context) {
    final quizViewModel = context.watch<QuizPageViewModel>();
    _totalItem = quizViewModel.questions.length;

    return Scaffold(
        appBar: const LessonLabAppBar(),
        body: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 30.0, 0.0, 0.0),
                    child: Container(
                        child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20.0),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 50.0),
                          child: const Text(
                            "Quiz Title: <Your quiz title>",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontSize: 30.0, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 20.0),
                        _buildQuestionWidget(
                          quizViewModel.questions[_questionIndex],
                          _questionIndex + 1,
                          _questionIndex,
                        ),
                        const SizedBox(
                          height: 20.0,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 60.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              PrimaryButton(
                                  handlePress: () {
                                    _prevQuestion();
                                  },
                                  text: '<',
                                  enabled: true),
                              Text(
                                '$_currentItem/$_totalItem',
                                style: const TextStyle(
                                    fontSize: 20.0,
                                    fontWeight: FontWeight.bold),
                              ),
                              PrimaryButton(
                                  handlePress: () {
                                    _nextQuestion();
                                  },
                                  text: '>',
                                  enabled: true),
                            ],
                          ),
                        ),
                      ],
                    )))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 0.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(20.0, 50.0, 6.0, 0.0),
                        height: 100.0,
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                      ),
                      const Spacer(),
                    ]),
              ),
            ),
          ],
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
    if (_questionIndex + 1 < _totalItem) {
      setState(() {
        _questionIndex++;
        _currentItem++;
      });
    }

    if (_questionIndex >= _totalItem) _resetQuiz();
  }

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _totalItem = 0;
      _selectedAnswers = List.filled(_totalItem, null);
    });
  }

  Widget _buildQuestionWidget(
      Map<String, Object> question, int questionNumber, int index) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                    margin: const EdgeInsets.only(
                        bottom: 10.0, left: 30.0, right: 600.0),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 50.0, vertical: 20.0),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 49, 51, 56),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Align(
                        alignment: Alignment.centerLeft,
                        child: Flexible(
                          child: Text(
                            '$questionNumber: ${question['question']}',
                            textAlign: TextAlign.left,
                            style: const TextStyle(
                              fontSize: 15.0,
                              color: Colors.amber,
                            ),
                            softWrap: true,
                          ),
                        ))),
                Container(
                  margin: const EdgeInsets.only(left: 30.0),
                  child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        for (Map<String, Object> answer in (question['answers']
                            as List<Map<String, Object>>))
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Answer(
                              answerText: answer['answerText'] as String,
                              isSelected: false,
                              answerTap: (bool? selected) {
                                _selectAnswer(selected, index);
                              },
                            ),
                          ),
                      ]),
                ),
                const SizedBox(
                    height: 20.0), // Adjust spacing between questions
              ],
            ),
          ],
        ));
  }
}
