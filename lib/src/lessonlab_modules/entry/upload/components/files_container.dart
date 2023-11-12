import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/file_bar.dart';

class FileContainer extends StatelessWidget {
  const FileContainer({super.key, required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
            restorationId: 'pdfListView',
            // physics: const NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            primary: false,
            itemCount: items.length,
            itemBuilder: (BuildContext context, int index) {
              return ListTile(
                title: FileBar(item: items[index])
              );
            });
  }
}
