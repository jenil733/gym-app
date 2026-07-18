import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gym/scr/core/constants/app_colors.dart';
import 'package:gym/scr/core/utils/helper/text_helper.dart';

class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.showBackButton = true,
    this.centerTitle = false,
  });

  final String title;
  final bool showBackButton;
  final bool centerTitle;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.transparent,
      surfaceTintColor: AppColors.transparent,
      shadowColor: AppColors.transparent,
      scrolledUnderElevation: 0,
      elevation: 0,
      centerTitle: centerTitle,
      leading: showBackButton
          ? IconButton(
              onPressed: Get.back<void>,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: AppColors.white,
              ),
            )
          : null,
      title: Text(title, style: TextHelper.appBarTitle),
    );
  }
}

class CommonBackHeader extends StatelessWidget {
  const CommonBackHeader({super.key, required this.title, this.onBack});

  final String title;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton.filled(
          onPressed: onBack ?? Get.back<void>,
          style: IconButton.styleFrom(
            backgroundColor: AppColors.surfaceHigh,
            foregroundColor: AppColors.textOnDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        const SizedBox(width: 10),
        Expanded(child: Text(title, style: TextHelper.homeTitle)),
      ],
    );
  }
}
