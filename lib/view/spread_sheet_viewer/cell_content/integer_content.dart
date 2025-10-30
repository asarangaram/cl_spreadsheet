import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'grid_cell_content.dart';

enum IntegerFormat { decimal, hex, binary, simple }

/// Content for displaying integers with formatting options and padding.
class IntegerContent extends GridCellContent {
  final int value;
  final IntegerFormat format;
  final TextStyle style;
  final int paddingCount;

  const IntegerContent(
    this.value, {
    this.format = IntegerFormat.decimal,
    this.style = const TextStyle(fontSize: 12, color: Colors.black87),
    this.paddingCount = 0,
  });

  String getFormattedDisplayValue() {
    String formattedText;
    switch (format) {
      case IntegerFormat.decimal:
        formattedText = NumberFormat('#,###').format(value);
        break;
      case IntegerFormat.hex:
        formattedText = '0x${value.toRadixString(16).toUpperCase()}';
        break;
      case IntegerFormat.binary:
        formattedText = '0b${value.toRadixString(2)}';
        break;
      case IntegerFormat.simple:
        formattedText = value.toString();
        break;
    }
    return formattedText;
  }

  @override
  String get rawValue {
    switch (format) {
      case IntegerFormat.decimal:
      case IntegerFormat.simple:
        return value.toString();
      case IntegerFormat.hex:
        return '0x${value.toRadixString(16).toUpperCase()}';
      case IntegerFormat.binary:
        return '0b${value.toRadixString(2)}';
    }
  }

  @override
  Widget buildWidget(BuildContext context) {
    String formattedText = getFormattedDisplayValue();

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
  String get tooltipMessage => getFormattedDisplayValue();
}
