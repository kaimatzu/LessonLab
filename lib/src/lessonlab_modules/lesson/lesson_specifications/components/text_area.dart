import 'package:flutter/material.dart';

class TextArea extends StatefulWidget {
  TextArea({
    Key? key,
    required this.label,
    required this.hintLabel,
  }) : super(key: key);

  final String hintLabel;
  final String label;

  final TextEditingController controller = TextEditingController();

  @override
  // ignore: library_private_types_in_public_api
  _TextAreaState createState() => _TextAreaState();
}

class _TextAreaState extends State<TextArea> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 32.0, 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
              fontFamily: 'Roboto, Inter, Arial',
              color: Color.fromARGB(255, 49, 51, 56),
              fontSize: 24.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8.0),
          TextField(
            controller: widget.controller,
            keyboardType: TextInputType.multiline,
            maxLines: 12,
            style: const TextStyle(
              fontFamily: 'Roboto, Inter, Arial',
              color: Colors.white,
            ),
            decoration: InputDecoration(
              contentPadding: const EdgeInsets.all(16.0),
              filled: true,
              fillColor: const Color.fromARGB(255, 49, 51, 56),
              border: const OutlineInputBorder(),
              labelText: widget.hintLabel,
              labelStyle: const TextStyle(
                color: Colors.grey,
              ),
              floatingLabelBehavior: FloatingLabelBehavior.never,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }
}
