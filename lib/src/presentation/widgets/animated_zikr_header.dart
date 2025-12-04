import 'dart:async';
import 'package:flutter/material.dart';
import '../../utils/theme.dart';

class AnimatedZikrHeader extends StatefulWidget {
  final bool isDarkMode;

  const AnimatedZikrHeader({
    super.key,
    required this.isDarkMode,
  });

  @override
  State<AnimatedZikrHeader> createState() => _AnimatedZikrHeaderState();
}

class _AnimatedZikrHeaderState extends State<AnimatedZikrHeader>
    with SingleTickerProviderStateMixin {
  final List<String> zikrList = [
    "🤲 سُبْحَانَ اللّٰه",
    "🙏 الْـحَمْدُ لِلّٰه",
    "🔥 اللّٰهُ أَكْبَر",
    "☝️ لَا إِلَهَ إِلَّا اللّٰه",
    "💜 أَسْتَغْفِرُ اللّٰه",
    "🌙 اللّٰهُمَّ صَلِّ عَلَى مُحَمَّد",
    "✨ سُبْحَانَ اللّٰهِ وَبِحَمْدِهِ",
    "🏔️ سُبْحَانَ اللّٰهِ الْعَظِيم",
    "💚 حَسْبِيَ اللّٰهُ لَا إِلَهَ إِلَّا هُو",
    "🌸 لَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللّٰه",
  ];

  int _currentIndex = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startAnimation();
  }

  void _startAnimation() {
    // Change zikr every 3 seconds
    _timer = Timer.periodic(const Duration(seconds: 3), (timer) {
      if (mounted) {
        setState(() {
          _currentIndex = (_currentIndex + 1) % zikrList.length;
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      transitionBuilder: (Widget child, Animation<double> animation) {
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.0, 0.3),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            )),
            child: child,
          ),
        );
      },
      child: Text(
        zikrList[_currentIndex],
        key: ValueKey<String>(zikrList[_currentIndex]),
        style: AppTheme.arabicMedium.copyWith(
          fontSize: 18,
          color: widget.isDarkMode
              ? Colors.white.withValues(alpha: 0.95)
              : Colors.black87,
          fontWeight: FontWeight.w600,
          height: 1.4,
        ),
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}

