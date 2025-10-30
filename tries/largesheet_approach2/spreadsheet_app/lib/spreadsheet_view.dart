import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'dart:math';
import 'package:spreadsheet_app/data_model.dart';

class SpreadsheetView extends StatefulWidget {
  const SpreadsheetView({
    super.key,
    required this.initialData,
    required this.onCellChanged,
  });

  final Map<CheckboxGridId, CellData> initialData;
  final Function(CheckboxGridId, CellData?) onCellChanged;

  @override
  State<SpreadsheetView> createState() => _SpreadsheetViewState();
}

class _SpreadsheetViewState extends State<SpreadsheetView> {
  int _rowCount = 5000;
  int _colCount = 5000;
  double _cellWidth = 120.0;
  double _cellHeight = 40.0;

  int _frozenRowCount = 0;
  int _frozenColCount = 0;

  final Random _random = Random();

  TableVicinity? _editingCell;
  final TextEditingController _editingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spreadsheet Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showSettingsDialog,
          ),
        ],
      ),
      body: TableView.builder(
        columnCount: _colCount + 1, // +1 for the header column
        rowCount: _rowCount + 1, // +1 for the header row
        pinnedColumnCount: 1 + _frozenColCount,
        pinnedRowCount: 1 + _frozenRowCount,
        columnBuilder: (int index) {
          return TableSpan(
            extent: FixedTableSpanExtent(index == 0 ? 60.0 : _cellWidth), // Smaller width for row header
          );
        },
        rowBuilder: (int index) {
          return TableSpan(
            extent: FixedTableSpanExtent(index == 0 ? 40.0 : _cellHeight), // Smaller height for column header
          );
        },
        cellBuilder: (BuildContext context, TableVicinity vicinity) {
          return TableViewCell(
            child: _buildCell(context, vicinity),
          );
        },
      ),
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
      final String headerText = cellData?.value?.toString() ?? _getColumnLabel(vicinity.column);
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
      final String headerText = cellData?.value?.toString() ?? vicinity.row.toString();
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
      bool isEditing = _editingCell != null &&
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
        final Color textColor = cellData?.properties?['textColor'] ?? Colors.black;

        return GestureDetector(
          onDoubleTap: () => _startEditing(vicinity, cellText),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
            ),
            padding: const EdgeInsets.all(8.0),
            child: Text(
              cellText,
              style: TextStyle(color: textColor),
            ),
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

  Future<void> _showSettingsDialog() async {
    final TextEditingController rowController =
        TextEditingController(text: _rowCount.toString());
    final TextEditingController colController =
        TextEditingController(text: _colCount.toString());
    final TextEditingController cellWidthController =
        TextEditingController(text: _cellWidth.toString());
    final TextEditingController cellHeightController =
        TextEditingController(text: _cellHeight.toString());
    final TextEditingController frozenRowCountController =
        TextEditingController(text: _frozenRowCount.toString());
    final TextEditingController frozenColCountController =
        TextEditingController(text: _frozenColCount.toString());

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextField(
                  controller: rowController,
                  decoration: const InputDecoration(labelText: 'Row Count'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: colController,
                  decoration: const InputDecoration(labelText: 'Column Count'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: cellWidthController,
                  decoration: const InputDecoration(labelText: 'Cell Width'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: cellHeightController,
                  decoration: const InputDecoration(labelText: 'Cell Height'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: frozenRowCountController,
                  decoration: const InputDecoration(labelText: 'Additional Frozen Row Count'),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: frozenColCountController,
                  decoration: const InputDecoration(labelText: 'Additional Frozen Column Count'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Apply'),
              onPressed: () {
                setState(() {
                  _rowCount = int.tryParse(rowController.text) ?? _rowCount;
                  _colCount = int.tryParse(colController.text) ?? _colCount;
                  _cellWidth =
                      double.tryParse(cellWidthController.text) ?? _cellWidth;
                  _cellHeight =
                      double.tryParse(cellHeightController.text) ?? _cellHeight;
                  _frozenRowCount = int.tryParse(frozenRowCountController.text) ?? _frozenRowCount;
                  _frozenColCount = int.tryParse(frozenColCountController.text) ?? _frozenColCount;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}
