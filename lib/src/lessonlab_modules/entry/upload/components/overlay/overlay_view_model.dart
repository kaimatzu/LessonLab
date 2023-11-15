import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_buttons_view.dart';

class OverlayViewModel extends ChangeNotifier {
  OverlayEntry? _overlayEntry;
  Widget _currentContent =
      const OverlayButtonsView(containerWidth: 480, containerHeight: 400);

  bool get isOverlayVisible => _overlayEntry != null;

  final double containerWidth = 480;
  final double containerHeight = 400;

  // File
  var fileCache = <XFile>[];

  // URL
  var urlCache = <String>[];

  // Text needs no cache.

  void showOverlay(BuildContext context) {
    _overlayEntry = OverlayEntry(
      builder: (BuildContext context) => Positioned(
        top: MediaQuery.of(context).size.height / 2 - (containerHeight / 2),
        left: MediaQuery.of(context).size.width / 2 - (containerWidth / 2),
        child: Material(
          color: Colors.transparent,
          child: Stack(
            children: [
              _currentContent,
              Positioned(
                top: 0,
                right: 0,
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () {
                    hideOverlay();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlayEntry!);
    notifyListeners();
  }

  void hideOverlay() {
    if (_overlayEntry != null) {
      _overlayEntry!.remove();
      _overlayEntry = null;

      fileCache.clear();
      urlCache.clear();

      _currentContent = OverlayButtonsView(
          containerWidth: containerWidth, containerHeight: containerHeight);
      notifyListeners();
    }
  }

  void changeContent(BuildContext context, Widget Function() newContent,
      OverlayViewModel overlayProvider) {
    _currentContent = newContent();
    if (overlayProvider.isOverlayVisible) {
      _overlayEntry!.remove();
      _overlayEntry = null;

      notifyListeners();
    }

    overlayProvider.showOverlay(context);
  }
}

class TextFile {
  final String title;
  final String content;

  TextFile({required this.title, required this.content});
}
