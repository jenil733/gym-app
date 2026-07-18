import 'package:flutter/material.dart';
import 'package:gym/scr/presentation/widgets/common/common_button.dart';

// ignore: unused_element
class GradientButton extends StatelessWidget {
  const GradientButton({super.key, required this.onPressed});

  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return CommonButton(
      label: 'Continue',
      onPressed: onPressed,
      height: 52,
      borderRadius: 18,
      trailingIcon: Icons.arrow_forward_rounded,
      useGradient: true,
    );
  }
}
