import 'dart:convert';

import 'package:flutter/foundation.dart';

/// Represents a single cell's data in the spreadsheet.
/// It stores the main 'value' and an arbitrary 'properties' map.
class CellData {
  final dynamic value;
  final Map<String, dynamic> properties;

  CellData({required this.value, required this.properties});

  CellData copyWith({dynamic value, Map<String, dynamic>? properties}) {
    return CellData(
      value: value ?? this.value,
      properties: properties ?? this.properties,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'value': value, 'properties': properties};
  }

  factory CellData.fromMap(Map<String, dynamic> map) {
    return CellData(
      value: map['value'] as dynamic,
      properties: Map<String, dynamic>.from(
        (map['properties'] as Map<String, dynamic>),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory CellData.fromJson(String source) =>
      CellData.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'CellData(value: $value, properties: $properties)';

  @override
  bool operator ==(covariant CellData other) {
    if (identical(this, other)) return true;

    return other.value == value && mapEquals(other.properties, properties);
  }

  @override
  int get hashCode => value.hashCode ^ properties.hashCode;
}
