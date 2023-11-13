import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
import 'package:lessonlab/src/global_components/selection_card.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_view.dart';
import 'package:flutter_svg/flutter_svg.dart';

// TODO(hans): Add svg icon

class QuizTypeView extends StatelessWidget {
  const QuizTypeView({
    Key? key,
  }) : super(key: key);

  static const routeName = '/quiztype';

  static const yellow = Color.fromRGBO(241, 196, 27, 1);

  // final IconData multipleChoice = Icon(
  //   assetImage: AssetImage('assets/images/Multiple choice (icon).png'),
  //   size: 24,
  // );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(180.0, 30.0, 180.0, 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Text(
                  'Quiz',
                  style: TextStyle(
                    fontFamily: 'Roboto',
                    fontSize: 32.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Choose Type',
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
                              context, // TODO(hans): change to multiple choice quiz view
                              UploadView.routeName,
                            );
                          },
                          child: SelectionCard(
                            // TODO(hans): Add multiple choice icon
                            icon: SvgPicture.asset(
                              'assets/svg/multiple_choice.svg',
                              semanticsLabel: 'Multiple choice',
                            ),
                            text: 'Multiple choice',
                          ),
                        ),
                        const SizedBox(width: 50),
                        GestureDetector(
                          onTap: () {
                            Navigator.restorablePushNamed(
                              context, // TODO(hans): change to identification quiz view
                              UploadView.routeName,
                            );
                          },
                          child: SelectionCard(
                            // TODO(hans): Add identification icon
                            icon: SvgPicture.asset(
                              'assets/svg/identification.svg',
                              semanticsLabel: 'Identification',
                            ),
                            text: 'Identification',
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
