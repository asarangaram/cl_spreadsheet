// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

@immutable
class SpreadsheetConfig {
  const SpreadsheetConfig({
    this.cellWidth = 120.0,
    this.cellHeight = 40.0,
    this.frozenRowCount = 0,
    this.frozenColCount = 0,
  });

  final double cellWidth;
  final double cellHeight;
  final int frozenRowCount;
  final int frozenColCount;

  SpreadsheetConfig copyWith({
    double? cellWidth,
    double? cellHeight,
    int? frozenRowCount,
    int? frozenColCount,
  }) {
    return SpreadsheetConfig(
      cellWidth: cellWidth ?? this.cellWidth,
      cellHeight: cellHeight ?? this.cellHeight,
      frozenRowCount: frozenRowCount ?? this.frozenRowCount,
      frozenColCount: frozenColCount ?? this.frozenColCount,
    );
  }

  @override
  bool operator ==(covariant SpreadsheetConfig other) {
    if (identical(this, other)) return true;

    return other.cellWidth == cellWidth &&
        other.cellHeight == cellHeight &&
        other.frozenRowCount == frozenRowCount &&
        other.frozenColCount == frozenColCount;
  }

  @override
  int get hashCode {
    return cellWidth.hashCode ^
        cellHeight.hashCode ^
        frozenRowCount.hashCode ^
        frozenColCount.hashCode;
  }

  @override
  String toString() {
    return 'SpreadsheetConfig(cellWidth: $cellWidth, cellHeight: $cellHeight, frozenRowCount: $frozenRowCount, frozenColCount: $frozenColCount)';
  }
}
