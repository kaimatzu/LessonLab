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

const List<Widget> icons = <Widget>[
  Icon(Icons.code),
  Icon(Icons.html),
];

class TextEditor extends StatefulWidget {
  const TextEditor({
    Key? key,
    required this.title,
    required this.mdContents,
    required this.cssContents,
  }) : super(key: key);

  final String title;
  final String mdContents;
  final String cssContents;

  @override
  State<TextEditor> createState() => _TextEditor();
}

class _TextEditor extends State<TextEditor> {
  final List<bool> _richView = <bool>[true, false];
  var _doneGenerating = false;
  // var mdContentFinal = "a";
  // var htmlContent = "";
  // var noStreamValue = 0;
  // late TextEditingController textController;
  final QuillController _controller = QuillController.basic();
  @override
  Widget build(BuildContext context) {
    final lessonResultViewModel = context.watch<LessonResultViewModel>();

    
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

    var editor = StreamBuilder<RustSignal>(
        stream: rustBroadcaster.stream.where((rustSignal) {
      return rustSignal.resource == streamMessage.ID;
    }), builder: (context, snapshot) {
      final rustSignal = snapshot.data;
      if (rustSignal != null) {
        final signal = streamMessage.StateSignal.fromBuffer(
          rustSignal.message!,
        );
        final rinfMessage = signal.streamMessage;
        if (rinfMessage == "[LL_END_STREAM]") {
          _doneGenerating = true;
          lessonResultViewModel.done = true;
        } else {

          // _controller.moveCursorToEnd(); // <-- Cant do this because this calls notifyListeners somewhere along its function stack. 
          // mdContentFinal += rinfMessage;
          _controller.document.insert(_controller.plainTextEditingValue.text.length - 1, rinfMessage);

        }
      }
      return QuillEditor.basic(
          // Pass the controller to QuillEditor
        configurations: QuillEditorConfigurations(
        controller: _controller,
        autoFocus: true,
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
    }
        // child: QuillEditor.basic(
        //     // Pass the controller to QuillEditor
        //   configurations: QuillEditorConfigurations(
        //   controller: _controller,
        //   autoFocus: true,
        //   padding: EdgeInsets.only(left: 30, top: 5, right: 30, bottom: 30),
        //   customStyles: DefaultStyles(
        //       h1: DefaultTextBlockStyle(
        //           TextStyle(
        //               color: Colors.amber,
        //               fontSize: 30,
        //               fontWeight: FontWeight.w700),
        //           VerticalSpacing(16, 0),
        //           VerticalSpacing(0, 0),
        //           null),
        //       h2: DefaultTextBlockStyle(
        //           TextStyle(
        //               color: Colors.amber,
        //               fontSize: 25,
        //               fontWeight: FontWeight.w500),
        //           VerticalSpacing(16, 0),
        //           VerticalSpacing(0, 0),
        //           null),
        //       h3: DefaultTextBlockStyle(
        //           TextStyle(
        //               color: Colors.amber,
        //               fontSize: 20,
        //               fontWeight: FontWeight.w500),
        //           VerticalSpacing(16, 0),
        //           VerticalSpacing(0, 0),
        //           null),
        //       paragraph: DefaultTextBlockStyle(
        //           TextStyle(
        //               color: Colors.amber,
        //               fontSize: 15,
        //           ),
        //           VerticalSpacing(16, 0),
        //           VerticalSpacing(0, 0),
        //       null),
        //       strikeThrough: TextStyle(
        //           color: Colors.amber, decoration: TextDecoration.lineThrough),
        //       sizeSmall: TextStyle(color: Colors.amber),
        //       italic: TextStyle(color: Colors.amber, fontStyle: FontStyle.italic),
        //       bold: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
        //       underline: TextStyle(
        //           color: Colors.amber, decoration: TextDecoration.underline),
        //       color: Colors.amber),
        //   )
        //     // textSelectionThemeData: TextSelectionThemeData(selectionColor: Colors.amber)
        // ),
        );

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          // Render title
          TextFormField(
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
            initialValue: widget.title,
            decoration: const InputDecoration(
              hintText: 'Enter your title here...',
              hintStyle: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.normal,
              ),
              filled: true,
              fillColor: Color.fromARGB(255, 49, 51, 56),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 30.0),

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
                Expanded(child: editor),
              ],
            ),
          )),
          // Insert text area here

          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    // textController = TextEditingController(text: widget.mdContents);
    // QuillController _controller = QuillController.basic();
    updateHtmlContent(); // Call this to update the HTML content initially
  }

  void updateHtmlContent() {
    setState(() {
      // htmlContent = md.markdownToHtml(textController.text);
    });
  }
}
