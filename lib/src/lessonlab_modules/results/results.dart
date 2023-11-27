import 'package:flutter/material.dart';

class QuizResult extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        height: double.infinity,
        child: Column(
          children: [
            const Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  'Quiz',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
            ),
            const Expanded(
              child: CenteredRowsWithLabels(),
            ),
            ScoreContainer(),
            FinishButton(),
          ],
        ),
      ),
    );
  }
}
class CenteredRowsWithLabels extends StatelessWidget {
  const CenteredRowsWithLabels({Key? key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: 10,
        itemBuilder: (context, index) {
          return CenteredRowWithLabel(
            questionNumber: index + 1,
          );
        },
      ),
    );
  }
}
class CenteredRowWithLabel extends StatelessWidget {
  final int questionNumber;

  CenteredRowWithLabel({required this.questionNumber});

  @override
  Widget build(BuildContext context) {
    Color customcolor = const Color(0xFF00860D);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 200,
          height: 50,
          decoration: BoxDecoration(
            color: customcolor,
            borderRadius: BorderRadius.circular(8.0), // Adjust the radius as needed
          ),
          child: const Center(
            child: Text(
              'Sample Correct Answer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(20),
          child: Text(
            '$questionNumber. Sample Question',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
class ScoreContainer extends StatelessWidget {
  final int score = 10;

  @override
  Widget build(BuildContext context) {
    Color customColor = const Color(0xFFFFD32C);
    bool passed = score >= 7;

    Color scoreTextColor = passed ? Colors.green : Colors.red;

    return Container(
      color: passed ? customColor : Colors.red,
      padding: const EdgeInsets.all(12),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Text(
            'Score',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Color.fromARGB(255, 2, 0, 0),
            ),
          ),
          Text(
            '$score/10',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: scoreTextColor,
            ),
          ),
          Text(
            passed ? 'You Pass' : 'You Fail',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: Color.fromARGB(255, 2, 0, 0),
            ),
          ),
        ],
      ),
    );
  }
}
class FinishButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomRight,
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: () {
          print("button pressed");
        },
        style: ElevatedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0), 
          ),
        ),
        child: const Text('Finish'),
      ),
    );
  }
}