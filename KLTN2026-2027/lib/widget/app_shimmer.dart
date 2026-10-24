import 'package:flutter/material.dart';
import '../app/theme/theme.dart';

/// Lightweight native skeleton/shimmer placeholder widget for loading states.
/// Zero external dependencies, pure Flutter animation.
class AppShimmer extends StatefulWidget {
  final double? width;
  final double? height;
  final BorderRadiusGeometry borderRadius;
  final Widget? child;

  const AppShimmer({
    super.key,
    this.width,
    this.height,
    this.borderRadius = AppRadius.borderSm,
    this.child,
  });

  /// Shimmer for a circular element (e.g. user avatar).
  factory AppShimmer.circle({
    Key? key,
    required double radius,
  }) {
    return AppShimmer(
      key: key,
      width: radius * 2,
      height: radius * 2,
      borderRadius: BorderRadius.circular(radius),
    );
  }

  /// Shimmer for a text line.
  factory AppShimmer.line({
    Key? key,
    double width = double.infinity,
    double height = 14,
    BorderRadiusGeometry borderRadius = AppRadius.tag,
  }) {
    return AppShimmer(
      key: key,
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  /// Shimmer for a card block.
  factory AppShimmer.card({
    Key? key,
    double width = double.infinity,
    double height = 100,
    BorderRadiusGeometry borderRadius = AppRadius.card,
  }) {
    return AppShimmer(
      key: key,
      width: width,
      height: height,
      borderRadius: borderRadius,
    );
  }

  @override
  State<AppShimmer> createState() => _AppShimmerState();
}

class _AppShimmerState extends State<AppShimmer> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _animation = Tween<double>(begin: 0.35, end: 0.85).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final baseColor = colors.surfaceSubtle;

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: baseColor.withValues(alpha: _animation.value),
            borderRadius: widget.borderRadius,
            border: Border.all(color: colors.cardBorder.withValues(alpha: 0.3)),
          ),
          child: widget.child,
        );
      },
    );
  }
}
