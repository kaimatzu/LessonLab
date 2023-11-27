import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_view_model.dart';
import 'package:provider/provider.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_buttons_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_view_model.dart';

class OverlayUploadURLView extends StatefulWidget {
  const OverlayUploadURLView({
    Key? key,
    required this.containerWidth,
    required this.containerHeight,
  }) : super(key: key);

  final double containerWidth;
  final double containerHeight;

  @override
  State<OverlayUploadURLView> createState() => _OverlayUploadURLState();
}
class _OverlayUploadURLState extends State<OverlayUploadURLView> {
  late TextEditingController urlTextAreaController;

  @override
  void initState() {
    super.initState();
    urlTextAreaController = TextEditingController();
  }

  @override
  void dispose() {
    urlTextAreaController.dispose();
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
          Padding(
            padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 60.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    height: overlayProvider.containerHeight - 113,
                    width: overlayProvider.containerWidth - 30,
                    decoration: BoxDecoration(
                      border: Border.all(
                          color: Colors.white,
                          width: 1.0), // Add this line for border
                      borderRadius: BorderRadius.circular(
                          8.0), // Add this line for rounded corners
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            primary: false,
                            itemCount: overlayProvider.urlCache.length,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: ListTile(
                                    tileColor: Colors.white,
                                    leading: const Icon(Icons.link,
                                        color: Colors.black),
                                    title: Text(
                                      overlayProvider.urlCache[index],
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(8.0, 20.0, 8.0, 0),
                            child: Center(
                              child: SizedBox(
                                width: widget.containerWidth - 20, // Adjust as needed
                                height: 54, // Adjust as needed
                                child: TextField(
                                    controller: urlTextAreaController,
                                    decoration: const InputDecoration(
                                      border: OutlineInputBorder(),
                                      hintText: 'Enter your url here...',
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                    maxLines: 1),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
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
            bottom: 45,
            left: overlayProvider.containerWidth / 2 - 60,
            child: ElevatedButton.icon(
              onPressed: () {
                addURL(context, overlayProvider);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                minimumSize: const Size(60.0, 40.0),
              ),
              icon: const Icon(Icons.add),
              label: const Text('New'),
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
                    saveURLAndClose(context, uploadViewModel, overlayProvider);
                  },
                  tooltip: 'Add new Text resource',
                  backgroundColor: overlayProvider.urlCache.isNotEmpty
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

  void addURL(BuildContext context, OverlayViewModel overlayProvider) {
    final String url = urlTextAreaController.text;

    overlayProvider.urlCache.add(url);
    urlTextAreaController.text = '';
    
    overlayProvider.changeContent(
        context,
        () => OverlayUploadURLView(
            containerWidth: widget.containerWidth,
            containerHeight: widget.containerHeight),
        overlayProvider);
  }

  void saveURLAndClose(BuildContext context, UploadViewModel uploadViewModel, OverlayViewModel overlayProvider) {
    uploadViewModel.urlFiles.addAll(overlayProvider.urlCache);
    overlayProvider.urlCache.clear();
    
    overlayProvider.hideOverlay();
  }
}
