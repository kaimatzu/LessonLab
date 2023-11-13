import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay_upload_text.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay_upload_url.dart';
import 'package:provider/provider.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay_provider.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay_upload_file.dart';
class OverlayButtons extends StatelessWidget {
  
  const OverlayButtons({
    Key? key,
    required this.containerWidth,
    required this.containerHeight,
  }) : super(key: key);

  final double containerWidth;
  final double containerHeight;

  @override
  Widget build(BuildContext context) {
    final overlayProvider = context.watch<OverlayProvider>();

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
              overlayProvider.changeContent(context, () => OverlayUploadFile(containerWidth: containerWidth, containerHeight: containerHeight), overlayProvider);
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
              overlayProvider.changeContent(context, () => OverlayUploadURL(containerWidth: containerWidth, containerHeight: containerHeight), overlayProvider);
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
              overlayProvider.changeContent(context, () => OverlayUploadText(containerWidth: containerWidth, containerHeight: containerHeight), overlayProvider);
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

