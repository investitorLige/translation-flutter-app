import 'package:flutter/material.dart';

class TranslationInput extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final int maxLines;
  final bool readOnly;
  final bool expands;

  const TranslationInput({
    super.key,
    required this.controller,
    required this.label,
    this.maxLines = 1,
    this.readOnly = false,
    this.expands = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        alignLabelWithHint: true,
      ),
      maxLines: expands ? null : maxLines,
      readOnly: readOnly,
      expands: expands,
      textAlignVertical: TextAlignVertical.top,
    );
  }
}