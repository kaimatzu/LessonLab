import 'package:flutter/material.dart';

class Answer extends StatefulWidget {
  final String answerText;
  final int index;
  final int groupValue;
  final Function(int) answerTap;

  Answer({
    required this.answerText,
    required this.index,
    required this.groupValue,
    required this.answerTap,
  });

  @override
  State<Answer> createState() => _AnswerState();
}

class _AnswerState extends State<Answer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        RadioListTile<int>(
          title: Text(
            widget.answerText,
            style: const TextStyle(
              fontSize: 15.0,
              color: Color.fromARGB(255, 49, 51, 56),
            ),
          ),
          value: widget.index,
          groupValue: widget.groupValue,
          onChanged: (value) {
            widget.answerTap(value!);
          },
        ),
      ],
    );
  }
}
