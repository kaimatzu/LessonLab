import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_import_export/lesson_export_connection_orchestrator.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_connection_orchestrator.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:developer' as developer;

import 'package:markdown/markdown.dart' as md;
import 'package:rinf/rinf.dart';
import 'package:lessonlab/messages/results/view_lesson_result/load_lesson.pb.dart'
    as streamMessage;
import 'dart:async';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/markdown_quill.dart';

import 'package:markdown/markdown.dart' as md;
import 'package:rinf/rinf.dart';
import 'package:lessonlab/messages/results/view_lesson_result/load_lesson.pb.dart'
    as streamMessage;
import 'dart:async';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/markdown_quill.dart';

import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_model.dart';



class LessonResultViewModel with ChangeNotifier {
  late final LessonResultModel _lessonResultModel;
  late final LessonResultConnectionOrchestrator
      _lessonResultConnectionOrchestrator;
  late final LessonExportConnectionOrchestrator
      _lessonExportConnectionOrchestrator;

  final _statusCode = 0;
  late final int _lessonId;
  late QuillController quillController;
  
  bool _done = false;
  bool get done => _done;
  set done(bool value) {
    _done = value;
  }

  String _lessonContent = "";
  String get lessonContent => _lessonContent;
  set lessonContent(String value) {
    _lessonContent = value;
  }

  LessonResultModel get lessonResultModel => _lessonResultModel;

  LessonResultViewModel() {
    _lessonResultModel = LessonResultModel.initialize();
    _lessonResultConnectionOrchestrator = LessonResultConnectionOrchestrator();
    loadViewContent();
  }

  // void regenerate() {
  //   developer.log(">>> regenerate");
  // }

  Future<void> returnToMenu(
      BuildContext context, MenuViewModel menuViewModel) async {
    // developer.log("Convert to md");   

    // final deltaToMd = DeltaToMarkdown();
    // lessonContent = deltaToMd.convert(quillController.document.toDelta());
    developer.log("Lesson content: $lessonContent", name: "returnToMenu");

    // developer.log("Convert to md");   

    // final deltaToMd = DeltaToMarkdown();
    // lessonContent = deltaToMd.convert(quillController.document.toDelta());
    developer.log("Lesson content: $lessonContent", name: "returnToMenu");

    await _lessonResultConnectionOrchestrator.saveLesson(lessonContent);

    developer.log("Load menu content");
    await menuViewModel.loadViewContent();
    

    if (!context.mounted) return;
    // ignore: use_build_context_synchronously
    Navigator.restorablePushNamed(
      context,
      MenuView.routeName,
    );
  }

  Future<void> loadViewContent() async {
    try {
      final result =
          await _lessonResultConnectionOrchestrator.getLessonResultModel();

      _lessonResultModel.cssContents = result.cssContents;
      _lessonResultModel.lesson.title = result.lesson.title;
      _lessonResultModel.lesson.content = result.lesson.content;
      _lessonResultModel.lesson.id = result.lesson.id;

      _lessonId = _lessonResultModel.lesson.id;
      
      notifyListeners();
    } catch (error) {
      // Handle errors
      developer.log('Error loading contents: $error', name: 'Error');
    }
  }

  Future<void> exportLesson(String lessonTitle) async {
    final FileSaveLocation? result = await getSaveLocation(acceptedTypeGroups: [
      const XTypeGroup(label: "LessonLab file (.lela)", extensions: [".lela"])
    ], suggestedName: "$lessonTitle.lela");
    if (result != null) {
      developer.log(result.path);
      _lessonExportConnectionOrchestrator.exportLesson(result.path);
    }
  }

    Future<void> regenerateSection(BuildContext context, String lessonContent, QuillController controller, ValueNotifier<bool> doneGeneratingNotifier) async {
      doneGeneratingNotifier.value = false;
      debugPrint("Lesson content to regenerate: $lessonContent");
      var dialogContent = await createInstructionDialog(context);
      debugPrint("Dialog content: $dialogContent");
      // _lessonOpenConnectionOrchestrator.
      if(dialogContent != null) {
        debugPrint("Opened lesson stream from flutter...");
        _lessonResultConnectionOrchestrator.reopenLessonStream(dialogContent, _lessonId, content: lessonContent);

        var selection = controller.selection;
        late StreamSubscription<RustSignal> streamSubscription;

        // var mdDocument = md.Document(
        //   encodeHtml: false,
        //   extensionSet: md.ExtensionSet.gitHubFlavored,
        // );

        controller.document.delete(selection.start, selection.extentOffset - selection.baseOffset);
        controller.moveCursorToPosition(selection.start);
        var currentCursorPos = selection.start;
        streamSubscription = rustBroadcaster.stream
        .where((rustSignal) => rustSignal.resource == streamMessage.ID)
        .listen((RustSignal rustSignal) {
        // Handle the stream data here
        final signal = streamMessage.StateSignal.fromBuffer(rustSignal.message!);
        final rinfMessage = signal.streamMessage;
        if (rinfMessage == "[LL_END_STREAM]") {
          streamSubscription.cancel();
          doneGeneratingNotifier.value = true;
        } else{
          debugPrint("In open lesson: $rinfMessage");
          controller.document.insert(currentCursorPos, rinfMessage);    
          currentCursorPos += rinfMessage.length;
          controller.moveCursorToPosition(currentCursorPos);
        }
      });
      controller.notifyListeners();
      }
    }

  Future<String?> createInstructionDialog(BuildContext context) async {
    final quillEditorController = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );

    return await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        titlePadding: const EdgeInsets.only(left: 16, top: 8),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('How would you like Lela to regenerate the text?'),
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            )
          ],
        ),
        content: SizedBox(
          width: 500,
          height: 150,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              SizedBox(
                height: 75,
                child: QuillEditor.basic(
                  configurations: QuillEditorConfigurations(
                    controller: quillEditorController,
                    readOnly: false,
                  ),
                ),
              ),
              // const SizedBox(height: 3),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(quillEditorController.plainTextEditingValue.text);
                  },
                  child: const Text("Confirm"),
                ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}

// Future<String> _loadFileContents(String filePath) async {
//   return await rootBundle.loadString(filePath);
// }
