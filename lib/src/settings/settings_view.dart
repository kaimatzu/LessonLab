import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'package:lessonlab/src/global_components/primary_button.dart';
import 'settings_view_model.dart';
import 'package:file_selector/file_selector.dart';
/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatefulWidget {
  const SettingsView({super.key, required this.settingsViewModel});

  static const routeName = '/settings';

  final SettingsViewModel settingsViewModel;

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  late TextEditingController directoryController;

    @override
  void initState() {
    super.initState();
    directoryController = TextEditingController();
  }

  @override
  void dispose() {
    directoryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Save Directory",
              style: TextStyle(
                fontFamily: 'Roboto, Inter, Arial',
                color: Color.fromARGB(255, 49, 51, 56),
                fontSize: 24.0,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8.0,),
            TextField(
              controller: directoryController,
              style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              filled: true,
              fillColor: Color.fromARGB(255, 49, 51, 56),
              border: OutlineInputBorder(),
              hintText: "no save directory",
              hintStyle: TextStyle(
                  fontFamily: 'Roboto, Inter, Arial',
                  color: Colors.grey,
                ),
              ),
              enabled: false, 
            ),
            const SizedBox(height: 8.0,),
            PrimaryButton(
              handlePress:  (){
                selectDirectory(context);
              },
              text: "Use another folder", 
            enabled: true
            )
          ],
        ) 
      ),
    );
  }

  void selectDirectory(BuildContext context) async{
    final String? directoryPath = await getDirectoryPath();

    if (directoryPath == null) {
      // Operation was canceled by the user.
    
      return;
    }
    else
    {
      directoryController.text = directoryPath;
    }
  }
}
