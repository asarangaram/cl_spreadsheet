import 'package:flutter/material.dart';
import 'package:spreadsheet_app/data_model.dart';
import 'package:spreadsheet_app/spreadsheet_view.dart';
import 'package:spreadsheet_app/spreadsheet_config.dart';

void main() {
  runApp(const SpreadsheetApp());
}

class SpreadsheetApp extends StatefulWidget {
  const SpreadsheetApp({super.key});

  @override
  State<SpreadsheetApp> createState() => _SpreadsheetAppState();
}

class _SpreadsheetAppState extends State<SpreadsheetApp> {
  final Map<CheckboxGridId, CellData> _externalCellData = {};
  SpreadsheetConfig _config = const SpreadsheetConfig();

  void _onCellChanged(CheckboxGridId id, CellData? data) {
    setState(() {
      if (data == null) {
        _externalCellData.remove(id);
      } else {
        _externalCellData[id] = data;
      }
    });
  }

  void _onConfigChanged(SpreadsheetConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Spreadsheet Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: SpreadsheetView(
        initialData: _externalCellData,
        onCellChanged: _onCellChanged,
        config: _config,
        onConfigChanged: _onConfigChanged,
      ),
    );
  }
}