import 'package:cl_spreadsheet/view/spread_sheet_viewer/cell_content/float_content.dart';
import 'package:cl_spreadsheet/view/spread_sheet_viewer/cell_content/grid_cell_content.dart';
import 'package:cl_spreadsheet/view/spread_sheet_viewer/cell_content/integer_content.dart';
import 'package:cl_spreadsheet/view/spread_sheet_viewer/cell_content/text_content.dart';
import 'package:flutter/material.dart';

import 'package:cl_spreadsheet/models/store/checkbox_grid_id.dart'; // Import CheckboxGridId

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
    } else {}
  }

  void _submitAndEndEditing({String? value}) {
    widget.onSubmitted(widget.id, value ?? _textController.text);

    setState(() {
      _isEditing = false;
    });
  }

  Widget _buildContentWidget() {
    return Builder(
      builder: (context) {
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
              hintText = 'Formatted: ${intContent.getFormattedDisplayValue()}';
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
          return widget.content!.buildWidget(context);
        }
      },
    );
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
