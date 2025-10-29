// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart' hide immutable;
import 'package:meta/meta.dart';

import 'package:cl_spreadsheet/models/sheet_properties.dart';

@immutable
class CurrentSheets {
  final List<SheetProperties> sheets;
  final String? activeSheetName;
  const CurrentSheets({this.sheets = const [], this.activeSheetName});

  CurrentSheets copyWith({
    List<SheetProperties>? sheets,
    ValueGetter<String?>? activeSheetName,
  }) {
    return CurrentSheets(
      sheets: sheets ?? this.sheets,
      activeSheetName: activeSheetName != null
          ? activeSheetName.call()
          : this.activeSheetName,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sheets': sheets.map((x) => x.toMap()).toList(),
      'activeSheetName': activeSheetName,
    };
  }

  factory CurrentSheets.fromMap(Map<String, dynamic> map) {
    return CurrentSheets(
      sheets: List<SheetProperties>.from(
        (map['sheets'] as List<int>).map<SheetProperties>(
          (x) => SheetProperties.fromMap(x as Map<String, dynamic>),
        ),
      ),
      activeSheetName: map['activeSheetName'] != null
          ? map['activeSheetName'] as String
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CurrentSheets.fromJson(String source) =>
      CurrentSheets.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SheetsManager(sheets: $sheets, activeSheetName: $activeSheetName)';

  @override
  bool operator ==(covariant CurrentSheets other) {
    if (identical(this, other)) return true;

    return listEquals(other.sheets, sheets) &&
        other.activeSheetName == activeSheetName;
  }

  @override
  int get hashCode => sheets.hashCode ^ activeSheetName.hashCode;
}
