import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:markdown/markdown.dart' as md;

const List<Widget> icons = <Widget>[
  Icon(Icons.code),
  Icon(Icons.html),
];

class TextEditor extends StatefulWidget {
  const TextEditor({Key? key, required this.title, required this.mdContents, required this.cssContents})
      : super(key: key);

  final String title;
  final String mdContents;
  final String cssContents;

  @override
  State<TextEditor> createState() => _TextEditor();
}

class _TextEditor extends State<TextEditor> {
  final List<bool> _richView = <bool>[true, false];
  late String htmlContent;
  late TextEditingController textController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8.0)),
            child: TextFormField(
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
              initialValue: widget.title,
              decoration: const InputDecoration(
                  hintText: 'Enter your title here...',
                  hintStyle: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.normal,
                  ),
                  filled: true,
                  fillColor: Color.fromARGB(255, 49, 51, 56),
                  border: OutlineInputBorder()),
            ),
          ),
          const SizedBox(height: 30.0),
          Stack(
            children: [
              Visibility(
                visible: _richView[0],
                child: Container(
                  // Render Placeholder when _richview is set to [false, true]
                  decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 49, 51, 56),
                      borderRadius: BorderRadius.circular(8.0)),
                  child: TextFormField(
                    controller: textController,
                    onChanged: (_) => updateHtmlContent(),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 16, height: 1.6),
                    // initialValue: widget.mdContents,
                    maxLines: null,
                    decoration: const InputDecoration(
                        hintText: 'Enter your text here...',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                        ),
                        filled: true,
                        fillColor: Color.fromARGB(255, 49, 51, 56),
                        border: OutlineInputBorder()),
                  ),
                ),
              ),
              Visibility(
                  visible: _richView[1],
                  child: Container(
                    // Render Placeholder when _richview is set to [false, true]
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 49, 51, 56),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Builder(
                      builder: (context) {
                        // developer.log(Style.fromCss(widget.cssContents, (css, errors) => null).keys.toString(), name: 'info-txe');
                        return Html(
                          data: '<div class="markdown-body">$htmlContent</div>',
                          style: Style.fromCss(widget.cssContents, (css, errors) => null)
                        );
                      }
                    ),
                  )),
              Positioned(
                top: 10,
                right: 10,
                child: ToggleButtons(
                  direction: Axis.horizontal,
                  onPressed: (int index) {
                    setState(() {
                      // The button that is tapped is set to true, and the others to false.
                      for (int i = 0; i < _richView.length; i++) {
                        _richView[i] = i == index;
                      }
                    });
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
              ),
            ],
          ),
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
