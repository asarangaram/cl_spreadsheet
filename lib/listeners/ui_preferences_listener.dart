import 'package:cl_spreadsheet/models/ui_preferences.dart';
import 'package:cl_spreadsheet/notifiers/ui_preferences.dart';
import 'package:flutter/material.dart';

class UiPreferencesListener extends StatelessWidget {
  const UiPreferencesListener({super.key, required this.builder});
  final Widget Function(BuildContext context, UiPreferences preferences)
  builder;

  @override
  Widget build(BuildContext context) {
    final notifier = uiPreferencesManager.notifier;
    return ListenableBuilder(
      listenable: notifier,
      builder: (context, final __) {
        return builder(context, notifier.state);
      },
    );
  }
}
