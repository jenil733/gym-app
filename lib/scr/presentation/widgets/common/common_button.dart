import 'package:flutter/material.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';

class CommonButton extends StatelessWidget {
  const CommonButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.trailingIcon,
    this.height = 54,
    this.borderRadius = 12,
    this.fontSize,
    this.backgroundColor = AppColors.primary,
    this.disabledBackgroundColor = AppColors.field,
    this.foregroundColor = AppColors.white,
    this.disabledForegroundColor = AppColors.textMuted,
    this.useGradient = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final IconData? trailingIcon;
  final double height;
  final double borderRadius;
  final double? fontSize;
  final Color backgroundColor;
  final Color disabledBackgroundColor;
  final Color foregroundColor;
  final Color disabledForegroundColor;
  final bool useGradient;

  bool get _isEnabled => onPressed != null;

  TextStyle get _textStyle {
    return TextHelper.button.copyWith(
      fontSize: fontSize,
      color: _isEnabled ? foregroundColor : disabledForegroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (useGradient) {
      return _GradientButtonBody(
        label: label,
        onPressed: onPressed,
        trailingIcon: trailingIcon,
        height: height,
        borderRadius: borderRadius,
        textStyle: _textStyle,
      );
    }

    final buttonStyle = FilledButton.styleFrom(
      backgroundColor: backgroundColor,
      disabledBackgroundColor: disabledBackgroundColor,
      foregroundColor: foregroundColor,
      disabledForegroundColor: disabledForegroundColor,
      textStyle: _textStyle,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );

    return SizedBox(
      height: height,
      width: double.infinity,
      child: icon == null
          ? FilledButton(
              onPressed: onPressed,
              style: buttonStyle,
              child: _ButtonLabel(
                label: label,
                textStyle: _textStyle,
                trailingIcon: trailingIcon,
                foregroundColor: _isEnabled
                    ? foregroundColor
                    : disabledForegroundColor,
              ),
            )
          : FilledButton.icon(
              onPressed: onPressed,
              style: buttonStyle,
              icon: Icon(icon),
              label: Text(label, style: _textStyle),
            ),
    );
  }
}

class _ButtonLabel extends StatelessWidget {
  const _ButtonLabel({
    required this.label,
    required this.textStyle,
    required this.trailingIcon,
    required this.foregroundColor,
  });

  final String label;
  final TextStyle textStyle;
  final IconData? trailingIcon;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    if (trailingIcon == null) {
      return Text(label, style: textStyle);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: textStyle),
        const SizedBox(width: 10),
        Icon(trailingIcon, color: foregroundColor, size: 20),
      ],
    );
  }
}

class _GradientButtonBody extends StatelessWidget {
  const _GradientButtonBody({
    required this.label,
    required this.onPressed,
    required this.trailingIcon,
    required this.height,
    required this.borderRadius,
    required this.textStyle,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? trailingIcon;
  final double height;
  final double borderRadius;
  final TextStyle textStyle;

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        color: isEnabled ? null : AppColors.field,
        gradient: isEnabled
            ? const LinearGradient(colors: AppColors.actionGradient)
            : null,
        boxShadow: isEnabled
            ? const [
                BoxShadow(
                  color: AppColors.primarySoft,
                  blurRadius: 22,
                  offset: Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: SizedBox(
            height: height,
            width: double.infinity,
            child: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: textStyle),
                  if (trailingIcon != null) ...[
                    const SizedBox(width: 12),
                    Icon(trailingIcon, color: AppColors.white, size: 20),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
