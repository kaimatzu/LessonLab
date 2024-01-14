import 'package:flutter/material.dart';
import 'dart:developer' as developer;

class DropdownStateNotifier extends ChangeNotifier {
  String _selectedValue = '';

  String get selectedValue => _selectedValue;

  void setSelectedValue(String value) {
    _selectedValue = value;
    notifyListeners();
  }
}

class Dropdown extends StatefulWidget {
  const Dropdown(
      {Key? key,
      required this.label,
      required this.list,
      required this.stateNotifier})
      : super(key: key);

  final String label;
  final List<String> list;
  final DropdownStateNotifier stateNotifier;

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  @override
  void initState() {
    super.initState();
    widget.stateNotifier.setSelectedValue(widget.list.first);
    developer.log(widget.stateNotifier.selectedValue, name: "Dropdown trace");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 32.0, 32.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          widget.label,
          style: const TextStyle(
            fontFamily: 'Roboto, Inter, Arial',
            fontSize: 24.0,
            fontWeight: FontWeight.w600,
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            dropdownColor: const Color.fromARGB(255, 49, 51, 56),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(255, 49, 51, 56),
              enabledBorder: OutlineInputBorder(
                  //borderRadius: BorderRadius.(12),
                  borderSide: BorderSide(
                      width: 2, color: Color.fromARGB(255, 49, 51, 56))),
            ),
            value: widget.stateNotifier.selectedValue,
            style: const TextStyle(
              fontFamily: 'Roboto, Inter, Arial',
              color: Colors.white,
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              widget.stateNotifier.setSelectedValue(value!);
            },
            items: widget.list.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        )
      ]),
    );
  }
}
