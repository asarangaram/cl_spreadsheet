import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:async';

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

class CheckboxGridLayout extends StatefulWidget {
  final int rows;
  final int columns;
  final Map<CheckboxGridId, GridCellContent> initialChildren;

  const CheckboxGridLayout({
    super.key,
    required this.rows,
    required this.columns,
    required this.initialChildren,
  });

  @override
  State<CheckboxGridLayout> createState() => _CheckboxGridLayoutState();
}

class _CheckboxGridLayoutState extends State<CheckboxGridLayout> {
  // Variables for cell sizing
  static const double _kCellWidth = 120.0;
  static const double _kCellHeight = 40.0;

  late Map<CheckboxGridId, GridCellContent> _gridData;

  final Map<CheckboxGridId, bool> _errorMap = {};
  final Map<CheckboxGridId, Timer> _errorTimers = {};

  @override
  void initState() {
    super.initState();
    _gridData = Map.from(widget.initialChildren);
  }

  @override
  void dispose() {
    for (var timer in _errorTimers.values) {
      timer.cancel();
    }
    super.dispose();
  }

  void _clearTimer(CheckboxGridId id) {
    _errorTimers[id]?.cancel();
    _errorTimers.remove(id);
  }

  int? _tryParseRadix(String value, IntegerFormat format) {
    String cleanValue = value.toLowerCase().trim();
    int radix = 10;

    if (format == IntegerFormat.hex) {
      if (cleanValue.startsWith('0x')) {
        cleanValue = cleanValue.substring(2);
      }
      radix = 16;
    } else if (format == IntegerFormat.binary) {
      if (cleanValue.startsWith('0b')) {
        cleanValue = cleanValue.substring(2);
      }
      radix = 2;
    } else {
      cleanValue = cleanValue.replaceAll(',', '');
      return int.tryParse(cleanValue);
    }

    if (cleanValue.isEmpty) return null;

    return int.tryParse(cleanValue, radix: radix);
  }

  void _handleCellSubmitted(CheckboxGridId id, String newValue) {
    if (!mounted) return;

    final currentContent = _gridData[id];
    final String trimmedValue = newValue.trim();

    _clearTimer(id);

    if (currentContent != null && trimmedValue == currentContent.rawValue) {
      if (_errorMap.containsKey(id)) {
        setState(() {
          _errorMap.remove(id);
        });
      }
      return;
    }

    GridCellContent? newContent = currentContent;
    bool isValid = true;

    if (currentContent is TextContent) {
      newContent = TextContent(trimmedValue, style: currentContent.style);
    } else if (currentContent is IntegerContent) {
      final int? parsedInt = _tryParseRadix(
        trimmedValue,
        currentContent.format,
      );

      if (parsedInt != null) {
        newContent = IntegerContent(
          parsedInt,
          format: currentContent.format,
          style: currentContent.style,
          paddingCount: currentContent.paddingCount,
        );
      } else {
        isValid = false;
      }
    } else if (currentContent is FloatContent) {
      final double? parsedDouble = double.tryParse(trimmedValue);
      if (parsedDouble != null) {
        newContent = FloatContent(
          parsedDouble,
          precision: currentContent.precision,
          style: currentContent.style,
          paddingCount: currentContent.paddingCount,
        );
      } else {
        isValid = false;
      }
    } else if (trimmedValue.isEmpty) {
      newContent = null;
    }

    setState(() {
      if (isValid) {
        if (newContent != null) {
          _gridData[id] = newContent;
        } else {
          _gridData.remove(id);
        }
        _errorMap.remove(id);
      } else {
        _errorMap[id] = true;

        _errorTimers[id] = Timer(const Duration(seconds: 5), () {
          if (mounted) {
            setState(() {
              _errorMap.remove(id);
            });
          }
          _errorTimers.remove(id);
        });
      }
    });
  }

  Widget _buildCell(CheckboxGridId id) {
    final GridCellContent? content = _gridData[id];
    final bool isDefined = content != null;
    final String tooltipMsg = isDefined ? content.tooltipMessage : '';
    final bool hasError = _errorMap.containsKey(id);

    return GridCell(
      id: id,
      rows: widget.rows,
      columns: widget.columns,
      content: content,
      tooltipMessage: tooltipMsg,
      onSubmitted: _handleCellSubmitted,
      defaultBackgroundColor: isDefined ? Colors.white : Colors.grey.shade100,
      errorColor: _kErrorColor,
      hasError: hasError,
      borderColor: Colors.black,
      borderWidth: 2.0,
      cellWidth: _kCellWidth,
      cellHeight: _kCellHeight,
    );
  }

  Widget _buildRow(int row) {
    List<Widget> rowChildren = [];
    for (int c = 0; c < widget.columns; c++) {
      rowChildren.add(_buildCell(CheckboxGridId(row: row, column: c)));
    }
    return Row(mainAxisSize: MainAxisSize.min, children: rowChildren);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> gridRows = [];
    for (int r = 0; r < widget.rows; r++) {
      gridRows.add(_buildRow(r));
    }

    final double totalWidth = widget.columns * _kCellWidth;
    final double totalHeight = widget.rows * _kCellHeight;

    return LayoutBuilder(
      builder: (context, constraints) {
        final bool needsHorizontalSpacer = totalWidth < constraints.maxWidth;
        final bool needsVerticalSpacer = totalHeight < constraints.maxHeight;
        final bool needsHorizontalScroll = totalWidth > constraints.maxWidth;
        final bool needsVerticalScroll = totalHeight > constraints.maxHeight;

        // 1. Core Content Column (The grid itself)
        final Widget contentColumn = Column(
          mainAxisSize: MainAxisSize.min,
          children: gridRows,
        );

        // 2. Horizontal Layout: Spacer OR SizedBox (for scrolling)
        Widget horizontalLayout;
        if (needsHorizontalScroll) {
          // FIX 1: Wrap the content in a SizedBox to impose a finite width
          // inside the SingleChildScrollView (scroll direction)
          horizontalLayout = SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: totalWidth, child: contentColumn),
          );
        } else {
          // Spacer/Flex logic when content fits horizontally
          horizontalLayout = Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              contentColumn,
              if (needsHorizontalSpacer)
                Flexible(fit: FlexFit.loose, child: const SizedBox.expand()),
            ],
          );
        }

        // 3. Vertical Layout: Spacer OR SizedBox (for scrolling)
        Widget finalLayout;
        if (needsVerticalScroll) {
          // FIX 2: Wrap the content in a SizedBox to impose a finite height
          // inside the SingleChildScrollView (scroll direction)
          finalLayout = SingleChildScrollView(
            scrollDirection: Axis.vertical,
            child: SizedBox(height: totalHeight, child: horizontalLayout),
          );
        } else {
          // Spacer/Flex logic when content fits vertically
          finalLayout = Column(
            mainAxisSize: MainAxisSize.max, // Must be max for Flexible to work
            children: [
              horizontalLayout,
              if (needsVerticalSpacer)
                Flexible(fit: FlexFit.loose, child: const SizedBox.expand()),
            ],
          );
        }

        // Return the resulting layout. Since the LayoutBuilder's constraints
        // are finite (from GridExampleScreen's Container), the Column/Flexible
        // structure will work, or the ScrollView structure will work.
        return finalLayout;
      },
    );
  }
}

// --------------------------------------------------------------------------
// 4. Example Usage Widget (Unchanged)
// --------------------------------------------------------------------------

class GridExampleScreen extends StatelessWidget {
  const GridExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final initialGridContentMap = <CheckboxGridId, GridCellContent>{
      // R0: Headers
      CheckboxGridId(row: 0, column: 0): const TextContent('Padded Ints (Dec)'),
      CheckboxGridId(row: 0, column: 1): const TextContent('Padded Floats'),
      CheckboxGridId(row: 0, column: 2): const TextContent('Hex (Edit in Hex)'),
      CheckboxGridId(row: 0, column: 3): const TextContent(
        'Binary (Edit in Bin)',
      ),

      // R1: Decimal Integers
      CheckboxGridId(row: 1, column: 0): const IntegerContent(
        1,
        paddingCount: 8,
      ),
      CheckboxGridId(row: 2, column: 0): const IntegerContent(
        1234,
        paddingCount: 8,
      ),
      CheckboxGridId(row: 3, column: 0): const IntegerContent(
        1000000,
        paddingCount: 8,
      ),

      // R1: Floats
      CheckboxGridId(row: 1, column: 1): const FloatContent(
        1.23,
        precision: 2,
        paddingCount: 10,
      ),
      CheckboxGridId(row: 2, column: 1): const FloatContent(
        1234.5,
        precision: 3,
        paddingCount: 10,
      ),
      CheckboxGridId(row: 3, column: 1): const FloatContent(
        1234567.89,
        precision: 2,
        paddingCount: 10,
      ),

      // R1: Hex Codes
      CheckboxGridId(row: 1, column: 2): const IntegerContent(
        15,
        format: IntegerFormat.hex,
      ),
      CheckboxGridId(row: 2, column: 2): const IntegerContent(
        255,
        format: IntegerFormat.hex,
      ),
      CheckboxGridId(row: 3, column: 2): const IntegerContent(
        65535,
        format: IntegerFormat.hex,
      ),

      // R1: Binary Codes
      CheckboxGridId(row: 1, column: 3): const IntegerContent(
        16,
        format: IntegerFormat.binary,
      ),
      CheckboxGridId(row: 2, column: 3): const IntegerContent(
        12,
        format: IntegerFormat.binary,
      ),
      CheckboxGridId(row: 3, column: 3): const IntegerContent(
        255,
        format: IntegerFormat.binary,
      ),
    };

    // We will use 10 rows and 4 columns here to test the vertical scrolling/spacer logic
    return Container(
      width: 400,
      height: 400,

      padding: const EdgeInsets.all(8.0),
      color: Colors.white,
      child: CheckboxGridLayout(
        rows: 10, // Increased rows to 10 to test scrolling when height > 400
        columns: 4,
        initialChildren: initialGridContentMap,
      ),
    );
  }
}
