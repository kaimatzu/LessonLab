import 'package:flutter/material.dart';

class QuizNavigator extends StatefulWidget {
  final int totalItems;
  final int questionIndex;
  final Function(int) tap;
  const QuizNavigator(
      {required this.totalItems,
      required this.questionIndex,
      required this.tap});

  @override
  State<QuizNavigator> createState() => _QuizNavigatorState();
}

class _QuizNavigatorState extends State<QuizNavigator> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      width: 350.0,
      constraints: const BoxConstraints(minHeight: 200.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 253, 237, 183),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Padding(
        padding: const EdgeInsets.only(left: 23.5, top: 36.0, bottom: 36.0),
        child: Wrap(
          spacing: 10.0,
          runSpacing: 11.0,
          alignment: WrapAlignment.start,
          children: [
            ...List.generate(
              widget.totalItems,
              (index) => InkWell(
                onTap: () {
                  setState(() {
                    //currentIndex = index;
                    widget.tap(index);
                  });
                },
                child: Container(
                  height: 50.0,
                  width: 35.0,
                  decoration: BoxDecoration(
                      color: widget.questionIndex == index
                          ? const Color.fromARGB(255, 49, 51, 56)
                          : Color.fromARGB(255, 241, 196, 27),
                      border:
                          Border.all(color: Color.fromARGB(255, 241, 196, 27))),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                          color: widget.questionIndex == index
                              ? Color.fromARGB(255, 241, 196, 27)
                              : const Color.fromARGB(255, 49, 51, 56),
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
