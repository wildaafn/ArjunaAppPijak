import 'package:flutter/material.dart';

class SplashContent extends StatelessWidget {
  final Animation<double> fadeAnimation;
  final Animation<double> scaleAnimation;
  final bool isDark;

  const SplashContent({
    super.key,
    required this.fadeAnimation,
    required this.scaleAnimation,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: fadeAnimation,
      child: ScaleTransition(
        scale: scaleAnimation,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildLogo(),
            const SizedBox(height: 40),
            _buildAppName(),
            const SizedBox(height: 12),
            _buildTagline(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      width: 150,
      height: 150,
      child: Image.asset(
        'assets/images/arjuna-logo.png',
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }

  Widget _buildAppName() {
    return Text(
      'ARJUNA',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w900,
        letterSpacing: 10,
        color: isDark ? Colors.white : const Color(0xFF1A1A1A),
      ),
    );
  }

  Widget _buildTagline() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Text(
        'ANALISIS HARGA & TINJAUAN PANGAN NUSANTARA',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w600,
          letterSpacing: 2.0,
          color: isDark ? Colors.white54 : Colors.black45,
        ),
      ),
    );
  }
}
