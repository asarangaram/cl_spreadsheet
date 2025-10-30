import 'package:flutter/material.dart';
import 'package:two_dimensional_scrollables/two_dimensional_scrollables.dart';
import 'dart:math';

void main() {
  runApp(const SpreadsheetApp());
}

class SpreadsheetApp extends StatelessWidget {
  const SpreadsheetApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spreadsheet Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SpreadsheetView(),
    );
  }
}

class SpreadsheetView extends StatefulWidget {
  const SpreadsheetView({super.key});

  @override
  State<SpreadsheetView> createState() => _SpreadsheetViewState();
}

class _SpreadsheetViewState extends State<SpreadsheetView> {
  int _rowCount = 5000;
  int _colCount = 5000;
  double _cellWidth = 120.0;
  double _cellHeight = 40.0;

  final Map<String, String> _cellData = {};
  final Random _random = Random();

  TableVicinity? _editingCell;
  final TextEditingController _editingController = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  String _generateRandomText() {
    return List.generate(10, (_) => _random.nextInt(26) + 65)
        .map((e) => String.fromCharCode(e))
        .join();
  }

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
        columnCount: _colCount,
        rowCount: _rowCount,
        columnBuilder: (int index) {
          return TableSpan(
            extent: FixedTableSpanExtent(_cellWidth),
          );
        },
        rowBuilder: (int index) {
          return TableSpan(
            extent: FixedTableSpanExtent(_cellHeight),
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

  Widget _buildCell(BuildContext context, TableVicinity vicinity) {
    final String cellKey = '${vicinity.row}-${vicinity.column}';
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
      final String cellText = _cellData[cellKey] ?? _generateRandomText();
      _cellData[cellKey] = cellText;
      return GestureDetector(
        onDoubleTap: () => _startEditing(vicinity, cellText),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
          ),
          padding: const EdgeInsets.all(8.0),
          child: Text(cellText),
        ),
      );
    }
  }

  void _startEditing(TableVicinity vicinity, String currentText) {
    setState(() {
      _editingCell = vicinity;
      _editingController.text = currentText;
      _focusNode.requestFocus();
    });
  }

  void _saveCell() {
    if (_editingCell != null) {
      setState(() {
        final String cellKey =
            '${_editingCell!.row}-${_editingCell!.column}';
        _cellData[cellKey] = _editingController.text;
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