import 'package:file_selector/file_selector.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_controller.dart';

// typedef Source = String | TextFile;

class UploadSourcesModel {
  final _pdfFilePaths = <XFile>[];
  final _urls = <String>[];
  final _texts = <TextFile>[];

  // Source getAllSources() {
  //   const Source temp = [];
  //   temp.addAll(pdfFilePaths);
  //   temp.addAll(urls);
  //   temp.addAll(texts);

  //   return temp;
  // }

  List<XFile> get pdfFilePaths => _pdfFilePaths;
  List<String> get urls => _urls;
  List<TextFile> get texts => _texts;

  // String getSource() {}
}
