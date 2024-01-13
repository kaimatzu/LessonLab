// ignore_for_file: prefer_const_constructors

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_open/lesson_open_view_model.dart';
import 'package:provider/provider.dart';
import 'package:quill_html_converter/quill_html_converter.dart';
import 'package:rinf/rinf.dart';
import 'package:lessonlab/messages/results/open_finished_lesson/open_lesson.pb.dart'
    as streamMessage;

import 'package:flutter_quill/flutter_quill.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart' as htmlToPdf;
import 'package:quill_pdf_converter/quill_pdf_converter.dart';
// import 'package:pdf/src/widgets/page_theme.dart' as pdfTheme;
// import 'package:pdf/pdf.dart' as pdf;
import 'package:pdf/widgets.dart' as pw;

import 'dart:async';

const List<Widget> icons = <Widget>[
  Icon(Icons.code),
  Icon(Icons.html),
];

class TextEditor extends StatefulWidget {
  const TextEditor({Key? key, required this.contents}) : super(key: key);

  final String contents;

  @override
  State<TextEditor> createState() => _TextEditor();
}

class _TextEditor extends State<TextEditor> {
  ValueNotifier<bool> _doneGeneratingNotifier = ValueNotifier<bool>(true);
  // var mdContentFinal = "a";
  // var htmlContent = "";
  // var noStreamValue = 0;
  // late TextEditingController textController;
  final QuillController _controller = QuillController.basic();
  // late StreamSubscription<RustSignal> streamSubscription;
  String message = "Nothing received yet";
  var markdownContent = "";
  bool isTextSelected = false;


  @override
  void initState() {
    super.initState();

    _controller.document = Document.fromDelta(Document.fromHtml(widget.contents));
    _controller.addListener(() { 
      if(isTextSelected != (_controller.selection.start != _controller.selection.end)){
        setState(() {
          isTextSelected = _controller.selection.start != _controller.selection.end;
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final lessonOpenViewModel = context.watch<LessonOpenViewModel>();

    _doneGeneratingNotifier.addListener(() {
      var delta = _controller.document.toDelta();
      // lessonOpenViewModel.lessonContent = deltaToMd.convert(delta); // This crashes for some reason
      lessonOpenViewModel.lessonContent = delta.toHtml();
      setState(() {
        lessonOpenViewModel.done = _doneGeneratingNotifier.value;
        debugPrint("Value changed to: ${lessonOpenViewModel.done}");
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final lessonOpenViewModel = context.watch<LessonOpenViewModel>();
    
    lessonOpenViewModel.lessonContent = _controller.document.toPlainText();
    lessonOpenViewModel.quillController = _controller;

    
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
                iconTheme: isTextSelected && lessonOpenViewModel.done ? 
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
                  if(isTextSelected && lessonOpenViewModel.done){
                    lessonOpenViewModel.regenerateSection(context, _controller.getPlainText(), _controller, _doneGeneratingNotifier);
                  }
                  // lessonOpenViewModel.createInstructionDialog(context);
                }),
            QuillToolbarCustomButtonOptions(
                icon: Icon(Icons.add_outlined),
                tooltip: "Continue lesson from this point",
                iconTheme: !isTextSelected && lessonOpenViewModel.done ? 
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
                  if(!isTextSelected && lessonOpenViewModel.done ){
                    lessonOpenViewModel.continueLessonFromHere(context, _controller, _doneGeneratingNotifier);
                  }
                }),
            QuillToolbarCustomButtonOptions(
                icon: Icon(Icons.picture_as_pdf_outlined),
                tooltip: "Create PDF from lesson",
                iconTheme: lessonOpenViewModel.done ? 
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
                  if(lessonOpenViewModel.done){
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
                }),
          ]),
    );

    var editor = QuillEditor.basic(
        // Pass the controller to QuillEditor
        configurations: QuillEditorConfigurations(
      controller: _controller,
      autoFocus: true,
      readOnly: !_doneGeneratingNotifier.value,
      padding: EdgeInsets.only(left: 30, top: 5, right: 30, bottom: 30),
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
                  fontWeight: FontWeight.w600),
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
          h4: DefaultTextBlockStyle(
              TextStyle(
                  color: Color.fromARGB(255, 49, 51, 56),
                  fontSize: 20,
                  fontWeight: FontWeight.w400),
              VerticalSpacing(16, 0),
              VerticalSpacing(0, 0),
              null),
          h5: DefaultTextBlockStyle(
              TextStyle(
                  color: Color.fromARGB(255, 49, 51, 56),
                  fontSize: 20,
                  fontWeight: FontWeight.w300),
              VerticalSpacing(16, 0),
              VerticalSpacing(0, 0),
              null),
          h6: DefaultTextBlockStyle(
              TextStyle(
                  color: Color.fromARGB(255, 49, 51, 56),
                  fontSize: 20,
                  fontWeight: FontWeight.w200),
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
      padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
      child: Column(
        children: [
          Center(
              child: Container(
            constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.670),
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
              color: const Color.fromARGB(
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
}
