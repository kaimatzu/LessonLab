import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/overlay/overlay_view_model.dart';
import 'package:cross_file/cross_file.dart';
import 'dart:developer' as developer;

import 'package:lessonlab/messages/entry/upload/uploaded_content.pb.dart' as RinfInterface;
import 'package:rinf/rinf.dart';

class UploadViewModel with ChangeNotifier {
  var files = <XFile>[];
  var urlFiles = <String>[];
  var textFiles = <TextFile>[];

  var status = 0;

  Future<void> sendData() async {
    final requestMessage = RinfInterface.CreateRequest(
      filePaths: files.map((file) => file.path).toList(),
      urls: urlFiles,
      texts: textFiles.map((textFile) => RinfInterface.TextFile(
        title: textFile.title,
        content: textFile.content,
      )).toList(),
    );
    final rustRequest = RustRequest(
      resource: RinfInterface.ID, 
      operation: RustOperation.Create,
      message: requestMessage.writeToBuffer(),
      // blob: NO BLOB 
    );
    final rustResponse = await requestToRust(rustRequest);
    final responseMessage = RinfInterface.CreateResponse.fromBuffer(
      rustResponse.message!,
    );
    status = responseMessage.statusCode;
    developer.log(status.toString(), name: 'rinf-info');
  }

  Future<void> getData() async {
    // Debug purposes. Just to check if the uploaded files are stored in rust main().
    final requestMessage = RinfInterface.ReadRequest(
        req: true
    );
    final rustRequest = RustRequest(
      resource: RinfInterface.ID, 
      operation: RustOperation.Read,
      message: requestMessage.writeToBuffer(),
      // blob: NO BLOB 
    );
    final rustResponse = await requestToRust(rustRequest);
    final responseMessage = RinfInterface.ReadResponse.fromBuffer(
      rustResponse.message!,
    );
    var content = responseMessage.filePaths;
    developer.log(content.join(), name: 'rinf-info');
  }
}