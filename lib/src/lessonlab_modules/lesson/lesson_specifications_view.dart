import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/components/dropdown_menu.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/components/input_field.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/results/lesson_result/lesson_result_view.dart';
import 'package:provider/provider.dart';

class LessonSpecificationsView extends StatelessWidget {
  const LessonSpecificationsView({
    Key? key,
  }) : super(key: key);

  static const routeName = '/specifications';

  @override
  Widget build(BuildContext context) {
    final lessonSpecificationsViewModel =
        context.watch<LessonSpecificationsViewModel>();

    return Scaffold(
      appBar: const LessonLabAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(180.0, 0.0, 180.0, 60.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lessonSpecificationsViewModel.formFields
              .map<Widget?>((formField) {
                if (formField.inputField != null) {
                  return formField
                      .inputField; 
                } else if (formField.dropdown != null) {
                  return formField
                      .dropdown;
                } else {
                  return null;
                }
              })
              .whereType<Widget>() // Filter out null values
              .toList(),
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 30.0, 180.0, 60.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            SecondaryButton(
              handlePress: () {
                Navigator.restorablePushNamed(
                  context,
                  UploadView.routeName,
                );
              },
              text: 'Cancel',
            ),
            const SizedBox(width: 30.0),
            PrimaryButton(
              handlePress: () {
                lessonSpecificationsViewModel.collectFormTextValues();
                lessonSpecificationsViewModel.sendData();
                lessonSpecificationsViewModel.getData();
                Navigator.restorablePushNamed(
                  context,
                  LessonResultView.routeName,
                );
              },
              text: 'Confirm',
              enabled: true,
            ),
          ],
        ),
      ),
    );
  }
}
