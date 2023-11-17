import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_view.dart';

class MenuViewModel with ChangeNotifier {
  void newMaterial(BuildContext context) {
    Navigator.restorablePushNamed(
      context,
      UploadView.routeName,
    );
  }
}
