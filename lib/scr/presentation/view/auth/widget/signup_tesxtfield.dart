import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/view/auth/widget/filedlabel.dart';

// ignore: unused_element
class SignUpTextField extends StatelessWidget {
  const SignUpTextField({
    super.key,
    required this.label,
    required this.icon,
    required this.hintText,
    required this.accent,
    required this.fillColor,
    required this.borderColor,
    required this.validator,
    this.controller,
    this.keyboardType,
    this.inputFormatters,
    this.readOnly = false,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final String hintText;
  final Color accent;
  final Color fillColor;
  final Color borderColor;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final bool readOnly;
  final VoidCallback? onTap;
  final String? Function(String?) validator;
  final TextEditingController? controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FieldLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          cursorColor: accent,
          style: TextHelper.fieldText,
          decoration: fieldDecoration(
            icon: icon,
            hintText: hintText,
            accent: accent,
            fillColor: fillColor,
            borderColor: borderColor,
          ),
        ),
      ],
    );
  }
}
