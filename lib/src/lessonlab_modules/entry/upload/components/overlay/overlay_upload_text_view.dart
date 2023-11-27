import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_view_model.dart';
import 'package:provider/provider.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_buttons_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_view_model.dart';

class OverlayUploadTextView extends StatefulWidget {
  const OverlayUploadTextView({
    Key? key,
    required this.containerWidth,
    required this.containerHeight,
  }) : super(key: key);

  final double containerWidth;
  final double containerHeight;

  @override
  State<OverlayUploadTextView> createState() => _OverlayUploadTextState();
}

class _OverlayUploadTextState extends State<OverlayUploadTextView> {
  late TextEditingController titleController;
  late TextEditingController contentController;

  bool _submittable = false;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController();
    contentController = TextEditingController();

    titleController.addListener(updateSubmitStatus);
    contentController.addListener(updateSubmitStatus);
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final uploadViewModel = context.watch<UploadViewModel>();
    final overlayProvider = context.watch<OverlayViewModel>();

    return Container(
      width: widget.containerWidth,
      height: widget.containerHeight,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 49, 51, 56),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Stack(
        children: [
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 0),
                child: Center(
                  child: SizedBox(
                    width: widget.containerWidth - 20, // Adjust as needed
                    height: 54, // Adjust as needed
                    child: TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your title here...',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 1
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8.0, 8.0, 8.0, 60.0),
                child: Center(
                  child: SizedBox(
                    width: widget.containerWidth - 20, // Adjust as needed
                    height: widget.containerHeight - 175, // Adjust as needed
                    child: TextField(
                      textAlignVertical: TextAlignVertical.top,
                      controller: contentController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter your content here...',
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: null,
                      minLines: null, 
                      expands: true,
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 15,
            left: 10,
            child: ElevatedButton(
              onPressed: () {
                overlayProvider.changeContent(
                    context,
                    () => OverlayButtonsView(
                        containerWidth: widget.containerWidth,
                        containerHeight: widget.containerHeight),
                    overlayProvider);
              },
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(120.0, 40.0),
              ),
              child: const Text('Back'),
            ),
          ),
          Positioned(
            bottom: 5,
            right: 5,
            child: SizedBox(
              height: 60.0,
              width: 60.0,
              child: FittedBox(
                child: FloatingActionButton(
                  onPressed: () {
                    saveText(context, uploadViewModel, overlayProvider);
                  },
                  tooltip: 'Add new Text resource',
                  backgroundColor: _submittable
                      ? Colors.amber
                      : const Color.fromARGB(162, 164, 127, 14),
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void updateSubmitStatus() {
    // Check if both text areas are non-empty
    final bool titleNotEmpty = titleController.text.isNotEmpty;
    final bool contentNotEmpty = contentController.text.isNotEmpty;

    setState(() {
      _submittable = titleNotEmpty && contentNotEmpty;
    });
  }

  void saveText(BuildContext context, UploadViewModel uploadViewModel, OverlayViewModel overlayProvider) {
    final String title = titleController.text;
    final String content = contentController.text;

    uploadViewModel.textFiles.add(TextFile(title: title, content: content));

    overlayProvider.changeContent(
        context,
        () => OverlayUploadTextView(
            containerWidth: widget.containerWidth,
            containerHeight: widget.containerHeight),
        overlayProvider);

    overlayProvider.hideOverlay();
  }
}
