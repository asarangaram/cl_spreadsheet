// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

@immutable
class UiPreferences {
  const UiPreferences({this.themeMode = ThemeMode.system});

  final ThemeMode themeMode;

  UiPreferences copyWith({ThemeMode? themeMode}) {
    return UiPreferences(themeMode: themeMode ?? this.themeMode);
  }

  @override
  String toString() => 'UiPreferences(themeMode: $themeMode)';

  @override
  bool operator ==(covariant UiPreferences other) {
    if (identical(this, other)) return true;

    return other.themeMode == themeMode;
  }

  @override
  int get hashCode => themeMode.hashCode;
}
