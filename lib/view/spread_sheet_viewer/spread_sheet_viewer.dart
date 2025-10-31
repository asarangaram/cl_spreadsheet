import 'package:cl_spreadsheet/listeners/ui_preferences_listener.dart';
import 'package:cl_spreadsheet/notifiers/store_notifier.dart';
import 'package:cl_spreadsheet/notifiers/ui_preferences.dart';
import 'package:cl_spreadsheet/listeners/sheets_listener.dart';
import 'package:cl_spreadsheet/listeners/spreadsheet_listener.dart';
import 'package:cl_spreadsheet/view/spreadsheet_view.dart';
import 'package:flutter/material.dart';

class ActiveSpreadSheetViewer extends StatelessWidget {
  const ActiveSpreadSheetViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return UiPreferencesListener(
      builder: (context, pref) {
        return SheetsListener(
          builder: (context, sheets) {
            final activeSheet = sheets.activeSheet;
            if (activeSheet == null) {
              throw Exception(
                "Invoke this widget only when activeSheet is set",
              );
            }
            return SpreadSheetListener(
              sheetName: activeSheet.name,
              builder: (context, sheet) {
                return SpreadsheetView(
                  sheetProperties: activeSheet,
                  initialData: sheet.data,
                  config: pref.sheetConfigGlobal,
                  onCellChanged: (id, data) {
                    final notifier = spreadSheetDBManager(
                      activeSheet.name,
                    ).notifier;
                    notifier.upsertOrDelete(id, data);
                  },
                  onConfigChanged: (config) {
                    uiPreferencesManager.notifier.updateConfig(config);
                  },
                );
              },
            );
          },
        );
      },
    );
  }
}
