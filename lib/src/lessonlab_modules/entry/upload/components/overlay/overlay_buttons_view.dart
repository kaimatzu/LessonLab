import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_upload_text_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_upload_url_view.dart';
import 'package:provider/provider.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_upload_file_view.dart';
class OverlayButtonsView extends StatelessWidget {
  
  const OverlayButtonsView({
    Key? key,
    required this.containerWidth,
    required this.containerHeight,
  }) : super(key: key);

  final double containerWidth;
  final double containerHeight;

  @override
  Widget build(BuildContext context) {
    final overlayProvider = context.watch<OverlayViewModel>();

    return Container(
      width: containerWidth,
      height: containerHeight,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 49, 51, 56),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () {
              overlayProvider.changeContent(context, () => OverlayUploadFileView(containerWidth: containerWidth, containerHeight: containerHeight), overlayProvider);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(300.0, 80.0),
            ),
            child: const Text(
              'Files',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              )),
          ),
          const SizedBox(height: 30.0),
          ElevatedButton(
            onPressed: () {
              overlayProvider.changeContent(context, () => OverlayUploadURLView(containerWidth: containerWidth, containerHeight: containerHeight), overlayProvider);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(300.0, 80.0),
            ),
            child: const Text(
              'URL',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              )),
          ),
          const SizedBox(height: 30.0),
          ElevatedButton(
            onPressed: () {
              overlayProvider.changeContent(context, () => OverlayUploadTextView(containerWidth: containerWidth, containerHeight: containerHeight), overlayProvider);
            },
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(300.0, 80.0),
            ),
            child: const Text(
              'Text',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
              )),
          ),
        ],
      ),
    );
  }
  
}

