import 'package:cl_spreadsheet/view/spread_sheet_viewer/cell_content/grid_cell_content.dart';
import 'package:flutter/material.dart';

/// Content for displaying floating-point numbers with fixed precision and padding.
class FloatContent extends GridCellContent {
  final double value;
  final int precision;
  final TextStyle style;
  final int paddingCount;

  const FloatContent(
    this.value, {
    this.precision = 2,
    this.style = const TextStyle(fontSize: 12, color: Colors.black87),
    this.paddingCount = 0,
  });

  String _getFormattedDisplayValue() {
    return value.toStringAsFixed(precision);
  }

  @override
  String get rawValue => value.toString();

  @override
  Widget buildWidget(BuildContext context) {
    String formattedText = _getFormattedDisplayValue();

    if (paddingCount > 0) {
      formattedText = formattedText.padLeft(paddingCount);
    }

    return Text(
      formattedText,
      textAlign: TextAlign.center,
      style: style,
      overflow: TextOverflow.clip,
      maxLines: 1,
    );
  }

  @override
  String get tooltipMessage => _getFormattedDisplayValue();
}
