import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../models/sheet_properties.dart';

class NewSheetForm extends StatefulWidget {
  final VoidCallback onClose;
  final void Function({required SheetProperties sheetProperties}) onSubmit;

  const NewSheetForm({
    super.key,
    required this.onClose,
    required this.onSubmit,
  });

  @override
  State<NewSheetForm> createState() => _NewSheetFormState();
}

class _NewSheetFormState extends State<NewSheetForm> {
  final double borderRadius = 18;
  final double bannerHeight = 48;
  final double width = 420;
  final double height = 340;

  final _formKey = GlobalKey<ShadFormState>();
  final nameController = TextEditingController();
  final rowController = TextEditingController();
  final colController = TextEditingController();

  @override
  void dispose() {
    nameController.dispose();
    rowController.dispose();
    colController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = ShadTheme.of(context).colorScheme;

    return SizedBox(
      width: width,
      height: height,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(width: 2, color: theme.border),
          color: theme.background,
          boxShadow: [BoxShadow(blurRadius: 8, offset: const Offset(0, 4))],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(borderRadius - 2),
          child: ShadForm(
            key: _formKey,
            child: Column(
              children: [
                _buildBanner(theme),
                Expanded(child: _buildFormFields()),
                _buildSubmitButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBanner(ShadColorScheme theme) {
    return Container(
      height: bannerHeight,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      color: theme.muted,
      child: Row(
        children: [
          const Text(
            "New spreadsheet",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          GestureDetector(
            onTap: widget.onClose,
            child: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFields() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        spacing: 12,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ShadInputFormField(
            id: "Spreadsheet name",
            controller: nameController,
            label: const Text("Spreadsheet name"),
            validator: (value) {
              if (value.isEmpty) return "Required";
              final invalid = RegExp(r'[<>:"/\\|?*]');
              if (invalid.hasMatch(value)) return "Invalid characters";
              if (value.length < 3) return "Min 3 characters";
              return null;
            },
          ),
          Row(
            spacing: 8,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _numberField("Rows", rowController)),
              Expanded(child: _numberField("Columns", colController)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _numberField(String label, TextEditingController controller) {
    return ShadInputFormField(
      controller: controller,
      id: label,
      label: Text(label),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      keyboardType: TextInputType.number,
      validator: (value) {
        if (value.isEmpty) return "Required";
        final numValue = int.tryParse(value);
        if (numValue == null) return "Invalid";
        if (numValue < 2 || numValue > 99) return "2–99 only";
        return null;
      },
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 8, right: 16, bottom: 16),
      child: Align(
        alignment: Alignment.centerRight,
        child: ShadButton.secondary(
          onPressed: () {
            if (_formKey.currentState!.saveAndValidate()) {
              final map = _formKey.currentState!.value;
              widget.onSubmit(
                sheetProperties: SheetProperties(
                  name: map["Spreadsheet name"],
                  rows: int.parse(map["Rows"]),
                  columns: int.parse(map["Columns"]),
                ),
              );
            }
          },
          child: const Text("Create"),
        ),
      ),
    );
  }
}
