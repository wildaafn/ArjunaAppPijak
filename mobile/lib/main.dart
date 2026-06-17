import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:komoditas_ai/core/providers.dart';
import 'core/theme.dart';
import 'features/dashboard/presentation/screens/dashboard_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'features/settings/presentation/screens/settings_screen.dart';
import 'features/insight/presentation/screens/insight_screen.dart';
import 'features/splash/presentation/screens/splash_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'shared/widgets/app_background.dart';

class AppConfig {
  /// Toggle to true to enable console/network logging.
  /// Set to false to prevent lags in the simulator caused by heavy terminal output.
  static const bool enableLogging = true;
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('commodity_cache');
  await initializeDateFormatting('id_ID', null);
  final prefs = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      child: const KomoditasAIApp(),
    ),
  );
}

class KomoditasAIApp extends ConsumerWidget {
  const KomoditasAIApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp(
      title: 'Arjuna',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final navBottomInset = bottomPadding > 0
        ? (bottomPadding - 18).clamp(8.0, 18.0)
        : 10.0;

    final List<Widget> screens = [
      // Tab 0: Dashboard
      const DashboardScreen(),
      // Tab 1: Komoditas list
      const HomeScreen(),
      // Tab 2: Insight
      const InsightScreen(),
      // Tab 3: Pengaturan
      const SettingsScreen(),
    ];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        extendBody: true,
        body: IndexedStack(index: _selectedIndex, children: screens),
        bottomNavigationBar: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            padding: MediaQuery.of(context).padding.copyWith(bottom: 0),
            viewPadding: MediaQuery.of(context).viewPadding.copyWith(bottom: 0),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, navBottomInset),
            child: Container(
              height: 66,
              decoration: BoxDecoration(
                color: isDark
                    ? const Color(0xFF061D2D).withValues(alpha: 0.96)
                    : Colors.white.withValues(alpha: 0.96),
                borderRadius: BorderRadius.circular(22),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFFE8C766).withValues(alpha: 0.14)
                      : const Color(0xFF07345A).withValues(alpha: 0.08),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: isDark ? 0.24 : 0.10),
                    blurRadius: 22,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                children: [
                  _NavItem(
                    label: 'Beranda',
                    icon: Icons.dashboard_outlined,
                    selectedIcon: Icons.dashboard_rounded,
                    selected: _selectedIndex == 0,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 0),
                  ),
                  _NavItem(
                    label: 'Komoditas',
                    icon: Icons.storefront_outlined,
                    selectedIcon: Icons.storefront_rounded,
                    selected: _selectedIndex == 1,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 1),
                  ),
                  _NavItem(
                    label: 'Insight',
                    icon: Icons.auto_awesome_mosaic_outlined,
                    selectedIcon: Icons.auto_awesome_mosaic,
                    selected: _selectedIndex == 2,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 2),
                  ),
                  _NavItem(
                    label: 'Pengaturan',
                    icon: Icons.settings_outlined,
                    selectedIcon: Icons.settings_rounded,
                    selected: _selectedIndex == 3,
                    isDark: isDark,
                    onTap: () => setState(() => _selectedIndex = 3),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  final bool selected;
  final bool isDark;
  final VoidCallback onTap;

  const _NavItem({
    required this.label,
    required this.icon,
    required this.selectedIcon,
    required this.selected,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final activeColor = isDark
        ? const Color(0xFFE8C766)
        : const Color(0xFF0B9F91);
    final inactiveColor = isDark ? Colors.white54 : const Color(0xFF66747C);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: SizedBox(
          height: 66,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOutCubic,
                width: selected ? 48 : 40,
                height: 30,
                decoration: BoxDecoration(
                  color: selected
                      ? activeColor.withValues(alpha: isDark ? 0.16 : 0.14)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  selected ? selectedIcon : icon,
                  size: 23,
                  color: selected ? activeColor : inactiveColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: selected ? activeColor : inactiveColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
