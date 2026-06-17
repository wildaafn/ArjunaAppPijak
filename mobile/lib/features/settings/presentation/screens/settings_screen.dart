import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/widgets/arjuna_brand.dart';
import '../../../../shared/widgets/error_state.dart';
import '../../../../shared/widgets/shimmer_placeholder.dart';
import '../../../../core/providers.dart';
import '../widgets/setting_section_title.dart';
import '../widgets/personalization_section.dart';
import '../widgets/about_app_section.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final metadataAsync = ref.watch(metadataProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          'Pengaturan',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : ArjunaColors.navy,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: const ArjunaAppBarBackground(),
      ),
      body: metadataAsync.when(
        data: (metadata) {
          return Container(
            width: double.infinity,
            height: double.infinity,
            margin: const EdgeInsets.only(top: 10),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF061525).withValues(alpha: 0.96)
                  : Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
              border: Border(
                top: BorderSide(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.black.withValues(alpha: 0.04),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: isDark ? 0.18 : 0.035),
                  blurRadius: 18,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 112),
              children: [
                const SettingSectionTitle(title: 'Personalisasi'),
                const SizedBox(height: 12),
                const PersonalizationSection(),
                const SizedBox(height: 32),
                const SettingSectionTitle(title: 'Tentang Aplikasi'),
                const SizedBox(height: 12),
                AboutAppSection(metadata: metadata),
              ],
            ),
          );
        },
        loading: () => Container(
          width: double.infinity,
          height: double.infinity,
          margin: const EdgeInsets.only(top: 12),
          decoration: BoxDecoration(
            color: isDark
                ? const Color(0xFF061525).withValues(alpha: 0.96)
                : Colors.white,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(24),
              topRight: Radius.circular(24),
            ),
            border: Border(
              top: BorderSide(
                color: isDark
                    ? Colors.white.withValues(alpha: 0.05)
                    : Colors.black.withValues(alpha: 0.04),
                width: 1,
              ),
            ),
          ),
          child: const SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 112),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SettingSectionTitle(title: 'Personalisasi'),
                SizedBox(height: 12),
                PersonalizationSection(),
                SizedBox(height: 32),
                SettingSectionTitle(title: 'Tentang Aplikasi'),
                SizedBox(height: 12),
                SettingsAboutShimmer(),
              ],
            ),
          ),
        ),
        error: (error, stack) => AppErrorWidget(
          title: 'Gagal Memuat Data',
          message: error.toString(),
          onRetry: () => ref.refresh(metadataProvider),
        ),
      ),
    );
  }
}
