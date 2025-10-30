import 'package:flutter/foundation.dart';

@immutable
class CheckboxGridId {
  const CheckboxGridId({
    required this.row,
    required this.column,
  });

  final int row;
  final int column;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CheckboxGridId &&
          runtimeType == other.runtimeType &&
          row == other.row &&
          column == other.column;

  @override
  int get hashCode => row.hashCode ^ column.hashCode;

  @override
  String toString() => 'CheckboxGridId(row: $row, column: $column)';
}

@immutable
class CellData {
  const CellData({
    required this.value,
    this.properties = const {},
  });

  final dynamic value;
  final Map<String, dynamic> properties;

  CellData copyWith({
    dynamic value,
    Map<String, dynamic>? properties,
  }) {
    return CellData(
      value: value ?? this.value,
      properties: properties ?? this.properties,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CellData &&
          runtimeType == other.runtimeType &&
          value == other.value &&
          mapEquals(properties, other.properties);

  @override
  int get hashCode => value.hashCode ^ properties.hashCode;

  @override
  String toString() => 'CellData(value: $value, properties: $properties)';
}
