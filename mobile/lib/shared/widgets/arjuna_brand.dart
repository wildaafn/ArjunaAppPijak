import 'package:flutter/material.dart';
import 'app_background.dart';

class ArjunaColors {
  static const navy = Color(0xFF07345A);
  static const deepNavy = Color(0xFF031827);
  static const teal = Color(0xFF16C7B7);
  static const tealDark = Color(0xFF0B9F91);
  static const gold = Color(0xFFE8C766);
  static const ivory = Color(0xFFFFFBF0);
  static const softIvory = Color(0xFFFFFAED);
  static const muted = Color(0xFF6A7D85);

  static Color appBarSurface(bool isDark) => isDark
      ? deepNavy.withValues(alpha: 0.95)
      : const Color(0xFFEAF8F4).withValues(alpha: 0.92);

  static Color title(bool isDark) => isDark ? const Color(0xFFEAF8F4) : navy;
  static Color accent(bool isDark) => isDark ? gold : tealDark;
}

class ArjunaAssets {
  static const logo = 'assets/images/arjuna-logo.png';
  static const mascotThinking = 'assets/images/arjuna_mascot_thinking.png';
  static const mascotAlert = 'assets/images/arjuna_mascot_alert.png';
  static const mascotCelebrate = 'assets/images/arjuna_mascot_celebrate.png';
  static const mascotWorried = 'assets/images/arjuna_mascot_worried.png';
  static const mascotPresenting = 'assets/images/arjuna_mascot_presenting.png';
}

class ArjunaLogoMark extends StatelessWidget {
  final double size;
  final double padding;
  final double radius;

  const ArjunaLogoMark({
    super.key,
    this.size = 38,
    this.padding = 3,
    this.radius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SizedBox(
      width: size,
      height: size,
      child: Padding(
        padding: EdgeInsets.all(padding),
        child: Image.asset(
          ArjunaAssets.logo,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          errorBuilder: (_, e, st) => Icon(
            Icons.architecture_rounded,
            color: ArjunaColors.accent(isDark),
            size: size * 0.58,
          ),
        ),
      ),
    );
  }
}

class ArjunaAppBarBackground extends StatelessWidget {
  const ArjunaAppBarBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: ArjunaColors.appBarSurface(isDark),
        border: Border(
          bottom: BorderSide(
            color: isDark
                ? ArjunaColors.gold.withValues(alpha: 0.1)
                : ArjunaColors.navy.withValues(alpha: 0.05),
          ),
        ),
      ),
      child: ClipRect(
        child: CustomPaint(
          painter: BatikKawungPainter(
            color: isDark
                ? ArjunaColors.gold.withValues(alpha: 0.025)
                : ArjunaColors.navy.withValues(alpha: 0.03),
          ),
        ),
      ),
    );
  }
}
