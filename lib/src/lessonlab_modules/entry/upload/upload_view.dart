import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_view_model.dart';
import 'package:provider/provider.dart';
import 'dart:developer' as developer;

import 'dart:io';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/resources_container.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_view_model.dart';

class UploadView extends StatefulWidget {
  const UploadView({Key? key}) : super(key: key);

  static const routeName = '/upload';

  @override
  State<UploadView> createState() => _UploadViewState();
}

class _UploadViewState extends State<UploadView> {
  @override
  Widget build(BuildContext context) {
    final uploadViewModel = context.watch<UploadViewModel>();
    final overlayProvider = context.watch<OverlayViewModel>();

    const noFilesStyle = TextStyle(color: Colors.grey);
    const fileNameTextStyle =
        TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold);

    void onBodyClick() {
      if (overlayProvider.isOverlayVisible) overlayProvider.hideOverlay();
    }

    return Scaffold(
      appBar: const LessonLabAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(180.0, 30.0, 180.0, 60.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Adjust as needed
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 4.0),
                child: Text(
                  'Files',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ResourcesContainer(
                  items: uploadViewModel.files,
                  icon: const Icon(Icons.file_open, color: Colors.white)),
              if (uploadViewModel.files.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(14.0, 6.0, 14.0, 4.0),
                  child: Text(
                    'No files available.',
                    style: noFilesStyle,
                  ),
                ),
              const Padding(
                padding: EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 4.0),
                child: Text(
                  'URL',
                  style: fileNameTextStyle,
                ),
              ),
              ResourcesContainer(
                  items: uploadViewModel.urlFiles,
                  icon: const Icon(Icons.link, color: Colors.white)),
              if (uploadViewModel.urlFiles.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(14.0, 6.0, 14.0, 4.0),
                  child: Text(
                    'No URLs available.',
                    style: noFilesStyle,
                  ),
                ),
              const Padding(
                padding: EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 4.0),
                child: Text(
                  'Text',
                  style: fileNameTextStyle,
                ),
              ),
              ResourcesContainer(
                  items: uploadViewModel.textFiles,
                  icon: const Icon(Icons.description, color: Colors.white)),
              if (uploadViewModel.textFiles.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(14.0, 6.0, 14.0, 4.0),
                  child: Text(
                    'No text available.',
                    style: noFilesStyle,
                  ),
                ),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 180.0, 60.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.restorablePushNamed(
                  context,
                  MenuView.routeName,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150.0, 50.0),
              ),
              child: const Text('Cancel'),
            ),
            // TODO(hans): change to new lesson and new quiz button that redirects to the corresponding page
            const SizedBox(width: 30.0),
            ElevatedButton(
              onPressed: () {
                if (uploadViewModel.files.isNotEmpty ||
                    uploadViewModel.urlFiles.isNotEmpty ||
                    uploadViewModel.textFiles.isNotEmpty) {
                  uploadViewModel.sendData();
                  uploadViewModel.getData();
                } else {
                  null;
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: uploadViewModel.files.isNotEmpty ||
                        uploadViewModel.urlFiles.isNotEmpty ||
                        uploadViewModel.textFiles.isNotEmpty
                    ? Colors.amber
                    : const Color.fromARGB(162, 164, 127, 14),
                minimumSize: const Size(150.0, 50.0),
              ),
              child: const Text('Next'),
            ),
            const SizedBox(width: 30.0),
            FloatingActionButton(
              onPressed: () {
                overlayProvider.showOverlay(context);
              },
              tooltip: 'Add new document',
              child: const Icon(Icons.add),
            ),
            // Add more items as needed
          ],
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: overlayProvider.isOverlayVisible
          ? Stack(
              children: [
                ModalBarrier(
                  color: Colors.black.withOpacity(0.5),
                  dismissible: false,
                ),
                const Positioned.fill(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            )
          : Container(),
    );
  }
}
