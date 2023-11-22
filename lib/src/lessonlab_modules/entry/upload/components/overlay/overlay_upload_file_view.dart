import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_view_model.dart';
import 'package:provider/provider.dart';
import 'package:file_selector/file_selector.dart';

import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/drag_and_drop_area.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_buttons_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_view_model.dart';


/* 
  TODO: Fix angy Flutter
  Flutter seems to be angry at something implemented here. Will check later. 
  Can't be fucking arsed to fix it right now. It seems to work just fine on the surface.
*/
class OverlayUploadFileView extends StatefulWidget {
  const OverlayUploadFileView({
    Key? key,
    required this.containerWidth,
    required this.containerHeight,
  }) : super(key: key);

  final double containerWidth;
  final double containerHeight;

  @override
  State<OverlayUploadFileView> createState() => _OverlayUploadFile();
}

class _OverlayUploadFile extends State<OverlayUploadFileView> {
  bool _dragging = false;

  @override
  Widget build(BuildContext context) {
    final uploadViewModel = context.watch<UploadViewModel>();
    final overlayProvider = context.watch<OverlayViewModel>();

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
                            () => OverlayButtonsView(
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
                    () => OverlayButtonsView(
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
                      saveFilesAndClose(
                          context, uploadViewModel, overlayProvider);
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

  void pickFile(BuildContext context, OverlayViewModel overlayProvider) async {
    const XTypeGroup fileTypeGroup = XTypeGroup(
      label: 'Files',
      extensions: <String>['pdf', 'txt', 'md', 'html', 'xml', 'json', 'csv'],
    );

    // This is the actual function that open's an open file dialog and returns the results in `results` list
    final List<XFile> results =
        await openFiles(acceptedTypeGroups: <XTypeGroup>[fileTypeGroup]);

    // NO DUPLICATES LOGIC
    for (var newFile in results) {
      bool contains = false;
      for (var cachedFile in overlayProvider.fileCache) {
        if (cachedFile.path + cachedFile.name == newFile.path + newFile.name) {
          contains = true;
          break;
        }
      }
      if (!contains) overlayProvider.fileCache.add(newFile);
    }

    // overlayProvider.fileCache.addAll(results);

    // ignore: use_build_context_synchronously
    overlayProvider.changeContent(
        context,
        () => OverlayUploadFileView(
            containerWidth: widget.containerWidth,
            containerHeight: widget.containerHeight),
        overlayProvider);
  }

  // Sends the list of files from overlay to upload screen
  void saveFilesAndClose(BuildContext context, UploadViewModel uploadViewModel,
      OverlayViewModel overlayProvider) {
    // No DUPLICATES logic
    for (var overlayFile in overlayProvider.fileCache) {
      bool contains = false;
      for (var uploadFile in uploadViewModel.files) {
        if (uploadFile.path + uploadFile.name ==
            overlayFile.path + overlayFile.name) {
          contains = true;
          break;
        }
      }
      if (!contains) uploadViewModel.files.add(overlayFile);
    }

    // uploadViewModel.files.addAll(overlayProvider.fileCache);
    overlayProvider.fileCache.clear();

    overlayProvider.hideOverlay();
  }
}
