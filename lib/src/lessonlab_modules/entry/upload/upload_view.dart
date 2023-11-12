import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/files_container.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay_provider.dart';

class UploadView extends StatelessWidget {
  const UploadView(
      {super.key,
      this.pdfItems = const ["Sample.pdf", "Sample2.pdf"],
      this.urlItems = const ["url1", "url2"],
      this.textItems = const ["another.txt"]});

  static const routeName = '/upload';

  final List<String> pdfItems;
  final List<String> urlItems;
  final List<String> textItems;

  @override
  Widget build(BuildContext context) {
    final overlayProvider = context.watch<OverlayProvider>();

    return Scaffold(
      appBar: const LessonLabAppBar(),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(180.0, 30.0, 180.0, 60.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // Adjust as needed
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 4.0),
                child: Text(
                  'PDF',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FileContainer(items: pdfItems),
              const Padding(
                padding: EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 4.0),
                child: Text(
                  'URL',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FileContainer(items: urlItems),
              const Padding(
                padding: EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 4.0),
                child: Text(
                  'Text',
                  style: TextStyle(
                    fontSize: 30.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              FileContainer(items: textItems),
              const SizedBox(height: 16.0),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, 0.0, 180.0, 60.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.restorablePushNamed(
                  context,
                  MenuView.routeName,
                );
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150.0, 50.0), // Set the desired size
              ),
              child: const Text('Cancel'),
            ),
            const SizedBox(width: 30.0),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(150.0, 50.0), // Set the desired size
              ),
              child: const Text('Next'),
            ),
            const SizedBox(width: 30.0),
            FloatingActionButton(
              onPressed: () {
                overlayProvider.showOverlay(context);
              },
              tooltip: 'Add new document',
              child: const Icon(Icons.add),
            )
            // Add more items as needed
          ],
        ),
      ),
    );
  }
}


