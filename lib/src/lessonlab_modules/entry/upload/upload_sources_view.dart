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
      width: 120,
    );
    var newLesson = PrimaryButton(
      handlePress: () {
        if (uploadViewModel.hasFiles) uploadViewModel.newLesson(context);
      },
      text: 'New Lesson',
      enabled: uploadViewModel.hasFiles,
      width: 120,
    );
    var newQuiz = PrimaryButton(
      handlePress: () => uploadViewModel.newQuiz(context),
      text: 'New Quiz',
      enabled: uploadViewModel.hasFiles,
      width: 120,
    );
    var paddingBetweenButtons = const SizedBox(width: 15.0);

    return Scaffold(
      appBar: const LessonLabAppBar(),
      body: Stack(
        children: [
          Row(
            children: [
              // Left side
              Expanded(
                flex: 3,
                child: Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 30.0, 0.0, 0.0),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15.0),
                          color: const Color.fromARGB(255, 244, 245, 247),
                        ),
                        padding: const EdgeInsets.all(25.0),
                        margin: const EdgeInsetsDirectional.only(bottom: 30.0),
                        height: 600,
                        width: 800,
                        child: Stack(
                          children: [
                            // Ignore the warning here and DO NOT use const
                            // ignore: prefer_const_constructors
                            Padding(
                              padding: const EdgeInsets.only(bottom: 80.0),
                              // ignore: prefer_const_constructors
                              child: SingleChildScrollView(
                                  // ignore: prefer_const_constructors
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                // ignore: prefer_const_constructors, prefer_const_literals_to_create_immutables
                                children: [UploadScreen()],
                              )),
                            ),
                            Positioned(
                              bottom: 15.0,
                              child: Container(
                                decoration: BoxDecoration(
                                  // borderRadius: BorderRadius.circular(50),
                                  boxShadow: [
                                    BoxShadow(
                                      color: const Color.fromRGBO(241, 196, 27, 1)
                                          .withOpacity(.3),
                                      spreadRadius: 3,
                                      blurRadius: 15,
                                      offset: const Offset(0, 5),
                                    ),
                                  ],
                                ),
                                child: FloatingActionButton(
                                  onPressed: () =>
                                      overlayProvider.showOverlay(context),
                                  elevation: 0,
                                  tooltip: 'Add New Document',
                                  child: const Icon(Icons.add),
                                ),
                              ),
                            ),
                          ],
                        ))),
              ),
              // Right side
              Padding(
                padding: const EdgeInsets.fromLTRB(30.0, 0.0, 30.0, 0.0),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: const EdgeInsets.fromLTRB(30.0, 50.0, 6.0, 0.0),
                        child: const Text(
                          '\n1) Select source type to upload by\n\t\t clicking the + icon.\n\n2) Upload a PDF file, paste a URL,\n\t\tor provide a text.\n\n3) Select New Lesson to generate\n\t\ta lesson, or New Quiz to generate\n\t\tan interactive quiz!',
                          style: TextStyle(
                              fontSize: 16.0,
                              color: Color.fromRGBO(49, 51, 56, 1),
                              fontWeight: FontWeight.w500),
                        ),
                      ),
                      const Spacer(),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 40.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            cancel,
                            paddingBetweenButtons,
                            newLesson,
                            paddingBetweenButtons,
                            newQuiz,
                            paddingBetweenButtons,
                          ],
                        ),
                      ),
                    ]),
              ),
            ],
          ),
          if (overlayProvider.isOverlayVisible)
            ModalBarrier(
              color: Colors.black.withOpacity(0.5),
              dismissible: false,
            ),
        ]
      ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      // floatingActionButton: overlayProvider.isOverlayVisible
      //     ? Stack(
      //         children: [
      //           ModalBarrier(
      //             color: Colors.black.withOpacity(0.5),
      //             dismissible: false,
      //           ),
      //           const Positioned.fill(
      //             child: Center(
      //               child: CircularProgressIndicator(),
      //             ),
      //           ),
      //         ],
      //       )
      //     : Container(),
    );
  }
}
