import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class NewSheetForm extends StatefulWidget {
  final double width;
  final double height;
  final double borderRadius;
  final void Function(String name, int rows, int cols)? onSubmit;

  const NewSheetForm({
    super.key,
    this.width = 340,
    this.height = 310,
    this.borderRadius = 18,
    this.onSubmit,
  });

  @override
  State<NewSheetForm> createState() => NewSheetFormState();
}

class NewSheetFormState extends State<NewSheetForm> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _rowCtrl = TextEditingController(text: "10");
  final _colCtrl = TextEditingController(text: "5");

  final RegExp _invalidFileChars = RegExp(r'[\/\\\:\*\?\"\<\>\|]');

  String? _validateName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return "Name required";
    }
    if (_invalidFileChars.hasMatch(value)) {
      return "Invalid characters: / \\ : * ? \" < > |";
    }
    return null;
  }

  String? _validateNumber(String? value) {
    final num = int.tryParse(value ?? "");
    if (num == null) return "Required";
    if (num < 2) return "Min 2";
    if (num > 99) return "Max 99";
    return null;
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      widget.onSubmit?.call(
        _nameCtrl.text,
        int.parse(_rowCtrl.text),
        int.parse(_colCtrl.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(widget.borderRadius),
          border: Border.all(width: 2, color: Colors.grey.shade300),
          boxShadow: [
            BoxShadow(
              blurRadius: 8,
              offset: Offset(0, 4),
              color: Colors.black.withValues(alpha: 0.10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.borderRadius - 2),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Container(
                  height: 42,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: Colors.grey.shade200,
                  child: const Text(
                    "New Spreadsheet",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Spreadsheet Name"),
                        const SizedBox(height: 4),
                        ShadInputFormField(
                          controller: _nameCtrl,
                          validator: _validateName,
                          textInputAction: TextInputAction.next,
                          /* decoration: const InputDecoration(
                            isDense: true,
                            border: OutlineInputBorder(),
                          ), */
                        ),
                        const SizedBox(height: 14),

                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Rows"),
                                  const SizedBox(height: 4),
                                  ShadInputFormField(
                                    controller: _rowCtrl,
                                    keyboardType: TextInputType.number,
                                    validator: _validateNumber,
                                    /* decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ), */
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("Columns"),
                                  const SizedBox(height: 4),
                                  ShadInputFormField(
                                    controller: _colCtrl,
                                    keyboardType: TextInputType.number,
                                    validator: _validateNumber,
                                    /* decoration: const InputDecoration(
                                      isDense: true,
                                      border: OutlineInputBorder(),
                                    ), */
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        Align(
                          alignment: Alignment.centerRight,
                          child: ShadButton.secondary(
                            onPressed: _submit,
                            child: const Text("Create"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
