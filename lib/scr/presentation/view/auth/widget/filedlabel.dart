import 'package:flutter/material.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(label, style: TextHelper.fieldLabel);
  }
}

InputDecoration fieldDecoration({
  required IconData icon,
  required String hintText,
  required Color accent,
  required Color fillColor,
  required Color borderColor,
}) {
  return InputDecoration(
    hintText: hintText,
    hintStyle: TextHelper.fieldHint,
    errorStyle: TextHelper.error,
    prefixIcon: Padding(
      padding: const EdgeInsets.only(left: 20, right: 12),
      child: Icon(icon, color: accent, size: 28),
    ),
    prefixIconConstraints: const BoxConstraints(minWidth: 70),
    filled: true,
    fillColor: fillColor,
    contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: borderColor, width: 1.4),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: accent, width: 1.6),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: accent, width: 1.4),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(18),
      borderSide: BorderSide(color: accent, width: 1.6),
    ),
  );
}
