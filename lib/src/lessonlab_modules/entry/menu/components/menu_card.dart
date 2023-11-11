import 'package:flutter/material.dart';

class MenuCard extends StatelessWidget {
  final String title;
  final String content;

  const MenuCard({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 49, 51, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0), // Set the border radius here
      ),
      elevation: 8.0,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 24.0, 16.0, 16.0),
            child: Text(
              title,
              style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 8.0, 16.0, 24.0),
            child: Text(
              content,
              style: const TextStyle(fontSize: 16, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
