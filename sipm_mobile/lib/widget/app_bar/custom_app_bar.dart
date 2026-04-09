import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sipm_mobile/app/consts/app_path.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final Widget? titleWidget;
  final Widget? leading;
  final List<Widget>? actions;
  final bool showLogo;
  final bool showBackButton;
  final VoidCallback? onBackPressed;
  final VoidCallback? onLogoPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final bool centerTitle;
  final double? leadingWidth;
  final double? titleSpacing;
  final PreferredSizeWidget? bottom;
  final double logoSize;

  const CustomAppBar({
    super.key,
    this.title,
    this.titleWidget,
    this.leading,
    this.actions,
    this.showLogo = false,
    this.showBackButton = false,
    this.onBackPressed,
    this.onLogoPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.centerTitle = false,
    this.leadingWidth,
    this.titleSpacing,
    this.bottom,
    this.logoSize = 32,
  });

  @override
  Size get preferredSize =>
      Size.fromHeight(kToolbarHeight + (bottom?.preferredSize.height ?? 0));

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: backgroundColor ?? Colors.white,
      foregroundColor: foregroundColor ?? Colors.black87,
      elevation: elevation,
      centerTitle: centerTitle,
      leadingWidth: leadingWidth,
      titleSpacing:
          titleSpacing ??
          (leading != null || showLogo || showBackButton ? 0 : 16),
      leading: _buildLeading(context),
      title: _buildTitle(context),
      actions: actions,
      bottom: bottom,
    );
  }

  Widget? _buildLeading(BuildContext context) {
    if (leading != null) {
      return leading;
    }

    if (showBackButton) {
      return IconButton(
        onPressed: onBackPressed ?? () => context.pop(),
        icon: Icon(
          Icons.arrow_back_ios_new,
          color: foregroundColor ?? Colors.black87,
        ),
      );
    }

    if (showLogo) {
      return Builder(
        builder: (ctx) => GestureDetector(
          onTap: onLogoPressed ?? () => Scaffold.of(ctx).openDrawer(),
          child: Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            child: Image.asset(
              AppPath.icApp,
              width: logoSize,
              height: logoSize,
              fit: BoxFit.contain,
            ),
          ),
        ),
      );
    }

    return null;
  }

  Widget? _buildTitle(BuildContext context) {
    if (titleWidget != null) {
      return titleWidget;
    }

    if (title != null) {
      return Text(
        title!,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: foregroundColor ?? Colors.black87,
        ),
      );
    }

    return null;
  }
}

/// AppBar with logo and custom title widget
class CustomAppBarWithLogo extends StatelessWidget
    implements PreferredSizeWidget {
  final Widget? titleWidget;
  final List<Widget>? actions;
  final VoidCallback? onLogoPressed;
  final Color? backgroundColor;

  const CustomAppBarWithLogo({
    super.key,
    this.titleWidget,
    this.actions,
    this.onLogoPressed,
    this.backgroundColor,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return CustomAppBar(
      showLogo: true,
      onLogoPressed: onLogoPressed,
      titleWidget: titleWidget,
      actions: actions,
      backgroundColor: backgroundColor,
      titleSpacing: 0,
    );
  }
}
