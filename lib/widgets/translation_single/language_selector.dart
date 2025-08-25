import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String value;
  final ValueChanged<String?> onChanged;
  final String label;

  const LanguageSelector({
    super.key,
    required this.value,
    required this.onChanged,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: const [
        DropdownMenuItem(value: 'en', child: Text('English')),
        DropdownMenuItem(value: 'sr', child: Text('Serbian')),
      ],
      onChanged: onChanged,
    );
  }
}