import 'package:flutter/material.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';
import 'package:gym/scr/presentation/view/auth/widget/filedlabel.dart';

class GenderDropdown extends StatelessWidget {
  const GenderDropdown({
    required this.label,
    required this.value,
    required this.icon,
    required this.accent,
    required this.fillColor,
    required this.borderColor,
    required this.validator,
    required this.onChanged,
  });

  final String label;
  final String? value;
  final IconData icon;
  final Color accent;
  final Color fillColor;
  final Color borderColor;
  final String? Function(String?) validator;
  final ValueChanged<String?> onChanged;

  TextStyle get _textStyle {
    return TextHelper.fieldText;
  }

  TextStyle get _hintStyle {
    return TextHelper.fieldHint;
  }

  @override
  Widget build(BuildContext context) {
    return FormField<String>(
      initialValue: value,
      validator: validator,
      builder: (field) {
        final hasError = field.hasError;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FieldLabel(label),
            const SizedBox(height: 8),
            DecoratedBox(
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: hasError ? accent : borderColor,
                  width: hasError ? 1.6 : 1.4,
                ),
              ),
              child: SizedBox(
                height: 54,
                child: Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 20, right: 22),
                      child: Icon(icon, color: accent, size: 28),
                    ),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: value,
                          hint: Text('Gender', style: _hintStyle),
                          isExpanded: true,
                          dropdownColor: fillColor,
                          borderRadius: BorderRadius.circular(18),
                          icon: Icon(
                            Icons.arrow_drop_down_rounded,
                            color: accent,
                          ),
                          style: _textStyle,
                          items: ['Male', 'Female']
                              .map(
                                (gender) => DropdownMenuItem(
                                  value: gender,
                                  child: Text(gender),
                                ),
                              )
                              .toList(),
                          onChanged: (newValue) {
                            field.didChange(newValue);
                            onChanged(newValue);
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                  ],
                ),
              ),
            ),
            if (hasError)
              Padding(
                padding: const EdgeInsets.only(left: 16, top: 7),
                child: Text(field.errorText ?? '', style: TextHelper.error),
              ),
          ],
        );
      },
    );
  }
}
