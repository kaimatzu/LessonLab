import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_view.dart';

import 'package:provider/provider.dart';

class MenuCard extends StatelessWidget {
  final String title;
  final String content;
  final int id;

  const MenuCard({
    super.key,
    required this.title,
    required this.content,
    required this.id,
  });

  @override
  Widget build(BuildContext context) {
    var viewModel = context.watch<MenuViewModel>();

    // * TITLE
    var titleText = Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 24.0, 16.0, 16.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
    );

    // * DESCRIPTION
    var descriptionText = Padding(
      padding: const EdgeInsets.fromLTRB(24.0, 8.0, 16.0, 24.0),
      child: Text(
        content,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );

    // * CONTAINER
    var child = Visibility(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          titleText,
          descriptionText,
        ],
      ),
    );

    // * DELETE (icon)
    var icon = Positioned(
      top: 20,
      right: 20,
      child: GestureDetector(
        onTap: () => viewModel.deleteId(id),
        child: const Icon(
          Icons.delete, // 'delete' icon
          // Icons.more_vert,     // 'Kebab' icon
          color: Colors.white,
        ),
      ),
    );

    return GestureDetector(
      onTap: () {
        // Handle click on the entire background
        debugPrint('Card clicked');
        debugPrint('Card title: $title');
        debugPrint('Card id: $id');
        Navigator.restorablePushNamed(
          context,
          LessonOpenView.routeName,
          arguments: id,
        );
      },
      child: Card(
        color: const Color.fromARGB(255, 49, 51, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
        elevation: 8.0,
        child: Stack(
          children: [
            child,
            icon,
          ],
        ),
      ),
    );
  }
}
