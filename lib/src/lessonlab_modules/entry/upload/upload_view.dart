import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view.dart';

class UploadView extends StatelessWidget {
  const UploadView({
    super.key,
  });

  static const routeName = '/upload';
  
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: const LessonLabAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(180.0, 30.0, 180.0, 60.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Adjust as needed
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.restorablePushNamed(
                      context,
                      MenuView.routeName,
                    );
                  },
                  child: const Text('Cancel'),
                ),
                // Add more items as needed
              ],
            ),
            const SizedBox(height: 16.0),
            
          ],
        ),
      ),
    );
  }
}
