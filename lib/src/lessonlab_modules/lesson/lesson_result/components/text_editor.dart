// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_view_model.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'package:rinf/rinf.dart';
import 'package:lessonlab/messages/results/view_lesson_result/load_lesson.pb.dart'
    as streamMessage;

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/markdown_quill.dart';
import 'dart:async';

const List<Widget> icons = <Widget>[
  Icon(Icons.code),
  Icon(Icons.html),
];

class TextEditor extends StatefulWidget {
  const TextEditor({
    Key? key,
  }) : super(key: key);

  @override
  State<TextEditor> createState() => _TextEditor();
}

class _TextEditor extends State<TextEditor> {
  var _doneGenerating = false;
  // var mdContentFinal = "a";
  // var htmlContent = "";
  // var noStreamValue = 0;
  // late TextEditingController textController;
  final QuillController _controller = QuillController.basic();
  late StreamSubscription<RustSignal> streamSubscription;
  String message = "Nothing received yet";

  @override
  void initState() {
    super.initState();

    // Start listening to the stream in initState
    streamSubscription = rustBroadcaster.stream
        .where((rustSignal) => rustSignal.resource == streamMessage.ID)
        .listen((RustSignal rustSignal) {
      // Handle the stream data here
      final signal = streamMessage.StateSignal.fromBuffer(rustSignal.message!);
      final rinfMessage = signal.streamMessage;
      debugPrint(rinfMessage);
      if (rinfMessage == "[LL_END_STREAM]") {
        _doneGenerating = true;
        // lessonResultViewModel.done = true;
      } else {
        _controller.document.insert(_controller.plainTextEditingValue.text.length - 1, rinfMessage);
      }
      setState(() {
        // message = rinfMessage;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // final lessonResultViewModel = context.watch<LessonResultViewModel>();

    // var message = "";

    var mdDocument = md.Document(
        encodeHtml: false,
        extensionSet: md.ExtensionSet.gitHubFlavored,
        // you can add custom syntax.
        blockSyntaxes: [const EmbeddableTableSyntax()]);

    final mdToDelta = MarkdownToDelta(
      markdownDocument: mdDocument,

      // // you can add custom attributes based on tags
      // customElementToBlockAttribute: {
      //   'h4': (element) => [HeaderAttribute(level: 4)],
      // },
      // // custom embed
      // customElementToEmbeddable: {
      //   EmbeddableTable.tableType: EmbeddableTable.fromMdSyntax,
      // },
    );

    // const markdown = "# test";

    // var html = md.markdownToHtml(markdown);

    var toolbar = QuillToolbar.simple(
      configurations: QuillSimpleToolbarConfigurations(
          controller: _controller,
          buttonOptions: QuillSimpleToolbarButtonOptions(
              base: QuillToolbarBaseButtonOptions(
                iconTheme: QuillIconTheme(
                  iconButtonSelectedData: IconButtonData(
                    color: Colors.amber,
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.amberAccent,
                    ),
                  ),
                  iconButtonUnselectedData: IconButtonData(
                    color: Colors.amber,
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.amberAccent,
                    ),
                  ),
                ),
              ),
              selectHeaderStyleButtons:
                  QuillToolbarSelectHeaderStyleButtonsOptions(
                      iconTheme: QuillIconTheme(
                iconButtonSelectedData: IconButtonData(
                  color: Colors.amber,
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.amberAccent,
                  ),
                ),
                iconButtonUnselectedData: IconButtonData(
                  color: Colors.amber,
                  style: IconButton.styleFrom(
                    foregroundColor: Colors.amberAccent,
                  ),
                ),
              )),
              selectHeaderStyleDropdownButton:
                  QuillToolbarSelectHeaderStyleDropdownButtonOptions(
                      textStyle: TextStyle(color: Colors.amber))),
          headerStyleType: HeaderStyleType.original,
          // Maybe re-add these once things are figured out, but disable it for now.
          showFontSize: false,
          showSuperscript: false,
          showSubscript: false,
          showFontFamily: false,
          showColorButton: false,
          showBackgroundColorButton: false,
          customButtons: [
            QuillToolbarCustomButtonOptions(
                icon: Icon(Icons.restart_alt),
                tooltip: "Regenerate",
                iconTheme: QuillIconTheme(
                  iconButtonSelectedData: IconButtonData(
                    color: Colors.amber,
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.amberAccent,
                    ),
                  ),
                  iconButtonUnselectedData: IconButtonData(
                    color: Colors.amber,
                    style: IconButton.styleFrom(
                      foregroundColor: Colors.amberAccent,
                    ),
                  ),
                ),
                onPressed: () {
                  // quillPageNotifier.regenerateSection(_controller);
                  debugPrint("Regenerate section of text");
                }),
            QuillToolbarCustomButtonOptions(
                icon: Icon(Icons.add_outlined),
                tooltip: "Continue lesson from this point",
                onPressed: () {
                  // quillPageNotifier.regenerateSection(_controller);
                  debugPrint("Continue");
                }),
          ]),
    );

    var editor = QuillEditor.basic(
        // Pass the controller to QuillEditor
        configurations: QuillEditorConfigurations(
      controller: _controller,
      autoFocus: true,
      readOnly: !_doneGenerating,
      padding: EdgeInsets.only(left: 30, top: 5, right: 30, bottom: 30),
      customStyles: DefaultStyles(
          h1: DefaultTextBlockStyle(
              TextStyle(
                  color: Colors.amber,
                  fontSize: 30,
                  fontWeight: FontWeight.w700),
              VerticalSpacing(16, 0),
              VerticalSpacing(0, 0),
              null),
          h2: DefaultTextBlockStyle(
              TextStyle(
                  color: Colors.amber,
                  fontSize: 25,
                  fontWeight: FontWeight.w500),
              VerticalSpacing(16, 0),
              VerticalSpacing(0, 0),
              null),
          h3: DefaultTextBlockStyle(
              TextStyle(
                  color: Colors.amber,
                  fontSize: 20,
                  fontWeight: FontWeight.w500),
              VerticalSpacing(16, 0),
              VerticalSpacing(0, 0),
              null),
          paragraph: DefaultTextBlockStyle(
              TextStyle(
                color: Colors.amber,
                fontSize: 15,
              ),
              VerticalSpacing(16, 0),
              VerticalSpacing(0, 0),
              null),
          strikeThrough: TextStyle(
              color: Colors.amber, decoration: TextDecoration.lineThrough),
          sizeSmall: TextStyle(color: Colors.amber),
          italic: TextStyle(color: Colors.amber, fontStyle: FontStyle.italic),
          bold: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
          underline: TextStyle(
              color: Colors.amber, decoration: TextDecoration.underline),
          color: Colors.amber),
    )
        // textSelectionThemeData: TextSelectionThemeData(selectionColor: Colors.amber)
        );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Insert text area here
          Center(
              child: Container(
            height:
                400, // TODO: Need to change this into dynamic depending on screen size
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 49, 51, 56),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Column(
              children: [
                toolbar,
                // VerticalDivider(width: 2.0, color: Colors.black), // Doesn't seem to work
                Expanded(
                  child: editor,
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // Cancel the stream subscription in dispose
    streamSubscription.cancel();
    super.dispose();
  }
}
