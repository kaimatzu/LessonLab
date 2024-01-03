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
    var paddingBetweenButtons = const SizedBox(width: 30.0);

    return Scaffold(
      appBar: const LessonLabAppBar(),
<<<<<<< HEAD
<<<<<<< HEAD
      body: Row(
        children: [
          // Left side
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 30.0, 0.0, 0.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  color: const Color.fromARGB(255, 240, 240, 240),
                ),
                padding: const EdgeInsets.all(25.0),
                height: 1000,
                width: 800,
                child: Stack(
                  children: [
                    // Ignore the warning here and DO NOT use const
                    Padding(
                      padding: const EdgeInsets.only(bottom: 80.0),
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            UploadScreen()
                          ],
                        )
                      ),
                    ),
                    Positioned(
                      bottom: 15.0,
                      child: Container(
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
                          tooltip: 'Add New Document',
                          child: const Icon(Icons.add),
                        ),
                      ),
                    )
                  ],
                )
              )
            ),
          ),
          // Right side
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(30.0, 0.0, 0.0, 0.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.fromLTRB(20.0, 50.0, 6.0, 0.0),
                    child: const Text(
                      '\n1) Select source type to upload by\n\t\t clicking the + icon.\n\n2) Upload a PDF file, paste a URL,\n\t\tor provide a text.\n\n3) Select New Lesson to generate\n\t\ta lesson, or New Quiz to generate\n\t\tan interactive quiz!',
                      style: TextStyle(fontSize: 16.0, color: Color.fromRGBO(49, 51, 56, 1), fontWeight: FontWeight.w500),
                    ),
=======
=======
>>>>>>> 8754148bd8ed411e1756cfda6e65bb9de535fcec
      // ignore: prefer_const_constructors
      body: Padding(
          padding: const EdgeInsets.fromLTRB(100.0, 30.0, 140.0, 60.0),
          // ignore: prefer_const_constructors
          child: UploadScreen()),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 180.0, 60.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            cancel,
            paddingBetweenButtons,
            newLesson,
            paddingBetweenButtons,
            newQuiz,
            paddingBetweenButtons,
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
>>>>>>> 8754148 (Impl delete in config.json)
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        cancel,
                        const SizedBox(width: 15.0),
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
                          width: 120.0
                        ),
                        const SizedBox(width: 15.0),
                        PrimaryButton(
                          handlePress: () {
                            uploadViewModel.newQuiz(context);
                          },
                          text: 'New Quiz',
                          enabled: uploadViewModel.hasFiles,
                          width: 120.0
                        ),
                        const SizedBox(width: 15.0),
                      ],
                    ),
                  ),
                ]
                
              ),
            ),
          ),
        ],
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
