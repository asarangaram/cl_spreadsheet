import 'package:cl_spreadsheet/view/spread_sheet_viewer/cell_content/grid_cell_content.dart';
import 'package:flutter/material.dart';

/// Content for simple string display.
class TextContent extends GridCellContent {
  final String text;
  final TextStyle style;

  const TextContent(
    this.text, {
    this.style = const TextStyle(fontSize: 12, color: Colors.black87),
  });

  @override
  Widget buildWidget(BuildContext context) {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: style,
      overflow: TextOverflow.clip,
      maxLines: 1,
    );
  }

  @override
  String get tooltipMessage => text;

  @override
  String get rawValue => text;
}
