import 'package:flutter/material.dart';

class Answer extends StatelessWidget {
  final String answerText;
  final bool isSelected;
  final Function(bool?) answerTap;

  Answer({
    required this.answerText,
    required this.isSelected,
    required this.answerTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Radio<bool?>(
          value: isSelected,
          groupValue:
              isSelected, // You might need to manage the group value accordingly
          onChanged: (bool? selected) {
            answerTap(selected);
          },
        ),
        Container(
            padding: const EdgeInsets.all(15.0), // Adjust the right padding
            margin: const EdgeInsets.only(bottom: 10.0, right: 600.0),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                answerText,
                style: TextStyle(fontSize: 15.0),
              ),
            )),
      ],
    );
  }
}
