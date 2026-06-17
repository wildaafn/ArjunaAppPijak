import 'package:flutter/material.dart';

class SettingSectionTitle extends StatelessWidget {
  final String title;

  const SettingSectionTitle({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Text(
      title.toUpperCase(),
      style: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w800,
        color: isDark ? const Color(0xFF16C7B7) : const Color(0xFF0B9F91),
        letterSpacing: 1.4,
      ),
    );
  }
}
