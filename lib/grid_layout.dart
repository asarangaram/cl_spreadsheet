import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// --------------------------------------------------------------------------
// 0. Abstract Cell Content Definition (Unchanged)
// --------------------------------------------------------------------------

/// Abstract base class for defining the content of a single grid cell.
abstract class GridCellContent {
  const GridCellContent();

  /// Builds the widget representation of the content.
  Widget buildWidget();

  /// Returns the raw string value for use in a Tooltip.
  String get tooltipMessage;

  // IMPORTANT: This must be the raw, unformatted value suitable for TextEditingController
  String get rawValue;
}

/// Content for simple string display. (Unchanged)
class TextContent extends GridCellContent {
  final String text;
  final TextStyle style;

  const TextContent(
    this.text, {
    this.style = const TextStyle(fontSize: 12, color: Colors.black87),
  });

  @override
  Widget buildWidget() {
    return Text(
      text,
      textAlign: TextAlign.center,
      style: style,
      overflow: TextOverflow.clip,
      maxLines: 1,
    );
  }

  @override
  String get tooltipMessage => text;

  @override
  String get rawValue => text;
}

/// Content for displaying integers with formatting options and padding. (Unchanged)
class IntegerContent extends GridCellContent {
  final int value;
  final IntegerFormat format;
  final TextStyle style;
  final int paddingCount;

  const IntegerContent(
    this.value, {
    this.format = IntegerFormat.decimal,
    this.style = const TextStyle(fontSize: 12, color: Colors.black87),
    this.paddingCount = 0,
  });

  String _getFormattedDisplayValue() {
    String formattedText;
    switch (format) {
      case IntegerFormat.decimal:
        formattedText = NumberFormat('#,###').format(value);
        break;
      case IntegerFormat.hex:
        formattedText = '0x${value.toRadixString(16).toUpperCase()}';
        break;
      case IntegerFormat.binary:
        formattedText = '0b${value.toRadixString(2)}';
        break;
      case IntegerFormat.simple:
        formattedText = value.toString();
        break;
    }
    return formattedText;
  }

  @override
  String get rawValue {
    switch (format) {
      case IntegerFormat.decimal:
      case IntegerFormat.simple:
        return value.toString();
      case IntegerFormat.hex:
        return '0x${value.toRadixString(16).toUpperCase()}';
      case IntegerFormat.binary:
        return '0b${value.toRadixString(2)}';
    }
  }

  @override
  Widget buildWidget() {
    String formattedText = _getFormattedDisplayValue();

    if (paddingCount > 0) {
      formattedText = formattedText.padLeft(paddingCount);
    }

    return Text(
      formattedText,
      textAlign: TextAlign.center,
      style: style,
      overflow: TextOverflow.clip,
      maxLines: 1,
    );
  }

  @override
  String get tooltipMessage => _getFormattedDisplayValue();
}

enum IntegerFormat { decimal, hex, binary, simple }

/// Content for displaying floating-point numbers with fixed precision and padding. (Unchanged)
class FloatContent extends GridCellContent {
  final double value;
  final int precision;
  final TextStyle style;
  final int paddingCount;

  const FloatContent(
    this.value, {
    this.precision = 2,
    this.style = const TextStyle(fontSize: 12, color: Colors.black87),
    this.paddingCount = 0,
  });

  String _getFormattedDisplayValue() {
    return value.toStringAsFixed(precision);
  }

  @override
  String get rawValue => value.toString();

  @override
  Widget buildWidget() {
    String formattedText = _getFormattedDisplayValue();

    if (paddingCount > 0) {
      formattedText = formattedText.padLeft(paddingCount);
    }

    return Text(
      formattedText,
      textAlign: TextAlign.center,
      style: style,
      overflow: TextOverflow.clip,
      maxLines: 1,
    );
  }

  @override
  String get tooltipMessage => _getFormattedDisplayValue();
}

// --------------------------------------------------------------------------
// 1. Layout ID and Delegate (Unchanged)
// --------------------------------------------------------------------------

/// A helper class to uniquely tag children with their (row, column) index.
class CheckboxGridId {
  final int row;
  final int column;
  CheckboxGridId({required this.row, required this.column});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is CheckboxGridId &&
        other.row == row &&
        other.column == column;
  }

  @override
  int get hashCode => row.hashCode ^ column.hashCode;
}

// --------------------------------------------------------------------------
// 2. Grid Cell Widget (Unchanged)
// --------------------------------------------------------------------------

typedef OnCellValueSubmitted =
    void Function(CheckboxGridId id, String newValue);

/// A stateful widget to wrap content and handle the edit/display toggle.
class GridCell extends StatefulWidget {
  final GridCellContent? content;
  final String tooltipMessage;
  final Color defaultBackgroundColor;
  final Color errorColor;
  final bool hasError;
  final Color borderColor;
  final double borderWidth;
  final CheckboxGridId id;
  final int rows;
  final int columns;
  final OnCellValueSubmitted onSubmitted;

  final double cellWidth;
  final double cellHeight;

  const GridCell({
    super.key,
    required this.content,
    required this.tooltipMessage,
    required this.id,
    required this.rows,
    required this.columns,
    required this.onSubmitted,
    required this.cellWidth,
    required this.cellHeight,
    this.defaultBackgroundColor = Colors.white,
    required this.errorColor,
    required this.hasError,
    this.borderColor = Colors.black,
    this.borderWidth = 2.0,
  });

  @override
  State<GridCell> createState() => _GridCellState();
}

class _GridCellState extends State<GridCell> {
  bool _isEditing = false;
  late TextEditingController _textController;
  late FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(
      text: widget.content?.rawValue ?? '',
    );
    _focusNode = FocusNode();
    _focusNode.addListener(_handleFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_handleFocusChange);
    _focusNode.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant GridCell oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!_isEditing) {
      final newRawValue = widget.content?.rawValue ?? '';
      if (newRawValue != _textController.text) {
        _textController.text = newRawValue;
      }
    }
  }

  void _handleFocusChange() {
    if (!_focusNode.hasFocus && _isEditing) {
      _submitAndEndEditing();
    }
  }

  void _startEditing() {
    if (widget.content != null) {
      setState(() {
        _isEditing = true;
      });
      _textController.selection = TextSelection.fromPosition(
        TextPosition(offset: _textController.text.length),
      );

      _focusNode.requestFocus();
    }
  }

  void _submitAndEndEditing({String? value}) {
    widget.onSubmitted(widget.id, value ?? _textController.text);

    setState(() {
      _isEditing = false;
    });
  }

  Widget _buildContentWidget() {
    if (widget.content == null) {
      return const SizedBox.shrink();
    }

    if (_isEditing) {
      String? hintText;
      TextStyle? textStyle;

      if (widget.content is IntegerContent) {
        final IntegerContent intContent = widget.content as IntegerContent;
        textStyle = intContent.style;
        if (intContent.format == IntegerFormat.decimal) {
          hintText = 'Formatted: ${intContent._getFormattedDisplayValue()}';
        } else if (intContent.format == IntegerFormat.hex ||
            intContent.format == IntegerFormat.binary) {
          hintText = 'Dec: ${intContent.value}';
        }
      } else if (widget.content is TextContent) {
        final TextContent textContent = widget.content as TextContent;
        textStyle = textContent.style;
      } else if (widget.content is FloatContent) {
        final FloatContent floatContent = widget.content as FloatContent;
        textStyle = floatContent.style;
      }

      return TextField(
        controller: _textController,
        autofocus: true,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.text,
        style: textStyle,
        decoration: InputDecoration(
          isDense: true,
          contentPadding: EdgeInsets.zero,
          border: InputBorder.none,
          hintText: hintText,
          hintStyle: const TextStyle(fontSize: 10, color: Colors.grey),
        ),
        onSubmitted: (value) => _submitAndEndEditing(value: value),
        focusNode: _focusNode,
      );
    } else {
      return widget.content!.buildWidget();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color cellColor = widget.hasError
        ? widget.errorColor
        : widget.defaultBackgroundColor;

    const double innerBorderFactor = 0.5;
    final double innerBorderWidth = widget.borderWidth * innerBorderFactor;

    final BorderSide topBorder = BorderSide(
      color: widget.borderColor,
      width: widget.id.row == 0 ? widget.borderWidth : innerBorderWidth,
    );
    final BorderSide leftBorder = BorderSide(
      color: widget.borderColor,
      width: widget.id.column == 0 ? widget.borderWidth : innerBorderWidth,
    );
    final BorderSide rightBorder = BorderSide(
      color: widget.borderColor,
      width: widget.id.column == widget.columns - 1
          ? widget.borderWidth
          : innerBorderWidth,
    );
    final BorderSide bottomBorder = BorderSide(
      color: widget.borderColor,
      width: widget.id.row == widget.rows - 1
          ? widget.borderWidth
          : innerBorderWidth,
    );

    final cellContainer = Container(
      width: widget.cellWidth,
      height: widget.cellHeight,
      decoration: BoxDecoration(
        color: cellColor,
        border: Border(
          top: topBorder,
          left: leftBorder,
          right: rightBorder,
          bottom: bottomBorder,
        ),
      ),
      padding: const EdgeInsets.all(4.0),
      child: Center(child: _buildContentWidget()),
    );

    final cell = GestureDetector(
      onDoubleTap: _startEditing,
      child: cellContainer,
    );

    final bool enableTooltip = widget.tooltipMessage.isNotEmpty && !_isEditing;

    return enableTooltip
        ? Tooltip(
            message: widget.tooltipMessage,
            waitDuration: const Duration(milliseconds: 500),
            child: cell,
          )
        : cell;
  }
}

// --------------------------------------------------------------------------
// 3. Grid Container Widget (FIXED: Explicit SizedBox sizing for scroll content)
// --------------------------------------------------------------------------

/// A constant for the error background color.
const Color _kErrorColor = Color(0xFFFEEAEA);

class CheckboxGridLayout extends StatelessWidget {
  final int rows;
  final int columns;
  final Map<CheckboxGridId, GridCellContent> initialChildren;

  static const double _kCellWidth = 120.0;
  static const double _kCellHeight = 40.0;

  const CheckboxGridLayout({
    super.key,
    required this.rows,
    required this.columns,
    required this.initialChildren,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: rows * columns,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        childAspectRatio: _kCellWidth / _kCellHeight,
      ),
      itemBuilder: (context, index) {
        final row = index ~/ columns;
        final column = index % columns;
        final id = CheckboxGridId(row: row, column: column);

        final content = initialChildren[id];
        final bool isDefined = content != null;
        final String tooltipMsg = isDefined ? content.tooltipMessage : '';
        // Error handling is currently in _CheckboxGridLayoutState,
        // which is being removed. For now, assume no errors.
        // This will be handled by the ViewModel later.
        const bool hasError = false;

        return GridCell(
          id: id,
          rows: rows,
          columns: columns,
          content: content,
          tooltipMessage: tooltipMsg,
          // onSubmitted will be handled by the ViewModel later
          onSubmitted: (id, newValue) {
            // Placeholder for now, will be replaced by ViewModel call
            //print('Cell $id submitted with value: $newValue');
          },
          defaultBackgroundColor: isDefined
              ? Colors.white
              : Colors.grey.shade100,
          errorColor: _kErrorColor,
          hasError: hasError,
          borderColor: Colors.black,
          borderWidth: 2.0,
          cellWidth: _kCellWidth,
          cellHeight: _kCellHeight,
        );
      },
    );
  }
}
