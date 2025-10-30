import 'package:cl_spreadsheet/listeners/ui_preferences_listener.dart';
import 'package:cl_spreadsheet/models/sheet_properties.dart';
import 'package:cl_spreadsheet/models/store/checkbox_grid_id.dart';
import 'package:cl_spreadsheet/models/store/spread_sheet.dart';
import 'package:cl_spreadsheet/view/spread_sheet_viewer/grid_cell.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SpreadSheetGrid extends StatefulWidget {
  final SheetProperties sheetProperties;
  final SpreadSheet sheet;

  const SpreadSheetGrid({
    super.key,
    required this.sheetProperties,
    required this.sheet,
  });

  @override
  State<SpreadSheetGrid> createState() => SpreadSheetGridState();
}

class SpreadSheetGridState extends State<SpreadSheetGrid> {
  @override
  Widget build(BuildContext context) {
    final prop = widget.sheetProperties;

    return UiPreferencesListener(
      builder: (context, pref) {
        final kCellWidth = pref.cellWidth;
        final kCellHeight = pref.cellHeight;
        return SizedBox(
          width: kCellWidth * prop.columns,
          height: kCellHeight * prop.rows,
          child: GridView.builder(
            itemCount: prop.rows * prop.columns,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: prop.columns,
              childAspectRatio: kCellWidth / kCellHeight,
            ),
            itemBuilder: (context, index) {
              final row = index ~/ prop.columns;
              final column = index % prop.columns;
              final id = CheckboxGridId(row: row, column: column);

              return SizedBox(
                width: kCellWidth,
                height: kCellHeight,
                child: CellBorder(
                  id: id,
                  rows: prop.rows,
                  columns: prop.columns,
                  borderWidth: 2.0,
                  child: GridCell(id: id, cellData: widget.sheet.data[id]),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class CellBorder extends StatelessWidget {
  const CellBorder({
    super.key,
    required this.id,
    required this.rows,
    required this.columns,
    required this.borderWidth,
    required this.child,
  });
  final CheckboxGridId id;
  final int rows;
  final int columns;
  final Widget child;
  final double borderWidth;

  @override
  Widget build(BuildContext context) {
    final borderColor = ShadTheme.of(context).colorScheme.foreground;
    const double innerBorderFactor = 0.5;
    final double innerBorderWidth = borderWidth * innerBorderFactor;

    final BorderSide topBorder = BorderSide(
      color: borderColor,
      width: id.row == 0 ? borderWidth : innerBorderWidth,
    );
    final BorderSide leftBorder = BorderSide(
      color: borderColor,
      width: id.column == 0 ? borderWidth : innerBorderWidth,
    );
    final BorderSide rightBorder = BorderSide(
      color: borderColor,
      width: id.column == columns - 1 ? borderWidth : innerBorderWidth,
    );
    final BorderSide bottomBorder = BorderSide(
      color: borderColor,
      width: id.row == rows - 1 ? borderWidth : innerBorderWidth,
    );
    final hasError = false;
    final Color cellColor = hasError
        ? ShadTheme.of(context).colorScheme.destructive
        : ShadTheme.of(context).colorScheme.background;

    return Container(
      decoration: BoxDecoration(
        color: cellColor,
        border: Border(
          top: topBorder,
          left: leftBorder,
          right: rightBorder,
          bottom: bottomBorder,
        ),
      ),
      padding: const EdgeInsets.all(4.0),
      alignment: Alignment.center,
      child: child,
    );
  }
}
