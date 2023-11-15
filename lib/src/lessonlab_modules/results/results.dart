import 'package:flutter/material.dart';

class QuizResult extends StatelessWidget {
  const QuizResult({Key? key}) : super(key: key);

  static const  routenName = '/Result';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quiz Result'),
      ),
      body: const Center(
        child: Text(
          'Hello, World!',
          style: TextStyle(fontSize: 24),
        ),
      ),
    );
  }
}
