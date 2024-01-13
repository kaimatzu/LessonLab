import "package:flutter/material.dart";

class ResultItem extends StatelessWidget {
  final Map<String, dynamic> result;
  final int index;

  const ResultItem({required this.result, required this.index});

  @override
  Widget build(BuildContext context) {
    String userAnswerText = '';
    String correctAnswerText = '';

    if (result['type'] == 1) {
      // Identification question
      userAnswerText = result['userAnswer'] ?? 'No Answer';
      correctAnswerText =
          (result['correctAnswer'] != null) ? result['correctAnswer'] : '';
    } else if (result['type'] == 2) {
      // Multiple choice question
      List<Map<String, dynamic>> choices = result['choices'];

      userAnswerText =
          (result['userAnswer'] != null && result['userAnswer']['index'] >= 0)
              ? choices[result['userAnswer']['index']]['content']
              : 'No Answer';
      correctAnswerText = choices[result['correctAnswerIndex']]['content'];
    }

    return Container(
      height: 200.0,
      decoration: BoxDecoration(
          color: result['isCorrect']
              ? Color.fromARGB(255, 223, 255, 219)
              : Color.fromARGB(255, 255, 219, 219),
          borderRadius: BorderRadius.circular(10.0)),
      margin: EdgeInsets.only(bottom: 20.0, right: 40.0),
      child: Padding(
        padding: const EdgeInsets.only(left: 20.0, top: 10.0, bottom: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${index + 1}. ${result['question']}',
              style: TextStyle(
                color: Color.fromARGB(255, 49, 51, 56),
                fontSize: 18.0,
              ),
            ),
            if (result['type'] == 2) _buildMultipleChoiceResult(result),
            if (result['type'] == 1)
              _buildIdentificationItem(result, userAnswerText),
            Container(
              margin: EdgeInsets.only(top: 25.0),
              child: Text(
                'Correct Answer: $correctAnswerText',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Color.fromARGB(255, 49, 51, 56),
                  fontSize: 16.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMultipleChoiceResult(Map<String, dynamic> result) {
    List<Map<String, dynamic>> choices = result['choices'];
    int correctAnswerIndex = result['correctAnswerIndex'];

    int? selectedChoiceIndex = result['userAnswer']?['index'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (int i = 0; i < choices.length; i++)
          Row(
            children: [
              Radio(
                value: i,
                groupValue: selectedChoiceIndex,
                onChanged: (value) {},
              ),
              Row(
                children: [
                  Text(
                    choices[i]['content'] ?? '',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Color.fromARGB(255, 49, 51, 56),
                    ),
                  ),
                  if (i == correctAnswerIndex && i == selectedChoiceIndex)
                    Text(
                      '  ✔',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.green,
                      ),
                    ),
                  if (i == selectedChoiceIndex && i != correctAnswerIndex)
                    Text(
                      '  ❌',
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            ],
          ),
      ],
    );
  }

  Widget _buildIdentificationItem(
      Map<String, dynamic> result, String userAnswerText) {
    return Container(
      margin: EdgeInsets.only(top: 20.0),
      child: Row(
        children: [
          Text(
            'Your Answer: ',
            style: TextStyle(
              fontSize: 16.0,
              color: Color.fromARGB(255, 49, 51, 56),
            ),
          ),
          Text(
            '$userAnswerText',
            style: TextStyle(
              fontSize: 16.0,
              color: Color.fromARGB(255, 49, 51, 56),
            ),
          ),
          if (result['isCorrect'])
            Text(
              '  ✔',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.green,
              ),
            ),
          if (result['userAnswer'] == '')
            Text(
              '  N/A',
              style: TextStyle(
                fontSize: 16.0,
                color: Color.fromARGB(255, 49, 51, 56),
              ),
            ),
          if (!result['isCorrect'] && result['userAnswer'] != '')
            Text(
              '  ❌',
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.red,
              ),
            ),
        ],
      ),
    );
  }
}
