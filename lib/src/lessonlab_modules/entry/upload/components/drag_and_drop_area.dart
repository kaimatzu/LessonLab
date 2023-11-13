import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:desktop_drop/desktop_drop.dart';

import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay_upload_file.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay_provider.dart';

class DragAndDropArea extends StatefulWidget {
  const DragAndDropArea({
    Key? key,
  }) : super(key: key);

  @override
  State<DragAndDropArea> createState() => _DragAndDropArea();
}

class _DragAndDropArea extends State<DragAndDropArea> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final overlayProvider = context.watch<OverlayProvider>();

    return DropTarget(
      onDragDone: (detail) {
        overlayProvider.fileCache.addAll(detail.files);
      },
      onDragEntered: (detail) {
        setState(() {
          _dragging = true;
        });
      },
      onDragExited: (detail) {
        setState(() {
          _dragging = false;
        });
        overlayProvider.changeContent(
        context,
        () => OverlayUploadFile(
            containerWidth: overlayProvider.containerWidth, containerHeight: overlayProvider.containerHeight),
        overlayProvider);
      },
      child: Container(
          width: 300,
          height: 100,
          decoration: BoxDecoration(
            border: Border.all(
              color: _dragging ? Colors.amber : Colors.white,
              style: BorderStyle.solid,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: const Center(
              child: Text("Drop files here.",
                  style: TextStyle(color: Colors.white)))
          ),
    );
  }
}
