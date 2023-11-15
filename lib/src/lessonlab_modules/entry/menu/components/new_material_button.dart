import 'package:flutter/material.dart';

class NewMaterialButton extends StatelessWidget {
  const NewMaterialButton(
      {super.key,
      required this.onPressed,
      required this.icon,
      required this.text});

  final void Function() onPressed;
  final Icon icon;
  final String text;

  final Color yellow = const Color.fromRGBO(241, 196, 27, 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: yellow.withOpacity(.3),
            spreadRadius: 2,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton.icon(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(yellow),
          shadowColor: MaterialStateProperty.all<Color>(yellow.withOpacity(0)),
        ),
        onPressed: onPressed,
        icon: icon,
        label: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }
}
