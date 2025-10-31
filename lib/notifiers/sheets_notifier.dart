import 'dart:io';

import 'package:cl_spreadsheet/common/async_value.dart';
import 'package:cl_spreadsheet/models/sheet_properties.dart';
import 'package:cl_spreadsheet/models/sheets_manager.dart';
import 'package:cl_spreadsheet/view/forms/new_sheet_form.dart';
import 'package:flutter/material.dart';
import 'package:minimal_mvn/minimal_mvn.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CurrentSheetsNotifier extends MMNotifier<AsyncValue<CurrentSheets>> {
  CurrentSheetsNotifier() : super(AsyncValue.loading()) {
    initialize();
  }

  Future<void> initialize() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final scanDir = Directory(p.join(directory.path, 'sheets'));
      final List<SheetProperties> sheets = [];
      if (scanDir.existsSync()) {
        final files = await scanDir.list().toList();

        for (var file in files) {
          final fileName = file.path.split('/').last;
          try {
            final sheet = SheetProperties.fromFileName(fileName);
            sheets.add(sheet);
          } on FormatException {
            // Ignore files that don't match the format
          }
        }
      }
      notify(AsyncValue.data(CurrentSheets(sheets: sheets)));
    } catch (e, st) {
      print(e);
      notify(AsyncError(e, st));
    }
  }

  openSheet(SheetProperties sheet) {
    state.whenOrNull(
      data: (data) => notify(AsyncValue.data(data.openSheet(sheet))),
    );
  }

  Future<SheetProperties?> newSheet(BuildContext context) async {
    final sheet = await showShadDialog<SheetProperties?>(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) => ShadDialog.alert(
        gap: 0,
        backgroundColor: Colors.transparent,

        shadows: [],
        border: BoxBorder.all(color: Colors.transparent),
        child: SizedBox(
          width: 375,
          child: NewSheetForm(
            onClose: () => Navigator.of(context).pop(null),
            onSubmit: ({required sheetProperties}) =>
                Navigator.of(context).pop(sheetProperties),
          ),
        ),
      ),
    );
    if (sheet != null) {
      sheetManager.notifier.openSheet(sheet);
    }
    return sheet;
  }
}

MMManager<CurrentSheetsNotifier> sheetManager = MMManager(
  () => CurrentSheetsNotifier(),
);
