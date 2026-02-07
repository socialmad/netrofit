import 'package:flutter/material.dart';
import '../theme/neo_theme.dart';

class NeoTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const NeoTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
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
      child: TextField(
        controller: controller,
        style: const TextStyle(fontWeight: FontWeight.bold),
        decoration: InputDecoration(
          hintText: hintText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }
}
