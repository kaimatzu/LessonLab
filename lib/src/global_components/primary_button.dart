import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton(
      {super.key, required this.handlePress, required this.text});

  final void Function() handlePress;
  final String text;

  static const yellow = Color.fromRGBO(241, 196, 149, 1);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: handlePress,
      style: ButtonStyle(
        backgroundColor: MaterialStateProperty.all<Color>(yellow),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
        child: Text(text),
      ),
    );
  }
}
