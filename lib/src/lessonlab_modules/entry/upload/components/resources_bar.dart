import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
// import 'package:lessonlab/messages/entry/upload/uploaded_content.pb.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_view_model.dart';
import 'package:provider/provider.dart';

import 'overlay/overlay_controller.dart';

class ResourcesBar extends StatelessWidget {
  const ResourcesBar({
    super.key,
    required this.title,
    required this.icon,
    // required this.items,
    required this.object,
  });

  // final List<Object> items;
  final String title;
  final Icon icon;
  final Object object;

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<UploadSourcesViewModel>();

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
            child: Text(
              title,
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 15,
                color: Colors.white,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              if (object is XFile) {
                viewModel.removePdf(object as XFile);
              } else if (object is String) {
                viewModel.removeUrl(object as String);
              } else if (object is TextFile) {
                viewModel.removeText(object as TextFile);
              }
            },
            child: const Icon(Icons.delete, color: Colors.white),
          )
        ],
      ),
    );
  }
}
