import 'package:flutter/material.dart';

import '../../core/themes/themes.dart';

class CustomAppBar extends StatelessWidget with PreferredSizeWidget {
  final Widget? leading;
  final List<Widget>? actions;
  final String title;
  final bool automaticallyImplyLeading;

  const CustomAppBar({
    Key? key,
    this.leading,
    this.actions,
    required this.title,
    this.automaticallyImplyLeading = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorPalette.primaryBrandColor,
      elevation: 0,
      automaticallyImplyLeading: automaticallyImplyLeading,
      leading: leading,
      title: Text(
        title,
        style: TextStyles.title.copyWith(color: ColorPalette.white),
      ),
      actions: actions,
      centerTitle: true,
      iconTheme: const IconThemeData(color: ColorPalette.white),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(50.0);
}
