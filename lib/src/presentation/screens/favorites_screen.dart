import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';
import '../../utils/theme.dart';
import '../../utils/localizations.dart';
import '../../domain/models/zikr.dart';
import '../../data/services/playlist_service.dart';
import '../providers/azkar_providers.dart';
import '../widgets/zikr_list_item.dart';
import '../widgets/floating_playlist_player.dart';
import 'zikr_detail_screen.dart';
import 'player_screen.dart';

class FavoritesScreen extends ConsumerStatefulWidget {
  const FavoritesScreen({super.key});

  @override
  ConsumerState<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends ConsumerState<FavoritesScreen> {
  final _playlistService = PlaylistService();
  bool _isPlayingAll = false;
  PlaylistState _playlistState = PlaylistState.idle;

  @override
  void initState() {
    super.initState();
    _playlistService.initialize();
    
    _playlistService.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _playlistState = state;
          _isPlayingAll = state == PlaylistState.playing || state == PlaylistState.paused;
        });
      }
    });
  }

  Future<void> _playAllFavorites(List<Zikr> favorites) async {
    if (favorites.isEmpty) return;

    if (_isPlayingAll && _playlistState == PlaylistState.playing) {
      await _playlistService.pause();
    } else if (_isPlayingAll && _playlistState == PlaylistState.paused) {
      await _playlistService.resume();
    } else {
      await _playlistService.loadPlaylist(favorites);
      await _playlistService.play();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.ofWithFallback(context);
    // Always watch the provider to ensure updates
    final favoritesAsync = ref.watch(favoriteAzkarProvider);

    return Scaffold(
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              _buildAppBar(l10n),
              favoritesAsync.when(
                loading: () => _buildShimmerLoading(),
                error: (error, stack) => _buildError(error),
                data: (favorites) => _buildFavoritesList(favorites),
              ),
            ],
          ),
          // Floating playlist player
          StreamBuilder<PlaylistState>(
            stream: _playlistService.stateStream,
            initialData: PlaylistState.idle,
            builder: (context, snapshot) {
              final state = snapshot.data ?? PlaylistState.idle;
              final isVisible = state == PlaylistState.playing || state == PlaylistState.paused;
              
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
      ),
    );
  }

  Widget _buildAppBar(AppLocalizations l10n) {
    return SliverAppBar(
      floating: true,
      snap: true,
      elevation: 0,
      backgroundColor: Colors.transparent,
      expandedHeight: 200,
      collapsedHeight: 70,
      flexibleSpace: LayoutBuilder(
        builder: (context, constraints) {
          return FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
              ),
              child: SafeArea(
                bottom: false,
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: const Icon(
                              Icons.favorite,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'My Favorites',
                                  style: AppTheme.titleLarge.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 28,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Your saved azkar',
                                  style: AppTheme.bodyMedium.copyWith(
                                    color: Colors.white.withOpacity(0.9),
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
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFavoritesList(List<Zikr> favorites) {
    if (favorites.isEmpty) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.primaryGreen.withOpacity(0.1),
                      AppTheme.primaryTeal.withOpacity(0.1),
                    ],
                  ),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.favorite_border,
                  size: 80,
                  color: AppTheme.primaryGreen,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'No favorites yet',
                style: AppTheme.titleLarge.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48.0),
                child: Text(
                  'Tap the heart icon on any zikr to add it to your favorites',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SliverToBoxAdapter(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats and Play All button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        AppTheme.primaryGreen.withOpacity(0.1),
                        AppTheme.primaryTeal.withOpacity(0.1),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: AppTheme.primaryGreen.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.favorite, color: AppTheme.primaryGreen, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${favorites.length} favorite${favorites.length > 1 ? 's' : ''}',
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryGreen,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${favorites.fold<int>(0, (sum, z) => sum + z.defaultCount)} total items',
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _buildPlayAllButton(favorites),
              ],
            ),
          ),
          // Favorites list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final zikr = favorites[index];
              
              return RepaintBoundary(
                child: ZikrListItem(
                  zikr: zikr,
                  isFavorite: true,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PlayerScreen(zikr: zikr),
                      ),
                    );
                  },
                  onFavoriteToggle: () async {
                    try {
                      final toggleFavorite = ref.read(toggleFavoriteProvider);
                      await toggleFavorite(zikr.id);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e')),
                        );
                      }
                    }
                  },
                ),
              );
            },
          ),
          const SizedBox(height: 100), // Space for floating player
        ],
      ),
    );
  }

  Widget _buildPlayAllButton(List<Zikr> favorites) {
    final totalItems = favorites.fold<int>(0, (sum, z) => sum + z.defaultCount);
    
    return Container(
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
          onTap: () => _playAllFavorites(favorites),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25),
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
                          ? 'Pause All'
                          : 'Resume All')
                      : 'Play All Favorites',
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
                    color: Colors.white.withOpacity(0.25),
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
    );
  }

  Widget _buildShimmerLoading() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Column(
            children: List.generate(
              5,
              (index) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                height: 100,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildError(Object error) {
    return SliverFillRemaining(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.primaryGreen,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading favorites',
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTheme.caption.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

