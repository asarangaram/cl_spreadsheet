// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart' hide immutable;
import 'package:meta/meta.dart';

import 'package:cl_spreadsheet/models/sheet_properties.dart';

@immutable
class CurrentSheets {
  final List<SheetProperties> sheets;
  final SheetProperties? activeSheet;
  const CurrentSheets({this.sheets = const [], this.activeSheet});

  CurrentSheets copyWith({
    List<SheetProperties>? sheets,
    ValueGetter<SheetProperties?>? activeSheetName,
  }) {
    return CurrentSheets(
      sheets: sheets ?? this.sheets,
      activeSheet: activeSheetName != null
          ? activeSheetName.call()
          : activeSheet,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'sheets': sheets.map((x) => x.toMap()).toList(),
      'activeSheetName': activeSheet,
    };
  }

  factory CurrentSheets.fromMap(Map<String, dynamic> map) {
    return CurrentSheets(
      sheets: List<SheetProperties>.from(
        (map['sheets'] as List<int>).map<SheetProperties>(
          (x) => SheetProperties.fromMap(x as Map<String, dynamic>),
        ),
      ),
      activeSheet: map['activeSheetName'] != null
          ? SheetProperties.fromMap(
              map['activeSheetName'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory CurrentSheets.fromJson(String source) =>
      CurrentSheets.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() =>
      'SheetsManager(sheets: $sheets, activeSheetName: $activeSheet)';

  @override
  bool operator ==(covariant CurrentSheets other) {
    if (identical(this, other)) return true;

    return listEquals(other.sheets, sheets) && other.activeSheet == activeSheet;
  }

  @override
  int get hashCode => sheets.hashCode ^ activeSheet.hashCode;

  CurrentSheets openSheet(SheetProperties sheet) {
    final updatedSheets = List<SheetProperties>.from(sheets);

    if (!updatedSheets.contains(sheet)) {
      if (updatedSheets.map((e) => e.name).contains(sheet.name)) {
        throw Exception(" Can't add two sheets with same name");
      }
      updatedSheets.add(sheet);
    }

    return CurrentSheets(sheets: updatedSheets, activeSheet: sheet);
  }
}
