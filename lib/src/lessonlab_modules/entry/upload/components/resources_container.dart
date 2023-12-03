import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_controller.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/resources_bar.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_view_model.dart';

class ResourcesContainer extends StatelessWidget {
  const ResourcesContainer({
    super.key,
    required this.viewModel,
    required this.items,
    required this.icon,
  });

  final UploadSourcesViewModel viewModel;
  final List<Object> items;
  final Icon icon;

  @override
  Widget build(BuildContext context) {
    var listView = ListView.builder(
        restorationId: 'contentListView',
        // physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        primary: false,
        itemCount: items.length,
        itemBuilder: (BuildContext context, int index) {
          final dynamic currentItem = items[index];
          if (currentItem is XFile) {
            return ListTile(
              title: ResourcesBar(
                  viewModel: viewModel,
                  title: currentItem.name,
                  icon: icon,
                  // items: ItemListWrapper(items),
                  // items: items,
                  object: currentItem),
            );
          } else if (currentItem is TextFile) {
            return ListTile(
              title: ResourcesBar(
                  viewModel: viewModel,
                  title: currentItem.title,
                  icon: icon,
                  // items: ItemListWrapper(items),
                  // items: items,
                  object: currentItem),
            );
          } else if (currentItem is String) {
            return ListTile(
              title: ResourcesBar(
                  viewModel: viewModel,
                  title: currentItem,
                  icon: icon,
                  // items: ItemListWrapper(items),
                  // items: items,
                  object: currentItem),
            );
          }

          return Container(); // Placeholder for other types
        });

    return listView;
  }
}
