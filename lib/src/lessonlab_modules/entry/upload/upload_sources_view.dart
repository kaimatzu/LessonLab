// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/upload_screen.dart';
import 'package:provider/provider.dart';

import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications/lesson_specifications_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/resources_container.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_controller.dart';

class UploadSourcesView extends StatelessWidget {
  const UploadSourcesView({Key? key}) : super(key: key);

  static const routeName = '/upload';

  @override
  Widget build(BuildContext context) {
    final uploadViewModel = context.watch<UploadSourcesViewModel>();
    final overlayProvider = context.watch<OverlayController>();

    var cancel = SecondaryButton(
      handlePress: () => uploadViewModel.cancelUpload(context),
      text: 'Cancel',
    );
    var newLesson = PrimaryButton(
      handlePress: () {
        if (uploadViewModel.hasFiles) uploadViewModel.newLesson(context);
      },
      text: 'New lesson',
      enabled: uploadViewModel.hasFiles,
    );
    var newQuiz = PrimaryButton(
      handlePress: () => uploadViewModel.newQuiz(context),
      text: 'New quiz',
      enabled: uploadViewModel.hasFiles,
    );

    return Scaffold(
      appBar: const LessonLabAppBar(),
      body: Padding(
          padding: const EdgeInsets.fromLTRB(180.0, 30.0, 180.0, 60.0),
          child: UploadScreen()),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 180.0, 60.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            cancel,
            const SizedBox(width: 30.0),
            newLesson,
            const SizedBox(width: 30.0),
            newQuiz,
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
                onPressed: () => overlayProvider.showOverlay(context),
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
