import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/azkar_repository.dart';
import '../../data/services/audio_player_service.dart';
import '../../data/services/playlist_service.dart';
import '../../data/services/storage_service.dart';
import '../../domain/models/zikr.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../utils/localizations.dart';
import 'floating_playlist_player.dart';
import '../screens/player_screen.dart';
import '../screens/zikr_reading_screen.dart';
import '../providers/azkar_providers.dart';

class CategoryAudioBottomSheet extends ConsumerStatefulWidget {
  final String categoryKey;
  final String categoryName;

  const CategoryAudioBottomSheet({
    super.key,
    required this.categoryKey,
    required this.categoryName,
  });

  @override
  ConsumerState<CategoryAudioBottomSheet> createState() =>
      _CategoryAudioBottomSheetState();
}

class _CategoryAudioBottomSheetState extends ConsumerState<CategoryAudioBottomSheet>
    with TickerProviderStateMixin {
  final _azkarRepo = AzkarRepository();
  final _audioService = AudioPlayerService();
  final _playlistService = PlaylistService();
  final _storage = StorageService();
  
  final _azkarNotifier = ValueNotifier<List<Zikr>>([]);
  final _isLoadingNotifier = ValueNotifier<bool>(true);
  
  bool _isPlayingAll = false;
  PlaylistState _playlistState = PlaylistState.idle;
  PlaylistItem? _currentItem;
  
  late AnimationController _sheetController;
  late AnimationController _playAllController;
  late Animation<double> _playAllScaleAnimation;
  StreamSubscription<PlaylistState>? _playlistStateSubscription;
  StreamSubscription<PlaylistItem?>? _playlistItemSubscription;

  @override
  void initState() {
    super.initState();
    _sheetController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _playAllController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _playAllScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _playAllController, curve: Curves.easeInOut),
    );

    _loadCategoryAzkar();
    _playlistService.initialize();
    
    _playlistStateSubscription = _playlistService.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _playlistState = state;
          _isPlayingAll = state == PlaylistState.playing || state == PlaylistState.paused;
        });
      }
    });

    _playlistItemSubscription = _playlistService.currentItemStream.listen((item) {
      if (mounted) {
        setState(() {
          _currentItem = item;
        });
      }
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    _playAllController.dispose();
    _playlistStateSubscription?.cancel();
    _playlistItemSubscription?.cancel();
    _azkarNotifier.dispose();
    _isLoadingNotifier.dispose();
    super.dispose();
  }

  Future<void> _loadCategoryAzkar() async {
    try {
      final azkar = await _azkarRepo.getAzkarByCategory(widget.categoryKey);
      _azkarNotifier.value = azkar;
      _isLoadingNotifier.value = false;
    } catch (e) {
      _isLoadingNotifier.value = false;
    }
  }

  Future<void> _playAll() async {
    final azkar = _azkarNotifier.value;
    if (azkar.isEmpty) return;

    _playAllController.forward().then((_) {
      _playAllController.reverse();
    });

    if (_isPlayingAll && _playlistState == PlaylistState.playing) {
      await _playlistService.pause();
    } else if (_isPlayingAll && _playlistState == PlaylistState.paused) {
      await _playlistService.resume();
    } else {
      await _playlistService.loadPlaylist(azkar);
      await _playlistService.play();
    }
  }

  Future<void> _openPlayerScreen(Zikr zikr) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PlayerScreen(zikr: zikr),
      ),
    );
  }

  Future<void> _toggleFavorite(String zikrId) async {
    try {
      // Use the provider to toggle favorite
      final toggleFavorite = ref.read(toggleFavoriteProvider);
      await toggleFavorite(zikrId);
      
      // Trigger rebuild locally
      setState(() {});
      
      // Visual feedback without SnackBar (just the heart animation is enough)
    } catch (e) {
      // Silent error handling - the heart icon won't change if there's an error
      debugPrint('Error updating favorite: ${e.toString()}');
    }
  }

  bool _isFavorite(String zikrId) {
    final prefs = _storage.getPreferences();
    return prefs.favoriteZikrIds.contains(zikrId);
  }


  @override
  Widget build(BuildContext context) {
    final isDarkMode = context.isDarkMode;
    
    return ValueListenableBuilder<List<Zikr>>(
      valueListenable: _azkarNotifier,
      builder: (context, azkar, _) {
        return ValueListenableBuilder<bool>(
          valueListenable: _isLoadingNotifier,
          builder: (context, isLoading, _) {
            final l10n = AppLocalizations.ofWithFallback(context);
            final audioCount = azkar.where((z) => z.audio.isNotEmpty).length;
            final totalPlaylistItems = azkar
                .where((z) => z.audio.isNotEmpty)
                .fold<int>(0, (sum, z) => sum + z.defaultCount);

            return Stack(
              children: [
                AnimatedPadding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                  ),
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut,
                  child: Container(
                    constraints: BoxConstraints(
                      maxHeight: MediaQuery.of(context).size.height * 0.9,
                    ),
                    decoration: BoxDecoration(
                      color: context.cardColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(28),
                        topRight: Radius.circular(28),
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Handle bar
                        Center(
                          child: Container(
                            margin: const EdgeInsets.only(top: 12, bottom: 8),
                            width: 40,
                            height: 4,
                            decoration: BoxDecoration(
                              color: isDarkMode 
                                  ? Colors.grey.shade600
                                  : Colors.grey.shade300,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ),
                        // Stats and Play All button (matching favorites tab style)
                        if (!isLoading && azkar.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Category title
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Text(
                                    widget.categoryName,
                                    style: AppTheme.titleLarge.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: context.textPrimary,
                                    ),
                                  ),
                                ),
                                // Stats container
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppTheme.primaryGreen.withValues(alpha: 0.15),
                                        AppTheme.primaryTeal.withValues(alpha: 0.15),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: AppTheme.primaryGreen.withValues(alpha: 0.4),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.headphones, color: AppTheme.primaryGreen, size: 20),
                                      const SizedBox(width: 8),
                                      Text(
                                        '$audioCount ${audioCount > 1 ? l10n.audios : l10n.audio}',
                                        style: AppTheme.bodyMedium.copyWith(
                                          color: AppTheme.primaryGreen,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      const Spacer(),
                                      Text(
                                        '$totalPlaylistItems ${l10n.totalItems}',
                                        style: AppTheme.bodySmall.copyWith(
                                          color: context.textSecondary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Play All and Read All buttons
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildPlayAllButton(totalPlaylistItems),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildReadAllButton(azkar),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        // Audio list
                        Flexible(
                          child: _buildAzkarList(azkar, isLoading),
                        ),
                        SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
                      ],
                    ),
                  ),
                ),
                // Floating player when playing all
                StreamBuilder<bool>(
                  stream: _playlistService.stateStream.map((state) => 
                      state == PlaylistState.playing || state == PlaylistState.paused),
                  initialData: false,
                  builder: (context, snapshot) {
                    final isVisible = snapshot.data ?? false;
                    return AnimatedPositioned(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOutCubic,
                      bottom: isVisible ? 0 : -100,
                      left: 0,
                      right: 0,
                      child: AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: isVisible ? 1.0 : 0.0,
                        child: FloatingPlaylistPlayer(
                          playlistService: _playlistService,
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildAzkarList(List<Zikr> azkar, bool isLoading) {
    final l10n = AppLocalizations.ofWithFallback(context);
    if (isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32.0),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (azkar.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.audiotrack_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.noAudiosAvailable,
                style: AppTheme.titleMedium.copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      shrinkWrap: true,
      itemCount: azkar.length,
      itemBuilder: (context, index) {
        final zikr = azkar[index];
        final isCurrentPlaying = _currentItem?.zikr.id == zikr.id &&
            _playlistState == PlaylistState.playing;
        final isFavorite = _isFavorite(zikr.id);

        return RepaintBoundary(
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 200 + (index * 30)),
            curve: Curves.easeOut,
            builder: (context, value, child) {
              return Opacity(
                opacity: value,
                child: Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: child,
                ),
              );
            },
            child: _buildAudioListItem(zikr, isCurrentPlaying, isFavorite),
          ),
        );
      },
    );
  }

  Widget _buildPlayAllButton(int totalItems) {
    final l10n = AppLocalizations.ofWithFallback(context);
    return ScaleTransition(
      scale: _playAllScaleAnimation,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isPlayingAll
                ? [AppTheme.primaryTeal, AppTheme.primaryGreen]
                : [AppTheme.primaryGreen, AppTheme.primaryTeal],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: (_isPlayingAll ? AppTheme.primaryTeal : AppTheme.primaryGreen)
                  .withOpacity(0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _playAll,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      _isPlayingAll && _playlistState == PlaylistState.playing
                          ? Icons.pause
                          : Icons.play_arrow,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    _isPlayingAll
                        ? (_playlistState == PlaylistState.playing
                            ? l10n.pauseAll
                            : l10n.resumeAll)
                        : l10n.playAll,
                    style: AppTheme.titleMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$totalItems',
                      style: AppTheme.bodySmall.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildReadAllButton(List<Zikr> azkar) {
    final l10n = AppLocalizations.ofWithFallback(context);
    
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryTeal,
            AppTheme.primaryGreen,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryTeal.withOpacity(0.4),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ZikrReadingScreen(
                  azkar: azkar,
                  categoryName: widget.categoryName,
                ),
              ),
            );
          },
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.menu_book,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.readAll,
                  style: AppTheme.titleMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAudioListItem(Zikr zikr, bool isCurrentPlaying, bool isFavorite) {
    if (zikr.audio.isEmpty) return const SizedBox.shrink();
    
    final isDarkMode = context.isDarkMode;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentPlaying
            ? AppTheme.primaryGreen.withValues(alpha: isDarkMode ? 0.2 : 0.1)
            : (isDarkMode 
                ? const Color(0xFF2A2A2A)
                : Colors.grey.shade50),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlaying
              ? AppTheme.primaryGreen.withValues(alpha: isDarkMode ? 0.5 : 0.3)
              : (isDarkMode
                  ? Colors.white.withValues(alpha: 0.1)
                  : Colors.grey.shade200),
          width: isCurrentPlaying ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openPlayerScreen(zikr),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Leading icon
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: isCurrentPlaying
                        ? AppTheme.primaryGradient
                        : LinearGradient(
                            colors: [Colors.grey.shade300, Colors.grey.shade400],
                          ),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isCurrentPlaying ? Icons.volume_up : Icons.audiotrack,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                // Title and subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        zikr.title.ar,
                        style: AppTheme.arabicMedium.copyWith(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isCurrentPlaying
                              ? AppTheme.primaryGreen
                              : context.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        zikr.text,
                        style: AppTheme.arabicSmall.copyWith(
                          fontSize: 12,
                          color: context.textSecondary,
                          height: 1.5,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isCurrentPlaying
                                  ? AppTheme.primaryGreen.withValues(alpha: 0.2)
                                  : (isDarkMode
                                      ? Colors.grey.shade700
                                      : Colors.grey.shade200),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              '${zikr.defaultCount}x',
                              style: AppTheme.caption.copyWith(
                                color: isCurrentPlaying
                                    ? AppTheme.primaryGreen
                                    : AppTheme.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (isCurrentPlaying && _currentItem != null) ...[
                            const SizedBox(width: 8),
                            Text(
                              '(${_currentItem!.repetition}/${_currentItem!.totalRepetitions})',
                              style: AppTheme.caption.copyWith(
                                color: AppTheme.primaryGreen,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // Favorite button
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite 
                        ? (isDarkMode ? Colors.red.shade400 : Colors.red)
                        : context.textSecondary,
                    size: 24,
                  ),
                  onPressed: () => _toggleFavorite(zikr.id),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
