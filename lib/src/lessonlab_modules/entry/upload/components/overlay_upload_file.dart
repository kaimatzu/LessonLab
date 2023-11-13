import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';

import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/drag_and_drop_area.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay_buttons.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay_provider.dart';

class OverlayUploadFile extends StatefulWidget {
  const OverlayUploadFile({
    Key? key,
    required this.containerWidth,
    required this.containerHeight,
  }) : super(key: key);

  final double containerWidth;
  final double containerHeight;

  @override
  State<OverlayUploadFile> createState() => _OverlayUploadFile();
}

class _OverlayUploadFile extends State<OverlayUploadFile> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final overlayProvider = context.watch<OverlayProvider>();

    return Container(
      width: widget.containerWidth,
      height: widget.containerHeight,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 49, 51, 56),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 60.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  if (overlayProvider.fileCache.isEmpty)
                    Column(
                      children: [
                        const SizedBox(height: 40),
                        const Text(
                          "No files uploaded...",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),
                        const DragAndDropArea(),
                        const SizedBox(height: 7),
                        const Text(
                          "or",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 10),
                        ElevatedButton.icon(
                          onPressed: () {
                            pickFile(context, overlayProvider);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            minimumSize: const Size(60.0, 40.0),
                          ),
                          icon: const Icon(Icons.add),
                          label: const Text('New'),
                        ),
                      ],
                    ),
                  if (overlayProvider.fileCache.isNotEmpty)
                    DropTarget(
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
                                containerWidth: overlayProvider.containerWidth,
                                containerHeight:
                                    overlayProvider.containerHeight),
                            overlayProvider);
                      },
                      child: Container(
                        height: overlayProvider.containerHeight - 113,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: _dragging ? Colors.amber : Colors.white,
                              width: 1.0), // Add this line for border
                          borderRadius: BorderRadius.circular(
                              8.0), // Add this line for rounded corners
                        ),
                        child: Expanded(
                          child: ListView.builder(
                            itemCount: overlayProvider.fileCache.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: ListTile(
                                    tileColor: Colors.white,
                                    leading: const Icon(Icons.file_open,
                                        color: Colors.black),
                                    title: Text(
                                      overlayProvider.fileCache[index].name,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 15,
            left: 10,
            child: ElevatedButton(
              onPressed: () {
                overlayProvider.changeContent(
                    context,
                    () => OverlayButtons(
                        containerWidth: widget.containerWidth,
                        containerHeight: widget.containerHeight),
                    overlayProvider);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120.0, 40.0),
              ),
              child: const Text('Back'),
            ),
          ),
          if (overlayProvider.fileCache.isNotEmpty)
            Positioned(
              bottom: 45,
              left: overlayProvider.containerWidth / 2 - 60,
              child: ElevatedButton.icon(
                onPressed: () {
                  pickFile(context, overlayProvider);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  minimumSize: const Size(60.0, 40.0),
                ),
                icon: const Icon(Icons.add),
                label: const Text('New'),
              ),
            ),
          Positioned(
            bottom: 5,
            right: 5,
            child: SizedBox(
              height: 60.0,
              width: 60.0,
              child: FittedBox(
                child: FloatingActionButton(
                  onPressed: () {
                    if (overlayProvider.fileCache.isNotEmpty) {
                      saveFilesAndClose(context, overlayProvider);
                    } else {
                      null;
                    }
                  },
                  tooltip: 'Add new File resource',
                  backgroundColor: overlayProvider.fileCache.isNotEmpty
                      ? Colors.amber
                      : const Color.fromARGB(162, 164, 127, 14),
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void pickFile(BuildContext context, OverlayProvider overlayProvider) async {
    const XTypeGroup fileTypeGroup = XTypeGroup(
      label: 'Files',
      extensions: <String>['pdf', 'txt', 'md', 'html', 'xml', 'json', 'csv'],
    );

    final List<XFile> result =
        await openFiles(acceptedTypeGroups: <XTypeGroup>[fileTypeGroup]);

    overlayProvider.fileCache.addAll(result);

    // ignore: use_build_context_synchronously
    overlayProvider.changeContent(
        context,
        () => OverlayUploadFile(
            containerWidth: widget.containerWidth,
            containerHeight: widget.containerHeight),
        overlayProvider);
  }

  void saveFilesAndClose(BuildContext context, OverlayProvider overlayProvider) {
    overlayProvider.files.addAll(overlayProvider.fileCache);
    overlayProvider.fileCache.clear();
    
    overlayProvider.hideOverlay();
  }
}
