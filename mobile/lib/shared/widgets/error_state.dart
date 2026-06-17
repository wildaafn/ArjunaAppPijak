import 'package:flutter/material.dart';
import 'arjuna_brand.dart';

class AppErrorWidget extends StatelessWidget {
  final String title;
  final String message;
  final VoidCallback onRetry;
  final IconData icon;

  const AppErrorWidget({
    super.key,
    required this.title,
    required this.message,
    required this.onRetry,
    this.icon = Icons.cloud_off_outlined,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final errorColor = Theme.of(context).colorScheme.error;
    final titleColor = ArjunaColors.title(isDark);

    // Clean up "Exception: " prefix from message if present
    String cleanedMessage = message;
    if (cleanedMessage.startsWith('Exception: ')) {
      cleanedMessage = cleanedMessage.substring('Exception: '.length);
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(28.0, 28.0, 28.0, 110.0), // Offsets the bottom nav bar visually
        child: Semantics(
          container: true,
          label: '$title. $cleanedMessage',
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: errorColor.withValues(alpha: isDark ? 0.14 : 0.09),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: errorColor.withValues(alpha: isDark ? 0.24 : 0.16),
                  ),
                ),
                child: Icon(icon, size: 32, color: errorColor),
              ),
              const SizedBox(height: 22),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: titleColor,
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                cleanedMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: isDark ? Colors.white54 : ArjunaColors.muted,
                  height: 1.5,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: 156,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text('Coba Lagi'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
