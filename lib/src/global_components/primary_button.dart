import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.handlePress,
    required this.text,
    required this.enabled,
  });

  final void Function() handlePress;
  final String text;
  final bool enabled;

  static const yellow = Color.fromARGB(255, 241, 196, 27);
  static const disabled =
      Color.fromARGB(255, (241 + 255) ~/ 2, (196 + 255) ~/ 2, (27 + 255) ~/ 2);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: yellow.withOpacity(.3),
                  spreadRadius: 3,
                  blurRadius: 10,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: ElevatedButton(
        onPressed: handlePress,
        onHover: enabled
            ? (bool onHover) {}
            : (bool onHover) {
                null;
              },
        style: ButtonStyle(
          backgroundColor: enabled
              ? MaterialStateProperty.all<Color>(yellow)
              : MaterialStateProperty.all<Color>(disabled),
          shadowColor: MaterialStateProperty.all<Color>(yellow.withAlpha(0)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
          child: Text(text),
        ),
      ),
    );
  }
}
