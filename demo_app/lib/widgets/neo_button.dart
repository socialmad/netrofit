import 'package:flutter/material.dart';
import '../theme/neo_theme.dart';

class NeoButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final Color? color;
  final Color? textColor;

  const NeoButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.color,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: color ?? NeoColors.primary,
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
        child: Text(
          text,
          style: TextStyle(
            color: textColor ?? Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
