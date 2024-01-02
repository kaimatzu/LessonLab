import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/upload_screen.dart';
import 'package:provider/provider.dart';

import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_view_model.dart';
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
      // DO NOT USE CONST HERE. FLUTTER IS FUCKING STUPID. THE UI WILL NOT RELOAD IF YOU USE CONST
      // ignore: prefer_const_constructors
      body: Padding(
          // ignore: prefer_const_constructors
          padding: EdgeInsets.fromLTRB(100.0, 30.0, 140.0, 60.0),
          // ignore: prefer_const_constructors
          child: UploadScreen()),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 180.0, 60.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            cancel,
            const SizedBox(width: 30.0),
            PrimaryButton(
              handlePress: () {
                if (uploadViewModel.hasFiles) {
                  // uploadViewModel.sendData();
                  // uploadViewModel.getData();
                  // Navigator.restorablePushNamed(
                  //   context,
                  //   LessonSpecificationsView.routeName,
                  // );
                  uploadViewModel.newLesson(context);
                } else {
                  null;
                }
              },
              text: 'New Lesson',
              enabled: uploadViewModel.hasFiles,
            ),
            const SizedBox(width: 30.0),
            PrimaryButton(
              handlePress: () {
                uploadViewModel.newQuiz(context);
              },
              text: 'New Quiz',
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
