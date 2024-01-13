import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/menu/menu_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_import_export/lesson_export_connection_orchestrator.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_connection_orchestrator.dart';
import 'package:file_selector/file_selector.dart';
import 'dart:developer' as developer;
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_model.dart';

import 'package:markdown/markdown.dart' as md;
import 'package:quill_html_converter/quill_html_converter.dart';
import 'package:rinf/rinf.dart';
import 'package:lessonlab/messages/results/open_finished_lesson/open_lesson.pb.dart'
    as streamMessage;
import 'dart:async';

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/markdown_quill.dart';

class LessonOpenViewModel with ChangeNotifier {
  late LessonOpenModel _lessonOpenModel;
  late LessonOpenConnectionOrchestrator
      _lessonOpenConnectionOrchestrator;
  late LessonExportConnectionOrchestrator
      _lessonExportConnectionOrchestrator;
  final _statusCode = 0;
  late int _lessonId;
  late QuillController quillController;

  bool _done = true;
  bool get done => _done;
  set done(bool value) {
    _done = value;
    // notifyListeners();
  }

  bool _instantiated = false;
  bool get instantiated => _instantiated;
  set instantiated(bool value) {
    _instantiated = value;
    // notifyListeners();
  }

  String _lessonContent = "";
  String get lessonContent => _lessonContent;
  set lessonContent(String value) {
    _lessonContent = value;
  }
  LessonOpenModel get lessonOpenModel => _lessonOpenModel;

  LessonOpenViewModel() {
     debugPrint("LessonOpenViewModel created!");
    // _lessonOpenModel = LessonOpenModel.initialize();
    // _lessonOpenConnectionOrchestrator = LessonOpenConnectionOrchestrator();
    // _lessonExportConnectionOrchestrator = LessonExportConnectionOrchestrator();
    // loadViewContent();
  }

  Future<void> initialize() async {
    _lessonOpenModel = LessonOpenModel.initialize();
    _lessonOpenConnectionOrchestrator = LessonOpenConnectionOrchestrator();
    _lessonExportConnectionOrchestrator = LessonExportConnectionOrchestrator();
  }

  Future<void> returnToMenu(BuildContext context, MenuViewModel menuViewModel) async {
    var delta = quillController.document.toDelta();
    lessonContent = delta.toHtml();
    await _lessonOpenConnectionOrchestrator.saveLesson(lessonContent, _lessonId);

    developer.log("Load menu content");
    await menuViewModel.loadViewContent();

    // ignore: use_build_context_synchronously
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> loadViewContent(int id) async {
    // if(!instantiated){
      // instantiated = true;
      _lessonId = id;

      try {
        final result =
            await _lessonOpenConnectionOrchestrator.getLessonOpenModel(id);

        _lessonOpenModel.cssContents = result.cssContents;
        _lessonOpenModel.lesson.title = result.lesson.title;
        _lessonOpenModel.lesson.content = result.lesson.content;

        notifyListeners();
      } catch (error) {
        // Handle errors
        developer.log('Error loading contents: $error', name: 'Error');
      }
    // }
  }

  Future<void> exportLesson(String lessonTitle) async {
    final FileSaveLocation? result =
      await getSaveLocation(
        acceptedTypeGroups: [
          const XTypeGroup(
            label: "LessonLab file (.lela)",
            extensions: [".lela"]
          )  
        ],
        suggestedName: "$lessonTitle.lela"
      );
    if (result != null) {
      developer.log(result.path);
      _lessonExportConnectionOrchestrator.exportLesson(result.path);
    }
  }

  Future<void> regenerateSection(BuildContext context, String lessonContent, QuillController controller, ValueNotifier<bool> doneGeneratingNotifier) async {
    debugPrint("Lesson content to regenerate: $lessonContent");
    var dialogContent = await createInstructionDialog(context);
    debugPrint("Dialog content: $dialogContent");
    // _lessonOpenConnectionOrchestrator.
    if(dialogContent != null) {
      doneGeneratingNotifier.value = false;
      debugPrint("Opened lesson stream from flutter...");
      _lessonOpenConnectionOrchestrator.reopenLessonStream(dialogContent, _lessonId, content: lessonContent);

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

  Future<void> continueLessonFromHere(BuildContext context, QuillController controller, ValueNotifier<bool> doneGeneratingNotifier) async {
    var dialogContent = await createInstructionDialog(context);
    debugPrint("Dialog content: $dialogContent");

    if(dialogContent != null) {
      doneGeneratingNotifier.value = false;
      debugPrint("Opened lesson stream from flutter...");
      _lessonOpenConnectionOrchestrator.reopenLessonStream(dialogContent, _lessonId);

      var selection = controller.selection;
      late StreamSubscription<RustSignal> streamSubscription;

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
