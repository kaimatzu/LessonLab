import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/resources_container.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_controller.dart';

class UploadView extends StatelessWidget {
  const UploadView({Key? key}) : super(key: key);

  static const routeName = '/upload';

  @override
  Widget build(BuildContext context) {
    final uploadViewModel = context.watch<UploadViewModel>();
    final overlayProvider = context.watch<OverlayController>();

    uploadViewModel.hasFiles = uploadViewModel.files.isNotEmpty ||
        uploadViewModel.urls.isNotEmpty ||
        uploadViewModel.textFiles.isNotEmpty;

    const noFilesStyle = TextStyle(color: Colors.grey);
    const fileNameTextStyle =
        TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold);
    const emptyPadding = EdgeInsets.fromLTRB(14.0, 6.0, 14.0, 4.0);
    const filePadding = EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 4.0);

    const txtFiles = Text('Files', style: fileNameTextStyle);
    const txtNoFiles = Text('No files available', style: noFilesStyle);
    const txtUrl = Text('URL', style: fileNameTextStyle);
    const txtNoUrl = Text('No URLs available ', style: noFilesStyle);
    const txtText = Text('Text', style: fileNameTextStyle);
    const txtNoText = Text('No text available.', style: noFilesStyle);

    return Scaffold(
      appBar: const LessonLabAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(180.0, 30.0, 180.0, 60.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Adjust as needed
            children: [
              const Padding(
                padding: filePadding,
                child: txtFiles,
              ),
              ResourcesContainer(
                items: uploadViewModel.files,
                icon: const Icon(Icons.file_open, color: Colors.white),
              ),
              if (uploadViewModel.files.isEmpty)
                const Padding(
                  padding: emptyPadding,
                  child: txtNoFiles,
                ),
              const Padding(
                padding: filePadding,
                child: txtUrl,
              ),
              ResourcesContainer(
                items: uploadViewModel.urls,
                icon: const Icon(Icons.link, color: Colors.white),
              ),
              if (uploadViewModel.urls.isEmpty)
                const Padding(
                  padding: emptyPadding,
                  child: txtNoUrl,
                ),
              const Padding(
                padding: filePadding,
                child: txtText,
              ),
              ResourcesContainer(
                items: uploadViewModel.textFiles,
                icon: const Icon(Icons.description, color: Colors.white),
              ),
              if (uploadViewModel.textFiles.isEmpty)
                const Padding(
                  padding: emptyPadding,
                  child: txtNoText,
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
                uploadViewModel.cancelUpload(context);
              },
              text: 'Cancel',
            ),
            const SizedBox(width: 30.0),
            PrimaryButton(
              handlePress: () {
                if (uploadViewModel.hasFiles) {
                  uploadViewModel.sendData();
                  uploadViewModel.getData();
                  Navigator.restorablePushNamed(
                    context,
                    LessonSpecificationsView.routeName,
                  );
                } else {
                  null;
                }
              },
              text: 'New lesson',
              enabled: uploadViewModel.hasFiles,
            ),
            const SizedBox(width: 30.0),
            PrimaryButton(
              handlePress: () {
                uploadViewModel.newQuiz(context);
              },
              text: 'New quiz',
              enabled: uploadViewModel.hasFiles,
            ),
            const SizedBox(width: 30.0),
            Container(
              decoration: BoxDecoration(
                // borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color:
                        const Color.fromRGBO(241, 196, 27, 1).withOpacity(.3),
                    spreadRadius: 3,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  overlayProvider.showOverlay(context);
                },
                elevation: 0,
                tooltip: 'Add new document',
                child: const Icon(Icons.add),
              ),
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
