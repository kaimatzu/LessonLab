import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'package:lessonlab/src/global_components/secondary_button.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/components/dropdown_menu.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/components/input_field.dart';
import 'package:lessonlab/src/lessonlab_modules/material_selection/material_selection_view.dart';

class SpecificationsView extends StatelessWidget {
  const SpecificationsView({
    super.key,
  });

  static const routeName = '/specifications';

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: const LessonLabAppBar(),
      body:Padding(
          padding: const EdgeInsets.fromLTRB(180.0, 0.0, 180.0, 60.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const InputFields(label: 'Title', hintLabel: 'Enter lesson title'),
                const InputFields(label: 'Focus Topic', hintLabel: 'Enter focus of the lesson'),
                const InputFields(label: 'Timeframe', hintLabel: 'Enter timeframe'),
                const InputFields(label: 'Learning Outcomes', hintLabel: 'Enter learning outcomes'),
                const Dropdown(),
                Padding(
                padding: const EdgeInsets.fromLTRB(0.0, 30.0, 16.0, 0.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      SecondaryButton(
                        handlePress: () {
                          Navigator.restorablePushNamed(
                            context, 
                            UploadView.routeName
                            );
                        },
                        text: 'Cancel',
                      ),
                      const SizedBox(width: 30.0),
                      PrimaryButton(
                        handlePress: () {},
                        text: 'Confirm',
                        enabled: true,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        )
    );
  }
}
