import 'dart:math';

import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_models/question_model.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_page/components/answer.dart';

class Question extends StatefulWidget {
  final QuestionModel question;
  final int questionNumber;
  final int index;
  final List<int> selectedAnswers;
  final List<TextEditingController> identificationControllers;

  const Question({
    required this.question,
    required this.questionNumber,
    required this.index,
    required this.selectedAnswers,
    required this.identificationControllers,
  });

  @override
  State<Question> createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  double _calculateHorizontalPadding(String questionText) {
    return max(20.0, min(questionText.length.toDouble(), 50.0));
  }

  @override
  Widget build(BuildContext context) {
    return _buildQuestionWidget(
        widget.question, widget.questionNumber, widget.index);
  }

  Widget _buildQuestionWidget(
      QuestionModel question, int questionNumber, int index) {
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
              color: const Color.fromARGB(255, 244, 245, 247),
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
                    if (question.type == 1)
                      _buildIdentification(index)
                    else if (question.type == 2)
                      _buildMultipleChoice(question, index)
                  ]),
            )),
      ],
    );
  }

  Widget _buildIdentification(int index) {
    return Column(
      children: [
        TextField(
          controller: _getController(index),
          decoration: const InputDecoration(border: OutlineInputBorder()),
        )
      ],
    );
  }

  TextEditingController _getController(int index) {
    while (widget.identificationControllers.length <= index) {
      widget.identificationControllers.add(TextEditingController());
    }
    return widget.identificationControllers[index];
  }

  Widget _buildMultipleChoice(QuestionModel question, int index) {
    return Column(
      children: [
        for (int i = 0;
            i < ((question as MultipleChoiceQuestionModel).choices).length;
            i++)
          Answer(
            answerText: question.choices[i].content,
            index: i,
            groupValue: widget.selectedAnswers.length > index
                ? widget.selectedAnswers[index]
                : 0,
            answerTap: (value) {
              setState(() {
                widget.selectedAnswers[index] = value;
              });
            },
          ),
      ],
    );
  }
}
