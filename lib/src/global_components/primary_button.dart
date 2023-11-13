import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.handlePress,
    required this.text,
  });

  final void Function() handlePress;
  final String text;

  static const yellow = Color.fromRGBO(241, 196, 27, 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: yellow.withOpacity(.3),
            spreadRadius: 5,
            blurRadius: 15,
            offset: const Offset(0, 2),
          ),
          BoxShadow(
            color: yellow.withOpacity(.3),
            spreadRadius: 5,
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: handlePress,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(yellow),
          shadowColor: MaterialStateProperty.all<Color>(yellow.withAlpha(0)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(32.0, 16.0, 32.0, 16.0),
          child: Text(text),
        ),
      ),
    );
  }
}
