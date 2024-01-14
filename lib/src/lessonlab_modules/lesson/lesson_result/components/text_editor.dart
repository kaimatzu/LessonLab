// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lessonlab/src/app.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_view.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_view_model.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'package:quill_html_converter/quill_html_converter.dart';
import 'package:rinf/rinf.dart';
import 'package:lessonlab/messages/results/view_lesson_result/load_lesson.pb.dart'
    as streamMessage;

import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/markdown_quill.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart' as htmlToPdf;
import 'package:quill_html_converter/quill_html_converter.dart';
import 'package:quill_pdf_converter/quill_pdf_converter.dart';
// import 'package:pdf/src/widgets/page_theme.dart' as pdfTheme;
// import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;

import 'dart:async';

import 'dart:developer' as developer;

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
  ValueNotifier<bool> _doneGeneratingNotifier = ValueNotifier<bool>(false);

  // var mdContentFinal = "a";
  // var htmlContent = "";
  // var noStreamValue = 0;
  // late TextEditingController textController;
  final QuillController _controller = QuillController.basic();
  late StreamSubscription<RustSignal> streamSubscription;
  late ScrollController _scrollController;
  final deltaToMd = DeltaToMarkdown();

  String message = "Nothing received yet";
  var markdownContent = "";
  bool isTextSelected = false;
  bool lessonInitialized = false;

  @override
  void initState() {
    // final lessonResultViewModel = context.watch<LessonResultViewModel>(); // PROBLEM HERE
    super.initState();
    _scrollController = ScrollController();
    _controller.addListener(() { 
      if(isTextSelected != (_controller.selection.start != _controller.selection.end)){
        // setState(() {
          isTextSelected = _controller.selection.start != _controller.selection.end;
        // });
      }
    });
    
    var mdDocument = md.Document(
        encodeHtml: false,
        extensionSet: md.ExtensionSet.gitHubFlavored,
        // you can add custom syntax.
        blockSyntaxes: [const EmbeddableTableSyntax()]);

    final mdToDelta = MarkdownToDelta(
      markdownDocument: mdDocument,
    );

    
    lessonGenerationStream(mdToDelta);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lessonResultViewModel = context.watch<LessonResultViewModel>();

    // ScaffoldMessenger.of(context).showSnackBar(showLessonGenerationStatus(0, context));
    // WidgetsBinding.instance.addPostFrameCallback((_) => ScaffoldMessenger.of(context).showSnackBar(showLessonGenerationStatus(0, context)));
    if(!lessonResultViewModel.done){
      // WidgetsBinding.instance.addPostFrameCallback((_) => ScaffoldMessenger.of(context).showSnackBar(showLessonGenerationStatus(0, context))); // Creating index notif
      Future(() => ScaffoldMessenger.of(context).showSnackBar(showLessonGenerationStatus(0, context)));
    }

    _doneGeneratingNotifier.addListener(() {
      var delta = _controller.document.toDelta();
      // lessonResultViewModel.lessonContent = deltaToMd.convert(delta); // This crashes for some reason
      lessonResultViewModel.lessonContent = delta.toHtml();
      setState(() {
        lessonResultViewModel.done = _doneGeneratingNotifier.value;
        debugPrint("Value changed to: ${lessonResultViewModel.done}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessonResultViewModel = context.watch<LessonResultViewModel>();
    lessonResultViewModel.quillController = _controller;
    // var message = "";
    // if (_doneGenerating) {
    //   lessonResultViewModel.done = true;
    // }

    // const markdown = "# test";

    // var html = md.markdownToHtml(markdown);

    var toolbar = QuillToolbar.simple(
      configurations: QuillSimpleToolbarConfigurations(
          controller: _controller,
          buttonOptions: QuillSimpleToolbarButtonOptions(
              base: QuillToolbarBaseButtonOptions(
                iconTheme: QuillIconTheme(
                  iconButtonSelectedData: IconButtonData(
                    color: Color.fromARGB(255, 49, 51, 56),
                    style: IconButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                          (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                    ),
                  ),
                  iconButtonUnselectedData: IconButtonData(
                    color: Color.fromARGB(255, 49, 51, 56),
                    style: IconButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                          (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                    ),
                  ),
                ),
              ),
              selectHeaderStyleButtons:
                  QuillToolbarSelectHeaderStyleButtonsOptions(
                      iconTheme: QuillIconTheme(
                iconButtonSelectedData: IconButtonData(
                  color: Color.fromARGB(255, 49, 51, 56),
                  style: IconButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                        (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                  ),
                ),
                iconButtonUnselectedData: IconButtonData(
                  color: Color.fromARGB(255, 49, 51, 56),
                  style: IconButton.styleFrom(
                    foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                        (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                  ),
                ),
              )),
              selectHeaderStyleDropdownButton:
                  QuillToolbarSelectHeaderStyleDropdownButtonOptions(
                      textStyle:
                          TextStyle(color: Color.fromARGB(255, 49, 51, 56)))),
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
                iconTheme: isTextSelected && lessonResultViewModel.done ? 
                QuillIconTheme(
                  iconButtonSelectedData: IconButtonData(
                    color: Color.fromARGB(255, 49, 51, 56),
                    style: IconButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                          (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                    ),
                  ),
                  iconButtonUnselectedData: IconButtonData(
                    color: Color.fromARGB(255, 49, 51, 56),
                    style: IconButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                          (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                    ),
                  ),
                ) :
                QuillIconTheme(
                  iconButtonSelectedData: IconButtonData(
                    color: Color.fromARGB(255, 204, 208, 217),
                    style: IconButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                          (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                    ),
                  ),
                  iconButtonUnselectedData: IconButtonData(
                    color: Color.fromARGB(255, 204, 208, 217),
                    style: IconButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                          (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                    ),
                  ),
                ),
                onPressed: () {
                  if (isTextSelected){
                    lessonResultViewModel.regenerateSection(context, _controller.getPlainText(), _controller, _doneGeneratingNotifier);
                  } 
                  else {
                    WidgetsBinding.instance.addPostFrameCallback((_) => ScaffoldMessenger.of(context).showSnackBar(showLessonGenerationStatus(3, context)));
                  }
                }),
            QuillToolbarCustomButtonOptions(
                icon: Icon(Icons.add_outlined),
                tooltip: "Continue lesson from this point",
                iconTheme: !isTextSelected && lessonResultViewModel.done ? 
                QuillIconTheme(
                  iconButtonSelectedData: IconButtonData(
                    color: Color.fromARGB(255, 49, 51, 56),
                    style: IconButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                          (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                    ),
                  ),
                  iconButtonUnselectedData: IconButtonData(
                    color: Color.fromARGB(255, 49, 51, 56),
                    style: IconButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                          (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                    ),
                  ),
                ) :
                QuillIconTheme(
                  iconButtonSelectedData: IconButtonData(
                    color: Color.fromARGB(255, 204, 208, 217),
                    style: IconButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                          (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                    ),
                  ),
                  iconButtonUnselectedData: IconButtonData(
                    color: Color.fromARGB(255, 204, 208, 217),
                    style: IconButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                          (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                    ),
                  ),
                ),
                onPressed: () {
                  if (!isTextSelected){
                    lessonResultViewModel.continueLessonFromHere(context, _controller, _doneGeneratingNotifier);
                  }
                  else {
                    WidgetsBinding.instance.addPostFrameCallback((_) => ScaffoldMessenger.of(context).showSnackBar(showLessonGenerationStatus(4, context)));
                  }
                }),
            QuillToolbarCustomButtonOptions(
                icon: Icon(Icons.picture_as_pdf_outlined),
                tooltip: "Create PDF from lesson",
                iconTheme: lessonResultViewModel.done ? 
                QuillIconTheme(
                  iconButtonSelectedData: IconButtonData(
                    color: Color.fromARGB(255, 49, 51, 56),
                    style: IconButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                          (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                    ),
                  ),
                  iconButtonUnselectedData: IconButtonData(
                    color: Color.fromARGB(255, 49, 51, 56),
                    style: IconButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                          (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                    ),
                  ),
                ) :
                QuillIconTheme(
                  iconButtonSelectedData: IconButtonData(
                    color: Color.fromARGB(255, 204, 208, 217),
                    style: IconButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                          (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                    ),
                  ),
                  iconButtonUnselectedData: IconButtonData(
                    color: Color.fromARGB(255, 204, 208, 217),
                    style: IconButton.styleFrom(
                      foregroundColor: Color.fromARGB(255, (241 + 255) ~/ 2,
                          (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                    ),
                  ),
                ),
                onPressed: () async {
                  if(lessonResultViewModel.done){
                    debugPrint(_controller.document.toDelta().toHtml());
                    var widgets = await _controller.document.toDelta().toPdf();
                    var filePath = './test/example.pdf';
                    var file = File(filePath);
                    final newpdf = htmlToPdf.Document();
                    newpdf.addPage(htmlToPdf.MultiPage(
                        maxPages: 200,
                        theme: pw.ThemeData(
                          defaultTextStyle: pw.TextStyle(fontSize: 12),
                          paragraphStyle: pw.TextStyle(fontSize: 12),
                          header0: pw.TextStyle(
                              fontSize: 28, fontWeight: pw.FontWeight.bold),
                          header1: pw.TextStyle(
                              fontSize: 25, fontWeight: pw.FontWeight.bold),
                          header2: pw.TextStyle(
                              fontSize: 23, fontWeight: pw.FontWeight.bold),
                          header3: pw.TextStyle(
                              fontSize: 20, fontWeight: pw.FontWeight.bold),
                          header4: pw.TextStyle(
                              fontSize: 18, fontWeight: pw.FontWeight.bold),
                          header5: pw.TextStyle(
                              fontSize: 16, fontWeight: pw.FontWeight.bold),
                          bulletStyle: pw.TextStyle(fontSize: 12),
                          tableHeader: pw.TextStyle(
                              fontSize: 12, fontWeight: pw.FontWeight.bold),
                          tableCell: pw.TextStyle(fontSize: 12),
                          softWrap: true,
                          textAlign: pw.TextAlign.left,
                          overflow: pw.TextOverflow.clip,
                          maxLines: null, // Unlimited lines
                        ),
                        build: (context) {
                          return widgets;
                        }));
                    await file.writeAsBytes(await newpdf.save());
                  }
                  else {
                    WidgetsBinding.instance.addPostFrameCallback((_) => ScaffoldMessenger.of(context).showSnackBar(showLessonGenerationStatus(5, context)));
                  }
                }),
          ]),
    );

    var editor = QuillEditor.basic(
        scrollController: _scrollController,
        // Pass the controller to QuillEditor
        configurations: QuillEditorConfigurations(
          controller: _controller,
          autoFocus: true,
          readOnly: !_doneGeneratingNotifier.value,
          padding: EdgeInsets.only(left: 30, top: 5, right: 30),
          elementOptions: const QuillEditorElementOptions(
            orderedList: QuillEditorOrderedListElementOptions(
              useTextColorForDot: true,
            ),
            unorderedList: QuillEditorUnOrderedListElementOptions(
              useTextColorForDot: true,
            ),
          ),
          customStyles: DefaultStyles(
              h1: DefaultTextBlockStyle(
                  TextStyle(
                      color: Color.fromARGB(255, 49, 51, 56),
                      fontSize: 30,
                      fontWeight: FontWeight.w700),
                  VerticalSpacing(16, 0),
                  VerticalSpacing(0, 0),
                  null),
              h2: DefaultTextBlockStyle(
                  TextStyle(
                      color: Color.fromARGB(255, 49, 51, 56),
                      fontSize: 25,
                      fontWeight: FontWeight.w500),
                  VerticalSpacing(16, 0),
                  VerticalSpacing(0, 0),
                  null),
              h3: DefaultTextBlockStyle(
                  TextStyle(
                      color: Color.fromARGB(255, 49, 51, 56),
                      fontSize: 20,
                      fontWeight: FontWeight.w500),
                  VerticalSpacing(16, 0),
                  VerticalSpacing(0, 0),
                  null),
              paragraph: DefaultTextBlockStyle(
                  TextStyle(
                    color: Color.fromARGB(255, 49, 51, 56),
                    fontSize: 15,
                  ),
                  VerticalSpacing(16, 0),
                  VerticalSpacing(0, 0),
                  null),
              strikeThrough: TextStyle(
                  color: Color.fromARGB(255, 49, 51, 56),
                  decoration: TextDecoration.lineThrough),
              sizeSmall: TextStyle(color: Color.fromARGB(255, 49, 51, 56)),
              italic: TextStyle(
                  color: Color.fromARGB(255, 49, 51, 56),
                  fontStyle: FontStyle.italic),
              bold: TextStyle(
                  color: Color.fromARGB(255, 49, 51, 56),
                  fontWeight: FontWeight.bold),
              underline: TextStyle(
                  color: Color.fromARGB(255, 49, 51, 56),
                  decoration: TextDecoration.underline),
              lists: DefaultListBlockStyle(
                  TextStyle(
                    color: context.quillEditorElementOptions?.unorderedList
                                    .useTextColorForDot ==
                                true ||
                            context.quillEditorElementOptions?.orderedList
                                    .useTextColorForDot ==
                                true
                        ? Color.fromARGB(255, 49, 51, 56)
                        : null,
                  ),
                  VerticalSpacing(16, 0),
                  VerticalSpacing(0, 0),
                  null,
                  null),
              color: Color.fromARGB(255, 49, 51, 56)),
        ));

    return Padding(
      padding: const EdgeInsets.only(left: 16.0, right: 16.0),
      child: Column(
        children: [
          Center(
              child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.670),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: Color.fromARGB(
                  255, (241 + 255) ~/ 2, (196 + 255) ~/ 2, (27 + 255) ~/ 2),
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
    _doneGeneratingNotifier.dispose();
    super.dispose();
  }

  void lessonGenerationStream(MarkdownToDelta mdToDelta) {
    // Start listening to the stream in initState
    streamSubscription = rustBroadcaster.stream
        .where((rustSignal) => rustSignal.resource == streamMessage.ID)
        .listen((RustSignal rustSignal) {
      // Handle the stream data here
      final signal = streamMessage.StateSignal.fromBuffer(rustSignal.message!);
      final rinfMessage = signal.streamMessage;
      debugPrint(rinfMessage);
      if(!lessonInitialized && rinfMessage.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) => ScaffoldMessenger.of(context).showSnackBar(showLessonGenerationStatus(1, context))); // In progress notif
        lessonInitialized = true;
        // ScaffoldMessenger.of(context).showSnackBar(showLessonGenerationStatus(1, context));
      }
      if (rinfMessage == "[LL_END_STREAM]") {
        _doneGeneratingNotifier.value = true;
        streamSubscription.cancel();
        // ScaffoldMessenger.of(context).showSnackBar(showLessonGenerationStatus(2, context));
        WidgetsBinding.instance.addPostFrameCallback((_) => ScaffoldMessenger.of(context).showSnackBar(showLessonGenerationStatus(2, context))); // Done notif
        debugPrint("Done generating: ${_doneGeneratingNotifier.value}");
      } else {
        markdownContent += rinfMessage;
        if (markdownContent.isNotEmpty) {
          _controller.document =
              Document.fromDelta(mdToDelta.convert(markdownContent));
          _controller.moveCursorToEnd();
        }
        // _controller.document.insert(_controller.plainTextEditingValue.text.length - 1, rinfMessage);
      }
      
    });
  }

  SnackBar showLessonGenerationStatus(int mode, BuildContext context) {
    // 0 = lessonInitialized index
    // 1 = streaming lesson
    // 2 = finished
    // 3 = regenerate section error
    // 4 = continue lesson from here error
    // 5 = lesson not done error

    ScaffoldMessenger.of(context).clearSnackBars();
    switch (mode) {
      case 0:
        {
          return SnackBar(
              content: Row(
                // We wrap this in a Row to constrain the visible part. It seems dumb but it works.
                children: [
                  Container(
                    height: 75,
                    width: 300,
                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, (241 + 255) ~/ 2,
                            (196 + 255) ~/ 2, (27 + 255) ~/ 2),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        CircularProgressIndicator(color: Colors.amber
                            // backgroundColor: Colors.amber,
                            ),
                        SizedBox(width: 24),
                        Text('Generating index...',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
              elevation: 1000,
              margin: EdgeInsets.fromLTRB(0, 0, MediaQuery.of(context).size.width / 1.5, 0),
              backgroundColor: const Color.fromARGB(0, 0, 0, 0),
              duration: const Duration(minutes: 60),
              padding: const EdgeInsets.all(16.0),
              behavior: SnackBarBehavior.floating,
              hitTestBehavior: HitTestBehavior.translucent,
          );
        }
      case 1: 
        {
          return SnackBar(
              content: Row(
                // We wrap this in a Row to constrain the visible part. It seems dumb but it works.
                children: [
                  Container(
                    height: 75,
                    width: 300,
                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 255, 226, 120),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        CircularProgressIndicator(color: Colors.amber
                            // backgroundColor: Colors.amber,
                            ),
                        SizedBox(width: 24),
                        Text('Streaming Lesson...',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
              elevation: 1000,
              margin: EdgeInsets.fromLTRB(0, 0, MediaQuery.of(context).size.width / 1.5, 0),
              backgroundColor: const Color.fromARGB(0, 255, 255, 255),
              duration: const Duration(minutes: 60),
              padding: const EdgeInsets.all(16.0),
              behavior: SnackBarBehavior.floating,
              hitTestBehavior: HitTestBehavior.translucent,);
              
          }
        case 2: 
          {
          return SnackBar(
              content: Row(
                // We wrap this in a Row to constrain the visible part. It seems dumb but it works.
                children: [
                  Container(
                    height: 75,
                    width: 300,
                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                    decoration: BoxDecoration(
                        color: const Color.fromARGB(255, 154, 231, 166),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.check, color: Colors.green),
                        SizedBox(width: 24),
                        Text('Finished Lesson Generation',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
              elevation: 1000,
              margin: EdgeInsets.fromLTRB(0, 0, MediaQuery.of(context).size.width / 1.5, 0),
              backgroundColor: const Color.fromARGB(0, 255, 255, 255),
              duration: const Duration(seconds: 10),
              padding: const EdgeInsets.all(16.0),
              behavior: SnackBarBehavior.floating,
              hitTestBehavior: HitTestBehavior.translucent,);
          }
        case 3: 
          {
          return SnackBar(
              content: Row(
                // We wrap this in a Row to constrain the visible part. It seems dumb but it works.
                children: [
                  Container(
                    height: 75,
                    width: 300,
                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 171, 141),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 24),
                        Text('Please select a section of text!',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
              elevation: 1000,
              margin: EdgeInsets.fromLTRB(0, 0, MediaQuery.of(context).size.width / 1.5, 0),
              backgroundColor: const Color.fromARGB(0, 255, 255, 255),
              duration: const Duration(seconds: 3),
              padding: const EdgeInsets.all(16.0),
              behavior: SnackBarBehavior.floating,
              hitTestBehavior: HitTestBehavior.translucent,);
          }
        case 4: 
          {
          return SnackBar(
              content: Row(
                // We wrap this in a Row to constrain the visible part. It seems dumb but it works.
                children: [
                  Container(
                    height: 75,
                    width: 300,
                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 171, 141),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 24),
                        Text('Unselect text!',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
              elevation: 1000,
              margin: EdgeInsets.fromLTRB(0, 0, MediaQuery.of(context).size.width / 1.5, 0),
              backgroundColor: const Color.fromARGB(0, 255, 255, 255),
              duration: const Duration(seconds: 3),
              padding: const EdgeInsets.all(16.0),
              behavior: SnackBarBehavior.floating,
              hitTestBehavior: HitTestBehavior.translucent,);
          }
        case 5: 
          {
          return SnackBar(
              content: Row(
                // We wrap this in a Row to constrain the visible part. It seems dumb but it works.
                children: [
                  Container(
                    height: 75,
                    width: 300,
                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 171, 141),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 24),
                        Text('Generation ongoing!',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
              elevation: 1000,
              margin: EdgeInsets.fromLTRB(0, 0, MediaQuery.of(context).size.width / 1.5, 0),
              backgroundColor: const Color.fromARGB(0, 255, 255, 255),
              duration: const Duration(seconds: 3),
              padding: const EdgeInsets.all(16.0),
              behavior: SnackBarBehavior.floating,
              hitTestBehavior: HitTestBehavior.translucent,);
          }
        default:
          {
          return SnackBar(
              content: Row(
                // We wrap this in a Row to constrain the visible part. It seems dumb but it works.
                children: [
                  Container(
                    height: 75,
                    width: 300,
                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 10),
                    decoration: BoxDecoration(
                        color: Color.fromARGB(255, 255, 171, 141),
                        borderRadius: BorderRadius.circular(10)),
                    child: const Row(
                      children: [
                        Icon(Icons.error, color: Colors.red),
                        SizedBox(width: 24),
                        Text('Error in Lesson Generation',
                            style:
                                TextStyle(color: Colors.black, fontSize: 16)),
                      ],
                    ),
                  ),
                ],
              ),
              elevation: 1000,
              margin: EdgeInsets.fromLTRB(0, 0, MediaQuery.of(context).size.width / 1.5, 0),
              backgroundColor: const Color.fromARGB(0, 255, 255, 255),
              duration: const Duration(seconds: 10),
              padding: const EdgeInsets.all(16.0),
              behavior: SnackBarBehavior.floating,
              hitTestBehavior: HitTestBehavior.translucent,);
          }
    }
  }
}
