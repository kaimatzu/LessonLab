import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
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

  @override
  Widget build(BuildContext context) {
    final quizViewModel = context.watch<QuizPageViewModel>();
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
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 30.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: null,
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20.0)),
                      child: const Text(
                        'Answer',
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 30.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: null,
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20.0)),
                      child: const Text(
                        'Answer',
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () {},
                    child: Container(
                      padding: const EdgeInsets.all(15.0),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5.0, horizontal: 30.0),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: null,
                          border: Border.all(color: Colors.blue),
                          borderRadius: BorderRadius.circular(20.0)),
                      child: const Text(
                        'Answer',
                        style: TextStyle(fontSize: 15.0),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              PrimaryButton(
                  handlePress: () {}, text: 'Next Question', enabled: true)
            ],
          )),
        ));
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
