
import 'package:flutter/material.dart';
import 'package:lessonlab/src/global_components/lessonlab_appbar.dart';

const List<String> list = <String>['Elementary', 'Junior High School', 'Senior High School', 'College'];

class Dropdown extends StatefulWidget {
  const Dropdown({
    super.key,
    });

  @override
  State<Dropdown> createState() => _DropdownState();
}

class _DropdownState extends State<Dropdown> {
  String selectedValue = list.first;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
              'Grade Level',
              style: TextStyle(fontSize: 20),
          ),
          SizedBox(
            width: 1440,
            child: DropdownButtonFormField<String>(
              isExpanded: true,
              dropdownColor: Color.fromARGB(255, 49, 51, 56),
              decoration: const InputDecoration(
                filled: true,
                fillColor: Color.fromARGB(255, 49, 51, 56),
                enabledBorder: OutlineInputBorder(
                    //borderRadius: BorderRadius.(12),
                    borderSide: BorderSide(width: 2, color: Color.fromARGB(255, 49, 51, 56))
                ),
              ),
              value: selectedValue,
              style: const TextStyle(color: Colors.white),
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
        ]
      ),

    );
  }
}
