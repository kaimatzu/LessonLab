import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';

class InputFields extends StatelessWidget {
  const InputFields({
    super.key,
    required this.label,
    required this.hintLabel
  });

  final String hintLabel;
  final String label;

  @override
  Widget build(BuildContext context) {

    return Padding(padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(color: Color.fromARGB(255, 49, 51, 56), fontSize: 20.0),
            ),
            TextField(
              style: const TextStyle(color: Colors.white),
              decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromARGB(255, 49, 51, 56),
              border: const OutlineInputBorder(),
              labelText: hintLabel,
              labelStyle: const TextStyle(color: Color.fromRGBO(255, 193, 7, 0.7)),
              floatingLabelBehavior: FloatingLabelBehavior.never
              ),
            )
          ],
        )
      );
  }
}
