import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class InputField extends StatefulWidget {
  InputField({
    Key? key,
    required this.label,
    required this.hintLabel,
  }) : super(key: key);

  final String hintLabel;
  final String label;

  final TextEditingController controller = TextEditingController();

  @override
  // ignore: library_private_types_in_public_api
  _InputFieldState createState() => _InputFieldState();
}

class _InputFieldState extends State<InputField> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 10.0, 16.0, 0.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.label,
            style: const TextStyle(
                color: Color.fromARGB(255, 49, 51, 56), fontSize: 16.0),
          ),
          TextField(
            controller: widget.controller,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              filled: true,
              fillColor: const Color.fromARGB(255, 49, 51, 56),
              border: const OutlineInputBorder(),
              labelText: widget.hintLabel,
              labelStyle:
                  const TextStyle(color: Color.fromRGBO(255, 193, 7, 0.7)),
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
