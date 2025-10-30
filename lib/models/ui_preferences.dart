// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

@immutable
class UiPreferences {
  const UiPreferences({
    this.themeMode = ThemeMode.system,
    this.cellHeight = 40,
    this.cellWidth = 120.0,
  });

  final ThemeMode themeMode;

  final double cellWidth;
  final double cellHeight;

  UiPreferences copyWith({
    ThemeMode? themeMode,
    double? cellWidth,
    double? cellHeight,
  }) {
    return UiPreferences(
      themeMode: themeMode ?? this.themeMode,
      cellWidth: cellWidth ?? this.cellWidth,
      cellHeight: cellHeight ?? this.cellHeight,
    );
  }

  @override
  String toString() =>
      'UiPreferences(themeMode: $themeMode, cellWidth: $cellWidth, cellHeight: $cellHeight)';

  @override
  bool operator ==(covariant UiPreferences other) {
    if (identical(this, other)) return true;

    return other.themeMode == themeMode &&
        other.cellWidth == cellWidth &&
        other.cellHeight == cellHeight;
  }

  @override
  int get hashCode =>
      themeMode.hashCode ^ cellWidth.hashCode ^ cellHeight.hashCode;
}
