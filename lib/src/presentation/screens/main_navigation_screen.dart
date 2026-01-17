import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import 'home_screen.dart';
import 'tasbih_list_screen.dart';
import 'favorites_screen.dart';
import 'quran_screen.dart';
import '../providers/ui_providers.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  late List<Widget> _screens;
  late List<AnimationController> _animationControllers;
  late List<Animation<double>> _fadeAnimations;

  @override
  void initState() {
    super.initState();
    
    _screens = [
    const HomeScreen(),
    const TasbihListScreen(),
    const FavoritesScreen(),
    const QuranScreen(),
  ];

    // Create animation controllers for each tab
    _animationControllers = List.generate(
      4,
      (index) => AnimationController(
        duration: const Duration(milliseconds: 300),
        vsync: this,
      ),
    );

    _fadeAnimations = _animationControllers
        .map((controller) => Tween<double>(begin: 0.0, end: 1.0).animate(
              CurvedAnimation(parent: controller, curve: Curves.easeIn),
            ))
        .toList();

    // Start animation for first tab
    _animationControllers[0].forward();
  }

  @override
  void dispose() {
    for (var controller in _animationControllers) {
      controller.dispose();
    }
    super.dispose();
  }



  void _onTabTapped(int index) {
    if (_currentIndex == index) return;

    // Update provider
    ref.read(currentTabProvider.notifier).state = index;
    ref.read(showBottomNavProvider.notifier).state = true;

    // If tapping Quran tab, check if we need to mark showcase as seen (if it wasn't shown automatically)
    if (index == 3) {
      // Logic to show Quran specific showcase is handled in QuranScreen via provider listener
    }

    setState(() {
      // Fade out current tab
      _animationControllers[_currentIndex].reverse();
      _currentIndex = index;
      // Fade in new tab
      _animationControllers[_currentIndex].forward();
    });
  }

  @override
  Widget build(BuildContext context) {
    return _buildScaffold(context);
  }

  Widget _buildScaffold(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;

    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: ScaffoldMessenger(
        child: Builder(
          builder: (context) => Scaffold(
            body: IndexedStack(
              index: _currentIndex,
              children: _screens.asMap().entries.map((entry) {
                return FadeTransition(
                  opacity: _fadeAnimations[entry.key],
                  child: entry.value,
                );
              }).toList(),
            ),
            bottomNavigationBar: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1.0,
                  child: child,
                );
              },
              child: ref.watch(showBottomNavProvider)
                  ? _buildBottomNavigationBar(context)
                  : const SizedBox.shrink(key: ValueKey('hide_nav')),
            ),
            // Ensure SnackBar has proper margins
            resizeToAvoidBottomInset: false,
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Container(
      key: const ValueKey('bottom_nav_bar'),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: isDarkMode
            ? Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              )
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDarkMode ? 0.3 : 0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.auto_awesome_rounded,
                label: l10n.azkar,
                index: 0,
              ),
              _buildNavItem(
                icon: Icons.touch_app_rounded,
                label: l10n.tasbih,
                index: 1,
              ),
              _buildNavItem(
                icon: Icons.favorite_rounded,
                label: l10n.favorites,
                index: 2,
              ),
              _buildNavItem(
                icon: Icons.menu_book_rounded,
                label: l10n.quranKareem,
                index: 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: GestureDetector(
      onTap: () => _onTabTapped(index),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(vertical: 6),
        decoration: BoxDecoration(
          gradient: isSelected ? AppTheme.primaryGradient : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                size: 22,
              ),
            ),
            const SizedBox(height: 2),
            Flexible(
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: AppTheme.caption.copyWith(
                  color: isSelected ? Colors.white : Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.6),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  fontSize: isSelected ? 11 : 10,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    )
    );
  }
}

