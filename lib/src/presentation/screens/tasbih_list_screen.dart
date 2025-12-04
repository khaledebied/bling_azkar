import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import '../../domain/models/tasbih_type.dart';
import '../providers/tasbih_providers.dart';
import 'tasbih_detail_screen.dart';

/// Main listing screen showing all 10 Tasbih types in a grid
class TasbihListScreen extends ConsumerWidget {
  const TasbihListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tasbihTypes = ref.watch(tasbihTypesProvider);
    final sharedPrefsAsync = ref.watch(sharedPreferencesProvider);
    
    // Wait for SharedPreferences to initialize
    return sharedPrefsAsync.when(
      loading: () => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
      error: (error, stack) => Scaffold(
        body: Center(
          child: Text('Error initializing: $error'),
        ),
      ),
      data: (_) => _buildContent(context, ref, tasbihTypes),
    );
  }
  
  Widget _buildContent(BuildContext context, WidgetRef ref, List<TasbihType> tasbihTypes) {
    final l10n = AppLocalizations.ofWithFallback(context);
    final isArabic = l10n.isArabic;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    
    return Directionality(
      textDirection: isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          title: Text(
            isArabic ? 'التسبيح الإلكتروني' : 'Electronic Tasbih',
            style: AppTheme.titleMedium.copyWith(
              color: Colors.black54,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: isDarkMode
                    ? [
                        Colors.black.withValues(alpha: 0.4),
                        Colors.transparent,
                      ]
                    : [
                        AppTheme.primaryGreen.withValues(alpha: 0.3),
                        Colors.transparent,
                      ],
              ),
            ),
          ),
        ),
        body: Container(
          decoration: BoxDecoration(
            color: isDarkMode
                ? const Color(0xFF0F1419)
                : const Color(0xFFF5F5F5),
          ),
          child: SafeArea(
            top: true,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 30, 16, 16),
              itemCount: tasbihTypes.length,
              itemBuilder: (context, index) {
                final type = tasbihTypes[index];
                return TasbihTypeCard(
                  type: type,
                  index: index,
                  isArabic: isArabic,
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Card widget for each Dhikr type
class TasbihTypeCard extends ConsumerStatefulWidget {
  final TasbihType type;
  final int index;
  final bool isArabic;

  const TasbihTypeCard({
    super.key,
    required this.type,
    required this.index,
    required this.isArabic,
  });

  @override
  ConsumerState<TasbihTypeCard> createState() => _TasbihTypeCardState();
}

class _TasbihTypeCardState extends ConsumerState<TasbihTypeCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTap() {
    // Save last selected type
    ref.read(tasbihRepositoryProvider).saveLastSelectedType(widget.type.id);
    
    // Navigate to detail screen with Hero animation
    Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            TasbihDetailScreen(tasbihType: widget.type),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(
            opacity: animation,
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(
                  parent: animation,
                  curve: Curves.easeOutCubic,
                ),
              ),
              child: child,
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(tasbihCounterProvider(widget.type));
    
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 200 + (widget.index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: GestureDetector(
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) {
          _controller.reverse();
          _onTap();
        },
        onTapCancel: () => _controller.reverse(),
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Hero(
            tag: 'tasbih_${widget.type.id}',
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: context.cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: widget.type.color.withValues(alpha: 0.15),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Row(
                      children: [
                        // Icon - Simple and clean
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: widget.type.color.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            widget.type.icon,
                            color: widget.type.color,
                            size: 28,
                          ),
                        ),
                        
                        const SizedBox(width: 16),
                        
                        // Text content
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Dhikr text (large)
                              Text(
                                widget.type.dhikrText,
                                style: AppTheme.dhikrText.copyWith(
                                  color: context.textPrimary,
                                  fontSize: 22,
                                  height: 1.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              const SizedBox(height: 6),
                              
                              // Meaning
                              Text(
                                widget.isArabic ? widget.type.meaningAr : widget.type.meaningEn,
                                style: AppTheme.bodySmall.copyWith(
                                  color: context.textSecondary,
                                  fontSize: 12,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              
                              const SizedBox(height: 8),
                              
                              // Target and progress row
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: widget.type.color.withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      '${widget.type.defaultTarget}×',
                                      style: AppTheme.caption.copyWith(
                                        color: widget.type.color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (session.currentCount > 0)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: session.isCompleted
                                            ? Colors.green.withValues(alpha: 0.1)
                                            : Colors.orange.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(
                                            session.isCompleted
                                                ? Icons.check_circle
                                                : Icons.timelapse,
                                            color: session.isCompleted
                                                ? Colors.green
                                                : Colors.orange,
                                            size: 12,
                                          ),
                                          const SizedBox(width: 4),
                                          Text(
                                            session.isCompleted
                                                ? (widget.isArabic ? 'مكتمل' : 'Done')
                                                : '${session.currentCount}/${session.targetCount}',
                                            style: AppTheme.caption.copyWith(
                                              color: session.isCompleted
                                                  ? Colors.green
                                                  : Colors.orange,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        
                        // Arrow
                        Icon(
                          widget.isArabic
                              ? Icons.arrow_back_ios_rounded
                              : Icons.arrow_forward_ios_rounded,
                          color: widget.type.color,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
            ),
          ),
        ),
      ),
    );
  }
}

