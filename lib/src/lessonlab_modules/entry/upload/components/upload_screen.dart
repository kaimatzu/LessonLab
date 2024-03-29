import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:lessonlab/src/lessonlab_modules/entry/upload/upload_sources_view_model.dart';
import 'package:lessonlab/src/lessonlab_modules/entry/upload/components/resources_container.dart';

class UploadScreen extends StatelessWidget {
  const UploadScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final uploadViewModel = context.watch<UploadSourcesViewModel>();

    uploadViewModel.hasFiles = uploadViewModel.getFilePaths().isNotEmpty ||
        uploadViewModel.getUrls().isNotEmpty ||
        uploadViewModel.getTexts().isNotEmpty;

    const noFilesStyle = TextStyle(color: Colors.grey);
    const fileNameTextStyle =
        TextStyle(fontSize: 30.0, fontWeight: FontWeight.bold, color: Color.fromRGBO(70, 70, 70, 1));
    const emptyPadding = EdgeInsets.fromLTRB(14.0, 6.0, 14.0, 4.0);
    const filePadding = EdgeInsets.fromLTRB(14.0, 0.0, 14.0, 4.0);


    const txtFiles = Text('Files', style: fileNameTextStyle);
    const txtNoFiles = Text('No files available', style: noFilesStyle);
    const txtUrl = Text('URL', style: fileNameTextStyle);
    const txtNoUrl = Text('No URLs available ', style: noFilesStyle);
    const txtText = Text('Text', style: fileNameTextStyle);
    const txtNoText = Text('No text available.', style: noFilesStyle);

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: filePadding,
            child: txtFiles,
          ),
          ResourcesContainer(
            viewModel: uploadViewModel,
            items: uploadViewModel.getFilePaths(),
            icon: const Icon(Icons.file_open, color: Colors.white),
          ),
          if (uploadViewModel.getFilePaths().isEmpty)
            const Padding(
              padding: emptyPadding,
              child: txtNoFiles,
            ),
          const Padding(
            padding: filePadding,
            child: txtUrl,
          ),
          ResourcesContainer(
            viewModel: uploadViewModel,
            items: uploadViewModel.getUrls(),
            icon: const Icon(Icons.link, color: Colors.white),
          ),
          if (uploadViewModel.getUrls().isEmpty)
            const Padding(
              padding: emptyPadding,
              child: txtNoUrl,
            ),
          const Padding(
            padding: filePadding,
            child: txtText,
          ),
          ResourcesContainer(
            viewModel: uploadViewModel,
            items: uploadViewModel.getTexts(),
            icon: const Icon(Icons.description, color: Colors.white),
          ),
          if (uploadViewModel.getTexts().isEmpty)
            const Padding(
              padding: emptyPadding,
              child: txtNoText,
            ),
          const SizedBox(height: 16.0),
        ],
      ),
    );
  }
}
