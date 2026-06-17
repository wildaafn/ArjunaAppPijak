import 'package:flutter/material.dart';
import '../../../../shared/domain/models.dart';
import '../../../../shared/widgets/arjuna_brand.dart';
import 'setting_card_wrapper.dart';

class AboutAppSection extends StatelessWidget {
  final AppMetadata metadata;

  const AboutAppSection({super.key, required this.metadata});

  @override
  Widget build(BuildContext context) {
    final about = metadata.aboutUs;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SettingCardWrapper(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const ArjunaLogoMark(size: 58, padding: 3, radius: 18),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arjuna Mobile',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: ArjunaColors.title(isDark),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Versi ${about['version'] ?? '1.0.0'}',
                        style: TextStyle(
                          color: isDark
                              ? Colors.white38
                              : const Color(0xFF6A7D85),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              about['description'] ?? '',
              style: TextStyle(
                fontSize: 14,
                height: 1.55,
                color: isDark ? Colors.white70 : const Color(0xFF2C3E50),
              ),
            ),
            const SizedBox(height: 20),
            const Divider(height: 1),
            const SizedBox(height: 12),
            _buildInfoRow(context, 'Developer', about['developer'] ?? ''),
            _buildInfoRow(context, 'Status', 'Stable Release'),
            _buildInfoRow(context, 'Update Terakhir', metadata.updatedAt),
          ],
        ),
      ),
    );
  }
 
  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navy = isDark ? const Color(0xFFEAF8F4) : const Color(0xFF07345A);
 
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: isDark ? Colors.white54 : const Color(0xFF6A7D85),
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: navy,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
