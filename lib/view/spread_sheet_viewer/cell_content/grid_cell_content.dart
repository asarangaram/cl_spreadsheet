import 'package:flutter/material.dart';

/// Abstract base class for defining the content of a single grid cell.
abstract class GridCellContent {
  const GridCellContent();

  /// Builds the widget representation of the content.
  Widget buildWidget(BuildContext context);

  /// Returns the raw string value for use in a Tooltip.
  String get tooltipMessage;

  // IMPORTANT: This must be the raw, unformatted value suitable for TextEditingController
  String get rawValue;
}
