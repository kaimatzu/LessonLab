import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/material_selection/material_selection_view.dart';
import 'package:provider/provider.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/resources_container.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay_provider.dart';

class UploadView extends StatelessWidget {
  const UploadView(
      {super.key});

  static const routeName = '/upload';

  @override
  Widget build(BuildContext context) {
    final overlayProvider = context.watch<OverlayProvider>();

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
              ResourcesContainer(items: overlayProvider.files, icon: const Icon(Icons.file_open, color: Colors.white)),
              if (overlayProvider.files.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(14.0, 6.0, 14.0, 4.0),
                  child: Text(
                    'No files available.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 4.0),
                child: Text(
                  'URL',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ResourcesContainer(items: overlayProvider.urlFiles, icon: const Icon(Icons.link, color: Colors.white)),
              if (overlayProvider.urlFiles.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(14.0, 6.0, 14.0, 4.0),
                  child: Text(
                    'No URLs available.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              const Padding(
                padding: EdgeInsets.fromLTRB(14.0, 14.0, 14.0, 4.0),
                child: Text(
                  'Text',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ResourcesContainer(items: overlayProvider.textFiles, icon: const Icon(Icons.description, color: Colors.white)),
              if (overlayProvider.textFiles.isEmpty)
                const Padding(
                  padding: EdgeInsets.fromLTRB(14.0, 6.0, 14.0, 4.0),
                  child: Text(
                    'No text available.',
                    style: TextStyle(color: Colors.grey),
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
            SecondaryButton(
              handlePress: () {
                Navigator.restorablePushNamed(context, MenuView.routeName);
              },
              text: 'Cancel',
            ),
            const SizedBox(width: 30.0),
            PrimaryButton(
              handlePress: () {
                Navigator.restorablePushNamed(
                  context,
                  MaterialSelectionView.routeName,
                );
              },
              text: 'Next',
            ),
            const SizedBox(width: 30.0),
            FloatingActionButton(
              onPressed: () {
                overlayProvider.showOverlay(context);
              },
              tooltip: 'Add new document',
              child: const Icon(Icons.add),
            )
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
