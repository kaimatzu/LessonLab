import 'dart:developer' as developer;

import 'package:lessonlab/messages/entry/upload/uploaded_content.pb.dart'
    // ignore: library_prefixes
    as RinfInterface;
import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_model.dart';
import 'package:rinf/rinf.dart';

class UploadSourcesConnectionOrchestrator {
  void sendData(UploadSourcesModel uploadModel) async {
    developer.log(uploadModel.pdfFilePaths.map((file) => file.path).toList().toString() ,name: 'file');
    developer.log(uploadModel.urls.toString(), name: 'url');
    developer.log(uploadModel.texts.toString(), name: 'text');
    final requestMessage = RinfInterface.CreateRequest(
      filePaths: uploadModel.pdfFilePaths.map((file) => file.path).toList(),
      urls: uploadModel.urls,
      texts: uploadModel.texts
          .map((text) =>
              RinfInterface.TextFile(title: text.title, content: text.content))
          .toList(),
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
    var statusCode = responseMessage.statusCode;
    developer.log(statusCode.toString(), name: 'rinf-info');
  }

  void getData() async {
    // Debug purposes. Just to check if the uploaded files are stored in rust main().
    final requestMessage = RinfInterface.ReadRequest(req: true);
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
    developer.log(content.join(), name: 'file');
    content = responseMessage.urls;
    developer.log(content.join(), name: 'url');
    content = responseMessage.texts.map((e) => e.toString()).toList();
    developer.log(content.join(), name: 'text');
  }
}
