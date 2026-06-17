import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/providers.dart';
import '../../../../main.dart';
import '../../../../shared/widgets/app_background.dart';
import '../../../../shared/widgets/arjuna_brand.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  UserMode _selectedMode = UserMode.buyer;

  final List<OnboardingData> _pages = [
    OnboardingData(
      image: 'assets/images/arjuna_onboard_monitor_v2.png',
      title: 'Pantau Harga Pangan Real-Time',
      subtitle:
          'Dapatkan informasi harga komoditas pangan pokok terkini langsung dari pasar-pasar di Indonesia secara akurat dan transparan.',
    ),
    OnboardingData(
      image: 'assets/images/arjuna_onboard_predict_v2.png',
      title: 'Prediksi Harga Berbasis AI',
      subtitle:
          'Gunakan teknologi peramalan model SARIMAX cerdas untuk melihat prediksi harga di masa depan guna meminimalisir kerugian keuangan.',
    ),
    OnboardingData(
      image: 'assets/images/arjuna_onboard_role_v2.png',
      title: 'Sesuaikan Perspektif Anda',
      subtitle:
          'Pilih peran Anda untuk menyesuaikan indikator warna harga agar sesuai dengan kebutuhan bisnis atau belanja harian Anda.',
    ),
  ];

  Future<void> _completeOnboarding() async {
    // Save user mode to settings provider
    ref.read(settingsProvider.notifier).setMode(_selectedMode);

    // Set first launch flag to false
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('is_first_launch', false);

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final accentColor = ArjunaColors.accent(isDark);
    final navyColor = ArjunaColors.navy;

    return AppBackground(
      showBlurShapes: true,
      showBatikPattern: true,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Column(
            children: [
              // Skip button at top
              Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: _currentPage < 2
                      ? TextButton(
                          onPressed: () {
                            _pageController.animateToPage(
                              2,
                              duration: const Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          },
                          child: Text(
                            'Lewati',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? ArjunaColors.gold : navyColor,
                            ),
                          ),
                        )
                      : const SizedBox(height: 48), // Match spacing
                ),
              ),

              // Page View for slides
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _currentPage = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final data = _pages[index];
                    final isLastPage = index == 2;

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // 3D Image
                          Expanded(
                            flex: 5,
                            child: LayoutBuilder(
                              builder: (context, constraints) {
                                final imageSide =
                                    constraints.maxHeight < constraints.maxWidth
                                    ? constraints.maxHeight
                                    : constraints.maxWidth;

                                return Center(
                                  child: SizedBox.square(
                                    dimension: imageSide,
                                    child: Container(
                                      margin: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(28),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: isDark ? 0.3 : 0.08,
                                            ),
                                            blurRadius: 24,
                                            offset: const Offset(0, 12),
                                          ),
                                        ],
                                      ),
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(28),
                                        child: Image.asset(
                                          data.image,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 32),

                          // Text Content
                          Expanded(
                            flex: 4,
                            child: Column(
                              children: [
                                Text(
                                  data.title,
                                  textAlign: TextAlign.center,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(
                                        fontWeight: FontWeight.w800,
                                        color: isDark
                                            ? Colors.white
                                            : navyColor,
                                        fontSize: 22,
                                        letterSpacing: -0.5,
                                      ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  data.subtitle,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: isDark
                                        ? Colors.white60
                                        : ArjunaColors.muted,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 24),

                                // Special Role Selector on the last page
                                if (isLastPage) ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _RoleCard(
                                          title: 'Pembeli',
                                          subtitle:
                                              'Konsumen / Ibu Rumah Tangga',
                                          icon: Icons.shopping_basket_rounded,
                                          isSelected:
                                              _selectedMode == UserMode.buyer,
                                          isDark: isDark,
                                          accentColor: accentColor,
                                          onTap: () {
                                            setState(() {
                                              _selectedMode = UserMode.buyer;
                                            });
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: _RoleCard(
                                          title: 'Penjual',
                                          subtitle:
                                              'Pedagang / Petani Komoditas',
                                          icon: Icons.storefront_rounded,
                                          isSelected:
                                              _selectedMode == UserMode.seller,
                                          isDark: isDark,
                                          accentColor: accentColor,
                                          onTap: () {
                                            setState(() {
                                              _selectedMode = UserMode.seller;
                                            });
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Actions (Indicator + CTA Button)
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Slide dots indicator
                    Row(
                      children: List.generate(
                        _pages.length,
                        (index) => AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          margin: const EdgeInsets.only(right: 6),
                          height: 8,
                          width: _currentPage == index ? 24 : 8,
                          decoration: BoxDecoration(
                            color: _currentPage == index
                                ? accentColor
                                : (isDark ? Colors.white24 : Colors.black12),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),

                    // Next / Start Button
                    ElevatedButton(
                      onPressed: () {
                        if (_currentPage < 2) {
                          _pageController.nextPage(
                            duration: const Duration(milliseconds: 500),
                            curve: Curves.easeInOut,
                          );
                        } else {
                          _completeOnboarding();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _currentPage == 2
                            ? accentColor
                            : navyColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 14,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentPage == 2 ? 'Mulai Sekarang' : 'Lanjut',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            _currentPage == 2
                                ? Icons.done_all_rounded
                                : Icons.arrow_forward_rounded,
                            size: 16,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class OnboardingData {
  final String image;
  final String title;
  final String subtitle;

  OnboardingData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class _RoleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool isSelected;
  final bool isDark;
  final Color accentColor;
  final VoidCallback onTap;

  const _RoleCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isSelected,
    required this.isDark,
    required this.accentColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected
              ? accentColor.withValues(alpha: isDark ? 0.16 : 0.08)
              : (isDark
                    ? Colors.white.withValues(alpha: 0.03)
                    : Colors.black.withValues(alpha: 0.02)),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? accentColor
                : (isDark
                      ? Colors.white.withValues(alpha: 0.08)
                      : Colors.black.withValues(alpha: 0.06)),
            width: isSelected ? 2.0 : 1.0,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? accentColor
                  : (isDark ? Colors.white38 : ArjunaColors.muted),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected
                    ? (isDark ? Colors.white : accentColor)
                    : (isDark ? Colors.white70 : ArjunaColors.navy),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white30 : Colors.black38,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
