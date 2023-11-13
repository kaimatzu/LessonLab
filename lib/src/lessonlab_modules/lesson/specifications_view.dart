import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/components/dropdown_menu.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/components/input_field.dart';

class SpecificationsView extends StatelessWidget {
  const SpecificationsView({
    super.key,
  });

  static const routeName = '/specifications';

  @override
  Widget build(BuildContext context) {

    return const Scaffold(
      appBar: LessonLabAppBar(),
      body:Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InputFields(label: 'Title', hintLabel: 'Enter lesson title'),
              InputFields(label: 'Timeframe', hintLabel: 'Enter timeframe'),
              Dropdown()
            ],
          ),
        )
    );
  }
}
