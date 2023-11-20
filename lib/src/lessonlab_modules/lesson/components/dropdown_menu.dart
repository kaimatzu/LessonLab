import 'package:flutter/material.dart';

const List<String> list = <String>[
  'Elementary',
  'Junior High School',
  'Senior High School',
  'College',
];

class Dropdown extends StatefulWidget {
  const Dropdown({
    super.key,
  });

  @override
  // ignore: library_private_types_in_public_api
  _DropdownState createState() => _DropdownState();

  // ignore: library_private_types_in_public_api
  String get getSelectedValue => createState().selectedValue;
}

class _DropdownState extends State<Dropdown> {
  String selectedValue = list.first;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(0.0, 0.0, 32.0, 32.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          'Grade Level',
          style: TextStyle(
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
            value: selectedValue,
            style: const TextStyle(
              fontFamily: 'Roboto, Inter, Arial',
              color: Colors.white,
            ),
            onChanged: (String? value) {
              // This is called when the user selects an item.
              setState(() {
                selectedValue = value!;
              });
            },
            items: list.map<DropdownMenuItem<String>>((String value) {
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
