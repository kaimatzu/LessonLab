import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import 'settings_view_model.dart';

/// Displays the various settings that can be customized by the user.
///
/// When a user changes a setting, the SettingsController is updated and
/// Widgets that listen to the SettingsController are rebuilt.
class SettingsView extends StatelessWidget {
  const SettingsView({super.key, required this.settingsViewModel});

  static const routeName = '/settings';

  final SettingsViewModel settingsViewModel;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        
      ),
    );
  }
}
