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

class _QuizPageViewState extends State<QuizPageView> {
  int _questionIndex = 0;
  bool _isSelected = false;

  int _totalItem = 0;
  int _currentItem = 1;

  @override
  Widget build(BuildContext context) {
    final quizViewModel = context.watch<QuizPageViewModel>();
    _totalItem = quizViewModel.questions.length;

    return Scaffold(
        appBar: const LessonLabAppBar(),
        body: SingleChildScrollView(
          child: Center(
              child: Column(
            children: [
              const SizedBox(height: 20.0),
              _buildQuestionWidget(
                  quizViewModel.questions[_questionIndex], _questionIndex + 1),
              ListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ...(quizViewModel.questions[_questionIndex]['answers']
                          as List<Map<String, Object>>)
                      .map(
                    (answer) => Answer(
                      answerText: answer['answerText'] as String,
                      answerColor: _isSelected
                          ? answer['score'] as bool
                              ? Colors.green
                              : Colors.red
                          : Colors.transparent,
                      answerTap: () {
                        _questionAnswered(answer['score'] as bool);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              PrimaryButton(
                  handlePress: () {
                    _nextQuestion();
                  },
                  text: 'Next',
                  enabled: true),
              const SizedBox(
                height: 20.0,
              ),
              PrimaryButton(
                  handlePress: () {
                    _prevQuestion();
                  },
                  text: 'Prev',
                  enabled: true),
              Container(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    '$_currentItem/$_totalItem',
                    style: const TextStyle(
                        fontSize: 40.0, fontWeight: FontWeight.bold),
                  ))
            ],
          )),
        ));
  }

  void _questionAnswered(bool answer) {
    setState(() {
      _isSelected = true;
    });
  }

  void _prevQuestion() {
    setState(() {
      _questionIndex--;
      _currentItem--;
    });
  }

  void _nextQuestion() {
    setState(() {
      _questionIndex++;
      _currentItem++;
      _isSelected = false;
    });

    if (_questionIndex >= _totalItem) _resetQuiz();
  }

  void _resetQuiz() {
    setState(() {
      _questionIndex = 0;
      _totalItem = 0;
    });
  }

  Widget _buildQuestionWidget(
      Map<String, dynamic> questionData, int questionNumber) {
    return Container(
        width: double.infinity,
        height: 130.0,
        margin: const EdgeInsets.only(bottom: 10.0, left: 30.0, right: 30.0),
        padding: const EdgeInsets.symmetric(horizontal: 50.0, vertical: 20.0),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 49, 51, 56),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Center(
          child: Text(
            'Question $questionNumber: ${questionData['question']}',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 20.0,
                color: Colors.amber,
                fontWeight: FontWeight.bold),
          ),
        ));
  }
}
