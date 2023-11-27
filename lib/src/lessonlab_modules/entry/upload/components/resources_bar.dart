import 'package:flutter/material.dart';

class ResourcesBar extends StatelessWidget {
  const ResourcesBar({
    super.key, 
    required this.item,
    required this.icon
  });

  final String item;
  final Icon icon;

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
            icon,
            const SizedBox(width: 6),
            Expanded(
              child: Text(item,
                  style: const TextStyle(fontSize: 18, color: Colors.white)),
            ),
            const Icon(Icons.more_vert, color: Colors.white)
            // icon
          ],
        ));
  }
}
