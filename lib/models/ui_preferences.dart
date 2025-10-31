// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:cl_spreadsheet/models/spreadsheet_config.dart';

@immutable
class UiPreferences {
  const UiPreferences({
    this.themeMode = ThemeMode.system,
    required this.sheetConfigGlobal,
  });

  final ThemeMode themeMode;

  final SpreadsheetConfig sheetConfigGlobal;

  UiPreferences copyWith({
    ThemeMode? themeMode,
    SpreadsheetConfig? sheetConfigGlobal,
  }) {
    return UiPreferences(
      themeMode: themeMode ?? this.themeMode,
      sheetConfigGlobal: sheetConfigGlobal ?? this.sheetConfigGlobal,
    );
  }

  @override
  String toString() =>
      'UiPreferences(themeMode: $themeMode, sheetConfigGlobal: $sheetConfigGlobal)';

  @override
  bool operator ==(covariant UiPreferences other) {
    if (identical(this, other)) return true;

    return other.themeMode == themeMode &&
        other.sheetConfigGlobal == sheetConfigGlobal;
  }

  @override
  int get hashCode => themeMode.hashCode ^ sheetConfigGlobal.hashCode;
}
