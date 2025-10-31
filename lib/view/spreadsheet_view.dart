import 'package:cl_spreadsheet/models/sheet_properties.dart';
import 'package:cl_spreadsheet/models/spreadsheet_config.dart';
import 'package:cl_spreadsheet/models/store/cell_data.dart';
import 'package:cl_spreadsheet/models/store/checkbox_grid_id.dart';
import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';

class SpreadsheetView extends StatefulWidget {
  const SpreadsheetView({
    super.key,
    required this.sheetProperties,
    required this.initialData,
    required this.onCellChanged,
    required this.config,
    required this.onConfigChanged,
  });

  final SheetProperties sheetProperties;
  final Map<CheckboxGridId, CellData> initialData;
  final Function(CheckboxGridId id, CellData? data) onCellChanged;
  final SpreadsheetConfig config;
  final Function(SpreadsheetConfig config) onConfigChanged;

  @override
  State<SpreadsheetView> createState() => _SpreadsheetViewState();
}

class _SpreadsheetViewState extends State<SpreadsheetView> {
  TableVicinity? _editingCell;
  final TextEditingController _editingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return TableView.builder(
      columnCount:
          widget.sheetProperties.columns + 1, // +1 for the header column
      rowCount: widget.sheetProperties.rows + 1, // +1 for the header row
      pinnedColumnCount: 1 + widget.config.frozenColCount,
      pinnedRowCount: 1 + widget.config.frozenRowCount,
      columnBuilder: (int index) {
        return TableSpan(
          extent: FixedTableSpanExtent(
            index == 0 ? 60.0 : widget.config.cellWidth,
          ), // Smaller width for row header
        );
      },
      rowBuilder: (int index) {
        return TableSpan(
          extent: FixedTableSpanExtent(
            index == 0 ? 40.0 : widget.config.cellHeight,
          ), // Smaller height for column header
        );
      },
      cellBuilder: (BuildContext context, TableVicinity vicinity) {
        return TableViewCell(child: _buildCell(context, vicinity));
      },
    );
  }

  String _getColumnLabel(int index) {
    if (index <= 0) return '';
    String label = '';
    while (index > 0) {
      index--;
      label = String.fromCharCode(65 + (index % 26)) + label;
      index ~/= 26;
    }
    return label;
  }

  Widget _buildCell(BuildContext context, TableVicinity vicinity) {
    final CheckboxGridId cellId = CheckboxGridId(
      row: vicinity.row,
      column: vicinity.column,
    );
    final CellData? cellData = widget.initialData[cellId];

    final bool isHeaderRow = vicinity.row == 0;
    final bool isHeaderColumn = vicinity.column == 0;
    final bool isTopLeftCorner = isHeaderRow && isHeaderColumn;

    if (isTopLeftCorner) {
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade200,
        ),
        alignment: Alignment.center,
        child: const Text(''),
      );
    } else if (isHeaderRow) {
      final String headerText =
          cellData?.value?.toString() ?? _getColumnLabel(vicinity.column);
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade200,
        ),
        alignment: Alignment.center,
        child: Text(
          headerText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else if (isHeaderColumn) {
      final String headerText =
          cellData?.value?.toString() ?? vicinity.row.toString();
      return Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          color: Colors.grey.shade200,
        ),
        alignment: Alignment.center,
        child: Text(
          headerText,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      );
    } else {
      // Regular data cell
      bool isEditing =
          _editingCell != null &&
          _editingCell!.row == vicinity.row &&
          _editingCell!.column == vicinity.column;

      if (isEditing) {
        return TextField(
          controller: _editingController,
          focusNode: _focusNode,
          onSubmitted: (value) => _saveCell(),
          decoration: const InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.all(8.0),
          ),
        );
      } else {
        final String cellText = cellData?.value?.toString() ?? '';
        final Color textColor =
            cellData?.properties['textColor'] ?? Colors.black;

        return GestureDetector(
          onDoubleTap: () => _startEditing(vicinity, cellText),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Text(cellText, style: TextStyle(color: textColor)),
          ),
        );
      }
    }
  }

  void _startEditing(TableVicinity vicinity, String currentText) {
    final bool isHeaderRow = vicinity.row == 0;
    final bool isHeaderColumn = vicinity.column == 0;

    if (isHeaderRow || isHeaderColumn) {
      // Headers are not editable
      return;
    }

    setState(() {
      _editingCell = vicinity;
      _editingController.text = currentText;
      _focusNode.requestFocus();
    });
  }

  void _saveCell() {
    if (_editingCell != null) {
      final CheckboxGridId cellId = CheckboxGridId(
        row: _editingCell!.row,
        column: _editingCell!.column,
      );
      final String newText = _editingController.text;

      if (newText.isEmpty) {
        widget.onCellChanged(cellId, null);
      } else {
        final CellData newCellData = CellData(value: newText);
        widget.onCellChanged(cellId, newCellData);
      }
      setState(() {
        _editingCell = null;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        _saveCell();
      }
    });
  }

  @override
  void dispose() {
    _editingController.dispose();
    _focusNode.dispose();
    super.dispose();
  }
}
