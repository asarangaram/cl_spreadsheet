import 'package:cl_spreadsheet/models/sheet_properties.dart';
import 'package:cl_spreadsheet/models/sheets_manager.dart';
import 'package:cl_spreadsheet/view/forms/new_sheet_form.dart';
import 'package:flutter/material.dart';
import 'package:minimal_mvn/minimal_mvn.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class CurrentSheetsNotifier extends MMNotifier<CurrentSheets> {
  CurrentSheetsNotifier() : super(CurrentSheets());

  openSheet(SheetProperties sheet) {
    notify(state.openSheet(sheet));
    print(state);
  }

  newSheet(BuildContext context) async {
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
      print("Sheet : $sheet");
    }
  }
}

MMManager<CurrentSheetsNotifier> sheetManager = MMManager(
  () => CurrentSheetsNotifier(),
);
