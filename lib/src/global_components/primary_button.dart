import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.handlePress,
    required this.text,
    required this.enabled,
    this.width,
    this.height,
    this.topLeftRadius = 12.0,
    this.topRightRadius = 12.0,
    this.bottomLeftRadius = 12.0,
    this.bottomRightRadius = 12.0,
  });

  final void Function() handlePress;
  final String text;
  final bool enabled;
  final double? width;
  final double? height;
  final double topLeftRadius;
  final double topRightRadius;
  final double bottomLeftRadius;
  final double bottomRightRadius;

  static const yellow = Color.fromARGB(255, 241, 196, 27);
  static const disabled =
      Color.fromARGB(255, (241 + 255) ~/ 2, (196 + 255) ~/ 2, (27 + 255) ~/ 2);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
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
          shape: MaterialStateProperty.all<OutlinedBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(topLeftRadius),
                topRight: Radius.circular(topRightRadius),
                bottomLeft: Radius.circular(bottomLeftRadius),
                bottomRight: Radius.circular(bottomRightRadius),
              ),
            ),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, 16.0, 0.0, 16.0),
          child: Text(text),
        ),
      ),
    );
  }
}
