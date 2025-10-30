import 'package:cl_spreadsheet/models/store/checkbox_grid_id.dart';
import 'package:cl_spreadsheet/view/spread_sheet_viewer/cell_content/grid_cell_content.dart';
import 'package:cl_spreadsheet/view/spread_sheet_viewer/grid_layout.dart';
import 'package:flutter/material.dart';

const Color _kErrorColor = Color(0xFFFEEAEA);

class CheckboxGridLayout extends StatefulWidget {
  final int rows;
  final int columns;
  final Map<CheckboxGridId, GridCellContent> initialChildren;

  const CheckboxGridLayout({
    super.key,
    required this.rows,
    required this.columns,
    required this.initialChildren,
  });

  @override
  State<CheckboxGridLayout> createState() => _CheckboxGridLayoutState();
}

class _CheckboxGridLayoutState extends State<CheckboxGridLayout>
    with WidgetsBindingObserver {
  static const double _kCellWidth = 120.0;
  static const double _kCellHeight = 40.0;
  @override
  void didChangeMetrics() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    print("rebuilding... _CheckboxGridLayoutState");
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: GridView.builder(
        itemCount: widget.rows * widget.columns,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: widget.columns,
          childAspectRatio: _kCellWidth / _kCellHeight,
        ),
        itemBuilder: (context, index) {
          print("building $index");
          final row = index ~/ widget.columns;
          final column = index % widget.columns;
          final id = CheckboxGridId(row: row, column: column);

          final content = widget.initialChildren[id];
          final bool isDefined = content != null;
          final String tooltipMsg = isDefined ? content.tooltipMessage : '';
          // Error handling is currently in _CheckboxGridLayoutState,
          // which is being removed. For now, assume no errors.
          // This will be handled by the ViewModel later.
          const bool hasError = false;

          return GridCell(
            id: id,
            rows: widget.rows,
            columns: widget.columns,
            content: content,
            tooltipMessage: tooltipMsg,
            // onSubmitted will be handled by the ViewModel later
            onSubmitted: (id, newValue) {
              // Placeholder for now, will be replaced by ViewModel call
              //print('Cell $id submitted with value: $newValue');
            },
            defaultBackgroundColor: isDefined
                ? Colors.white
                : Colors.grey.shade100,
            errorColor: _kErrorColor,
            hasError: hasError,
            borderColor: Colors.black,
            borderWidth: 2.0,
            cellWidth: _kCellWidth,
            cellHeight: _kCellHeight,
          );
        },
      ),
    );
  }
}
