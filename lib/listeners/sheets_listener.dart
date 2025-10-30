import 'package:cl_spreadsheet/models/sheets_manager.dart';
import 'package:cl_spreadsheet/notifiers/sheets_notifier.dart';
import 'package:flutter/material.dart';

class SheetsListener extends StatelessWidget {
  const SheetsListener({super.key, required this.builder});
  final Widget Function(BuildContext context, CurrentSheets sheets) builder;

  @override
  Widget build(BuildContext context) {
    final notifier = sheetManager.notifier;

    return ListenableBuilder(
      listenable: notifier,
      builder: (context, final __) {
        return builder(context, notifier.state);
      },
    );
  }
}
