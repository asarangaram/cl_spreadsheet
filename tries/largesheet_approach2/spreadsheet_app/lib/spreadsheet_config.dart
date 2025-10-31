import 'package:flutter/foundation.dart';

@immutable
class SpreadsheetConfig {
  const SpreadsheetConfig({
    this.rowCount = 5000,
    this.colCount = 5000,
    this.cellWidth = 120.0,
    this.cellHeight = 40.0,
    this.frozenRowCount = 0,
    this.frozenColCount = 0,
  });

  final int rowCount;
  final int colCount;
  final double cellWidth;
  final double cellHeight;
  final int frozenRowCount;
  final int frozenColCount;

  SpreadsheetConfig copyWith({
    int? rowCount,
    int? colCount,
    double? cellWidth,
    double? cellHeight,
    int? frozenRowCount,
    int? frozenColCount,
  }) {
    return SpreadsheetConfig(
      rowCount: rowCount ?? this.rowCount,
      colCount: colCount ?? this.colCount,
      cellWidth: cellWidth ?? this.cellWidth,
      cellHeight: cellHeight ?? this.cellHeight,
      frozenRowCount: frozenRowCount ?? this.frozenRowCount,
      frozenColCount: frozenColCount ?? this.frozenColCount,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpreadsheetConfig &&
          runtimeType == other.runtimeType &&
          rowCount == other.rowCount &&
          colCount == other.colCount &&
          cellWidth == other.cellWidth &&
          cellHeight == other.cellHeight &&
          frozenRowCount == other.frozenRowCount &&
          frozenColCount == other.frozenColCount;

  @override
  int get hashCode =>
      rowCount.hashCode ^
      colCount.hashCode ^
      cellWidth.hashCode ^
      cellHeight.hashCode ^
      frozenRowCount.hashCode ^
      frozenColCount.hashCode;

  @override
  String toString() =>
      'SpreadsheetConfig(rowCount: $rowCount, colCount: $colCount, cellWidth: $cellWidth, cellHeight: $cellHeight, frozenRowCount: $frozenRowCount, frozenColCount: $frozenColCount)';
}
