import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
import 'package:lessonlab/src/global_components/selection_card.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/specifications_view.dart';
import 'package:lessonlab/src/lessonlab_modules/quiz/quiz_type/quiz_type_view.dart';

class MaterialSelectionView extends StatelessWidget {
  const MaterialSelectionView({super.key});

  static const routeName = '/materialselection';

  static const yellow = Color.fromRGBO(241, 196, 27, 1);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(180.0, 30.0, 180.0, 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Choose Material',
                          style: TextStyle(
                            fontFamily: 'Roboto',
                            fontSize: 56.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.restorablePushNamed(
                              context, // TODO(hans): change to lesson specs view
                              SpecificationsView.routeName,
                            );
                          },
                          child: SelectionCard(
                            // TODO(hans): Add new lesson icon
                            icon: SvgPicture.asset(
                              'assets/svg/multiple_choice.svg',
                              semanticsLabel: 'New Lesson',
                            ),
                            text: 'New Lesson',
                          ),
                        ),
                        const SizedBox(width: 50),
                        GestureDetector(
                          onTap: () {
                            Navigator.restorablePushNamed(
                              context, // TODO(hans): change to quiz specs view
                              QuizTypeView.routeName,
                            );
                          },
                          child: SelectionCard(
                            // TODO(hans): Add new quiz icon
                            icon: SvgPicture.asset(
                              'assets/svg/identification.svg',
                              semanticsLabel: 'New Quiz',
                            ),
                            text: 'New Quiz',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.fromLTRB(56.0, 32.0, 100.0, 32.0),
        child: SecondaryButton(
          handlePress: () {
            Navigator.restorablePushNamed(context, UploadView.routeName);
          },
          text: "Cancel",
        ),
      ),
    );
  }
}
