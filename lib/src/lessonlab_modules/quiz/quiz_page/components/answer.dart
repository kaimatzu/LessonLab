import 'package:flutter/material.dart';

class Answer extends StatelessWidget {
  final String answerText;

  Answer({required this.answerText});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(15.0),
        margin: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 30.0),
        width: double.infinity,
        decoration: BoxDecoration(
            color: null,
            border: Border.all(color: Colors.blue),
            borderRadius: BorderRadius.circular(20.0)),
        child: Text(
          answerText,
          style: TextStyle(fontSize: 15.0),
        ),
      ),
    );
  }
}
