import 'package:flutter/material.dart';
import 'package:lessonlab/messages/entry/upload/uploaded_content.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:rinf/rinf.dart';


class SettingsViewModel extends ChangeNotifier{

  String _saveFilePath = '';
  String get saveFilePath => _saveFilePath;

  Future<void> sendData() async{
    final requestMessage = RinfInterface.CreateRequest(
      
    );
  }

  

}