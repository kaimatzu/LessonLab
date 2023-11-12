import 'package:flutter/material.dart';

class FileBar extends StatelessWidget {
  const FileBar({super.key, required this.item});

  final String item;

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 49, 51, 56),
          borderRadius: BorderRadius.circular(12.0),
        ),
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            Expanded(
              child: Text(item,
                  style: const TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const Icon(
              Icons.more_vert,
              color: Colors.white,
            ),
          ],
        ));
  }
}
