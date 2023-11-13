import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SelectionCard extends StatelessWidget {
  const SelectionCard({super.key, required this.text, required this.icon});

  final SvgPicture icon;
  final String text;

  static const yellow = Color.fromRGBO(241, 196, 27, 1);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: yellow,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: yellow.withOpacity(.3),
            spreadRadius: 2,
            blurRadius: 4,
            offset: const Offset(0, 2),
          )
        ],
      ),
      width: 120,
      height: 120,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            icon,
            Text(
              text,
              style: const TextStyle(
                fontFamily: 'Inter, Roboto, Arial',
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
