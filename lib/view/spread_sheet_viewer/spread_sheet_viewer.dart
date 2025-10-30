import 'package:cl_spreadsheet/view/spread_sheet_viewer/checkbox_grid_layout.dart';
import 'package:cl_spreadsheet/listeners/sheets_listener.dart';
import 'package:cl_spreadsheet/listeners/spreadsheet_listener.dart';
import 'package:cl_spreadsheet/view/spread_sheet_viewer/cell_content/text_content.dart';

import 'package:flutter/material.dart';

class SpreadSheetViewer extends StatelessWidget {
  const SpreadSheetViewer({super.key});

  @override
  Widget build(BuildContext context) {
    return SheetsListener(
      builder: (context, sheets) {
        final activeSheet = sheets.activeSheet;
        if (activeSheet == null) {
          throw Exception("Invoke this widget only when activeSheet is set");
        }
        return SpreadSheetListener(
          sheetName: activeSheet.name,
          builder: (context, sheet) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return Container(
                  width: constraints.maxWidth,
                  height: constraints.maxHeight,

                  padding: const EdgeInsets.all(8.0),
                  color: Colors.white,
                  child: CheckboxGridLayout(
                    rows: activeSheet
                        .rows, // Increased rows to 10 to test scrolling when height > 400
                    columns: activeSheet.columns,
                    initialChildren: sheet.data.map((k, v) {
                      return MapEntry(k, switch (v.value) {
                        _ => TextContent('${v.value}'),
                      });
                    }),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
