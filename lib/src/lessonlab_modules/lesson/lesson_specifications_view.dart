import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_specifications_view_model.dart';
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
        padding: const EdgeInsets.fromLTRB(180.0, 32.0, 180.0, 32.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: lessonSpecificationsViewModel.formFields
                .map<Widget?>((formField) {
                  if (formField.inputField != null) {
                    return formField.inputField;
                  } else if (formField.textArea != null) {
                    return formField.textArea;
                  } else if (formField.dropdown != null) {
                    return formField.dropdown;
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
            PrimaryButton(
              handlePress:  () async {
                lessonSpecificationsViewModel.selectLessonSavePath(context, lessonSpecificationsViewModel.saveTargetController);
              },
              text: "Save Path  ", 
            enabled: true
            ),
            const SizedBox(width: 8.0),
            SizedBox(
              width: 300,
              height: 50,
              child: TextField(
                controller: lessonSpecificationsViewModel.saveTargetController,
                style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 49, 51, 56),
                border: OutlineInputBorder(),
                hintText: "no save directory",
                hintStyle: TextStyle(
                    fontFamily: 'Roboto, Inter, Arial',
                    color: Colors.grey,
                  ),
                ),
                enabled: false, 
              ),
            ),
            const SizedBox(width: 60.0),
            SecondaryButton(
              handlePress: () {
                lessonSpecificationsViewModel.cancelLesson(context);
              },
              text: 'Cancel',
            ),
            const SizedBox(width: 30.0),
            PrimaryButton(
              handlePress: () {
                lessonSpecificationsViewModel.addCustomSpecifications();
              },
              text: 'Add',
              enabled: true,
            ),
            const SizedBox(width: 30.0),
            PrimaryButton(
              handlePress: () {
                lessonSpecificationsViewModel.collectFormTextValues();
                lessonSpecificationsViewModel.sendData();
                lessonSpecificationsViewModel.getData();
                lessonSpecificationsViewModel.generateLesson(context);
              },
              text: 'Generate',
              enabled: true,
            ),
          ],
        ),
      ),
    );
  }
}
