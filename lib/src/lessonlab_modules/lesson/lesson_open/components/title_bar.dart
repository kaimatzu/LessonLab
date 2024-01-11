import 'package:flutter/material.dart';

class TitleBar extends StatefulWidget {
  const TitleBar({
    Key? key,
    required this.title,
  }) : super(key: key);

  final String title;

  @override
  State<TitleBar> createState() => _TitleBar();
}

class _TitleBar extends State<TitleBar> {
  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        child: Column(children: [
          // Render title
          TextFormField(
            style: const TextStyle(
              color: Color.fromARGB(255, 49, 51, 56),
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            initialValue: widget.title,
            decoration: const InputDecoration(
              hintText: 'Enter your title here...',
              hintStyle: TextStyle(
                color: Colors.blueGrey,
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: Color.fromARGB(
                  255, (241 + 255) ~/ 2, (196 + 255) ~/ 2, (27 + 255) ~/ 2),
            ),
          ),
        ]));
  }
}
