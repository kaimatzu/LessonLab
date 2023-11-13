import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay_provider.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/resources_bar.dart';

class ResourcesContainer extends StatelessWidget {
  const ResourcesContainer(
      {super.key, required this.items, required this.icon});

  final List<Object> items;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        restorationId: 'contentListView',
        // physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        primary: false,
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final dynamic currentItem = items[index];
          if (currentItem is XFile) {
            return ListTile(
              title: ResourcesBar(item: currentItem.name, icon: icon),
            );
          } else if (currentItem is TextFile) {
            return ListTile(
              title: ResourcesBar(item: currentItem.title, icon: icon),
            );
          } else if (currentItem is String) {
            return ListTile(
              title: ResourcesBar(item: currentItem, icon: icon),
            );
          }

          return Container(); // Placeholder for other types
        });
  }
}
