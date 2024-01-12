import 'package:flutter/material.dart';

class ShowDialog {
  static void ShowConfirmDialog(
      BuildContext context, VoidCallback functionCall) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Confirmation'),
            content: Text('Are you sure you want to finish the quiz attempt?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  functionCall();
                },
                child: Text('Finish'),
              ),
            ],
          );
        });
  }
}
