import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_view_model.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'package:rinf/rinf.dart';

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
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Render title
          TextFormField(
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            initialValue: widget.title,
            decoration: const InputDecoration(
              hintText: 'Enter your title here...',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: Color.fromARGB(255, 49, 51, 56),
              border: OutlineInputBorder(),
            ),
          ),
        ]
      )
    );
  }
}