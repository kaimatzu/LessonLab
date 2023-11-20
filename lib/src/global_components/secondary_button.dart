import 'package:flutter/material.dart';

class SecondaryButton extends StatelessWidget {
  const SecondaryButton(
      {super.key, required this.handlePress, required this.text});

  final void Function() handlePress;
  final String text;
  final Color yellow = const Color.fromRGBO(242, 212, 102, 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: yellow.withOpacity(.3),
            spreadRadius: 3,
            blurRadius: 10,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: yellow.withOpacity(.3),
            spreadRadius: 3,
            blurRadius: 20,
            offset: const Offset(0, 10),
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
          padding: const EdgeInsets.fromLTRB(24.0, 16.0, 24.0, 16.0),
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
