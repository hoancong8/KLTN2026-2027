// lib/widget/app_network_image.dart

import 'package:flutter/material.dart';
import '../app/theme/theme.dart';

class AppNetworkImage extends StatelessWidget {
  final String? imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool isCircle;
  final Widget? fallbackWidget;
  final IconData defaultFallbackIcon;
  final Color? backgroundColor;

  const AppNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.isCircle = false,
    this.fallbackWidget,
    this.defaultFallbackIcon = Icons.sports_tennis_rounded,
    this.backgroundColor,
  });

  bool get _isValidUrl {
    if (imageUrl == null) return false;
    final trimmed = imageUrl!.trim();
    if (trimmed.isEmpty || trimmed == 'null' || trimmed == 'undefined') return false;
    final uri = Uri.tryParse(trimmed);
    return uri != null && (uri.scheme == 'http' || uri.scheme == 'https');
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final effectiveBgColor = backgroundColor ?? colors.surfaceSubtle;

    Widget placeholder = Container(
      width: width,
      height: height,
      color: effectiveBgColor,
      child: Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: colors.primary.withValues(alpha: 0.5),
          ),
        ),
      ),
    );

    Widget fallback = fallbackWidget ??
        Container(
          width: width,
          height: height,
          color: effectiveBgColor,
          child: Center(
            child: Icon(
              defaultFallbackIcon,
              size: (width != null && height != null) ? (width! * 0.45).clamp(16.0, 36.0) : 24.0,
              color: colors.primary.withValues(alpha: 0.6),
            ),
          ),
        );

    Widget imageWidget;

    if (!_isValidUrl) {
      imageWidget = fallback;
    } else {
      imageWidget = Image.network(
        imageUrl!.trim(),
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder;
        },
        errorBuilder: (context, error, stackTrace) {
          return fallback;
        },
      );
    }

    if (isCircle) {
      return ClipOval(
        child: SizedBox(
          width: width,
          height: height,
          child: imageWidget,
        ),
      );
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: SizedBox(
          width: width,
          height: height,
          child: imageWidget,
        ),
      );
    }

    return SizedBox(
      width: width,
      height: height,
      child: imageWidget,
    );
  }
}
