import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:lessonlab/src/lessonlab_modules/lesson/lesson_result/lesson_result_view_model.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:provider/provider.dart';
import 'package:rinf/rinf.dart';
import 'package:lessonlab/messages/results/view_lesson_result/load_lesson.pb.dart'
    as streamMessage;

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
  var mdContentFinal = "";
  var htmlContent = "";
  // var noStreamValue = 0;
  late TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    final lessonResultViewModel = context.watch<LessonResultViewModel>();

    // the main component of this view is the stack where it will hold both
    // raw markdown text and formatted markdown text for display
    // ---- Stack ----
    /// A widget that positions its children relative to the edges of its box.
    ///
    /// This class is useful if you want to overlap several children in a simple
    /// way, for example having some text and an image, overlaid with a gradient and
    /// a button attached to the bottom.

    // there are three things in the stack
    // 2 are Visibility and 1 is Position
    // `html`, `rawMd` = Visibility
    // `viewSelector` = Positioned
    // the `viewSelector` = is an absolute position widget at the top right of the text-view/editor
    // which you can use two switch between the 2 visibilities
    // the two Visibility variables in the stack
    // `html` is the formatted text of a markdown
    // `rawMd` is the pre-formatted text of a markdown

    // This the EDIT view
    var rawMd = Visibility(
      visible: _richView[0],
      child: Container(
          // Render Placeholder when _richview is set to [false, true]
          decoration: BoxDecoration(
            color: const Color.fromARGB(255, 49, 51, 56),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: StreamBuilder<RustSignal>(
            stream: rustBroadcaster.stream.where((rustSignal) {
              return rustSignal.resource == streamMessage.ID;
            }),
            builder: (context, snapshot) {
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
                  textController.text += rinfMessage;
                  htmlContent = md.markdownToHtml(textController.text);
                }
                // mdContentFinal += rinfMessage;
              }
              return TextFormField(
                controller: textController,
                onChanged: (_) => updateHtmlContent(),
                readOnly: !_doneGenerating,
                style: const TextStyle(
                    color: Colors.white, fontSize: 16, height: 1.6),
                maxLines: null,
                decoration: const InputDecoration(
                  hintText: 'Enter your text here...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(255, 49, 51, 56),
                  border: OutlineInputBorder(),
                ),
              );
            },
          )),
    );

    // this the SWITCH at the top right of the textview/texteditor
    var viewSelector = Positioned(
      top: 10,
      right: 10,
      child: ToggleButtons(
        direction: Axis.horizontal,
        onPressed: (int index) {
          if (_doneGenerating) {
            updateHtmlContent();
            setState(() {
              // The button that is tapped is set to true, and the others to false.
              for (int i = 0; i < _richView.length; i++) {
                _richView[i] = i == index;
              }
            });
          }
        },
        constraints: const BoxConstraints(
          minHeight: 20.0,
          minWidth: 40.0,
        ),
        borderRadius: const BorderRadius.all(Radius.circular(8)),
        borderColor: Colors.amber,
        selectedBorderColor: Colors.amber,
        selectedColor: Colors.white,
        fillColor: Colors.amber,
        color: Colors.amber,
        isSelected: _richView,
        children: icons,
      ),
    );

    // This the DISPLAY view
    var html = Visibility(
      visible: _richView[1],
      child: Container(
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 49, 51, 56),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Builder(
          builder: (context) {
            // SelectableText.rich()
            return SelectionArea(
              child: Html(
                data: '<div class="markdown-body">$htmlContent</div>',
                style: Style.fromCss(widget.cssContents, (css, errors) => null),
              ),
            );
          },
        ),
      ),
    );

    // ======= THE STACK =======
    var stack = Stack(
      children: [
        rawMd, // -> Visibility
        html, // -> Visibility
        viewSelector, // -> Positioned
      ],
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
          stack,
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    textController = TextEditingController(text: widget.mdContents);
    updateHtmlContent(); // Call this to update the HTML content initially
  }

  void updateHtmlContent() {
    setState(() {
      htmlContent = md.markdownToHtml(textController.text);
    });
  }
}
