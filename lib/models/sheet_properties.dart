import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class SheetProperties {
  final String name;
  final int columns;
  final int rows;
  const SheetProperties({
    required this.name,
    required this.columns,
    required this.rows,
  });

  SheetProperties copyWith({String? name, int? columns, int? rows}) {
    return SheetProperties(
      name: name ?? this.name,
      columns: columns ?? this.columns,
      rows: rows ?? this.rows,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{'name': name, 'columns': columns, 'rows': rows};
  }

  factory SheetProperties.fromMap(Map<String, dynamic> map) {
    return SheetProperties(
      name: map['name'] as String,
      columns: map['columns'] as int,
      rows: map['rows'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory SheetProperties.fromJson(String source) =>
      SheetProperties.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SheetProperties(name: $name, columns: $columns, rows: $rows)';

  @override
  bool operator ==(covariant SheetProperties other) {
    if (identical(this, other)) return true;

    return other.name == name && other.columns == columns && other.rows == rows;
  }

  @override
  int get hashCode => name.hashCode ^ columns.hashCode ^ rows.hashCode;
}
