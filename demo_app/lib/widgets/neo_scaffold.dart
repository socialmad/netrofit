import 'package:flutter/material.dart';
import '../theme/neo_theme.dart';

class NeoScaffold extends StatelessWidget {
  final Widget body;
  final String title;
  final Widget? bottom;

  const NeoScaffold({
    super.key,
    required this.body,
    required this.title,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: NeoColors.background,
      appBar: AppBar(
        backgroundColor: NeoColors.primary,
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(
            color: NeoColors.border,
            width: NeoDimensions.borderWidth,
          ),
        ),
        title: Text(
          title.toUpperCase(),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
        bottom: bottom != null
            ? PreferredSize(
                preferredSize: const Size.fromHeight(80),
                child: Container(
                  decoration: const BoxDecoration(
                    border: Border(
                      top: BorderSide(
                        color: NeoColors.border,
                        width: NeoDimensions.borderWidth,
                      ),
                    ),
                    color: NeoColors.background,
                  ),
                  padding: const EdgeInsets.all(16),
                  child: bottom,
                ),
              )
            : null,
      ),
      body: body,
    );
  }
}
