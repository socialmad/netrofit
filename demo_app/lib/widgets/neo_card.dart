import 'package:flutter/material.dart';
import '../theme/neo_theme.dart';

class NeoCard extends StatelessWidget {
  final Widget child;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final VoidCallback? onTap;

  const NeoCard({
    super.key,
    required this.child,
    this.backgroundColor,
    this.padding,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white,
        border: Border.all(
          color: NeoColors.border,
          width: NeoDimensions.borderWidth,
        ),
        boxShadow: const [
          BoxShadow(
            color: NeoColors.border,
            offset: NeoDimensions.shadowOffset,
            blurRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(16.0),
        child: child,
      ),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: card);
    }

    return card;
  }
}
