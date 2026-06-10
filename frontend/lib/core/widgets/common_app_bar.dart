import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Reusable AppBar matching the Figma design.
class CommonAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CommonAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBack = true,
    this.backgroundColor,
  });

  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final Color? backgroundColor;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: backgroundColor ?? AppColors.background,
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Metropolis',
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.dark,
        ),
      ),
      leading: showBack
          ? (leading ??
              IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 20),
                color: AppColors.dark,
                onPressed: () => Navigator.of(context).pop(),
              ))
          : null,
      automaticallyImplyLeading: showBack,
      actions: actions,
      iconTheme: const IconThemeData(color: AppColors.dark),
    );
  }
}
