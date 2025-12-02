import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/repositories/azkar_repository.dart';
import '../../data/services/audio_player_service.dart';
import '../../data/services/playlist_service.dart';
import '../../domain/models/zikr.dart';
import '../../utils/theme.dart';
import '../../utils/localizations.dart';
import 'package:just_audio/just_audio.dart';
import 'floating_playlist_player.dart';

class CategoryAudioBottomSheet extends StatefulWidget {
  final String categoryKey;
  final String categoryName;

  const CategoryAudioBottomSheet({
    super.key,
    required this.categoryKey,
    required this.categoryName,
  });

  @override
  State<CategoryAudioBottomSheet> createState() =>
      _CategoryAudioBottomSheetState();
}

class _CategoryAudioBottomSheetState extends State<CategoryAudioBottomSheet>
    with TickerProviderStateMixin {
  final _azkarRepo = AzkarRepository();
  final _audioService = AudioPlayerService();
  final _playlistService = PlaylistService();
  
  List<Zikr> _azkar = [];
  bool _isLoading = true;
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
    super.dispose();
  }

  Future<void> _loadCategoryAzkar() async {
    try {
      final azkar = await _azkarRepo.getAzkarByCategory(widget.categoryKey);
      if (mounted) {
        setState(() {
          _azkar = azkar;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _playAll() async {
    if (_azkar.isEmpty) return;

    _playAllController.forward().then((_) {
      _playAllController.reverse();
    });

    if (_isPlayingAll && _playlistState == PlaylistState.playing) {
      await _playlistService.pause();
    } else if (_isPlayingAll && _playlistState == PlaylistState.paused) {
      await _playlistService.resume();
    } else {
      await _playlistService.loadPlaylist(_azkar);
      await _playlistService.play();
    }
  }

  Future<void> _playSingle(Zikr zikr) async {
    if (zikr.audio.isEmpty) return;

    try {
      final audioInfo = zikr.audio.first;
      final audioPath = audioInfo.shortFile ?? audioInfo.fullFileUrl;
      await _audioService.playAudio(audioPath, isLocal: true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioCount = _azkar.where((z) => z.audio.isNotEmpty).length;
    final totalPlaylistItems = _azkar
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
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
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
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                // Header
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Icon(
                          Icons.headphones,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.categoryName,
                              style: AppTheme.titleLarge.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$audioCount audios • $totalPlaylistItems items',
                              style: AppTheme.bodySmall.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Play All button
                if (!_isLoading && _azkar.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                    child: _buildPlayAllButton(totalPlaylistItems),
                  ),
                // Divider
                const Divider(height: 32, thickness: 1),
                // Audio list
                Flexible(
                  child: _isLoading
                      ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(32.0),
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : _azkar.isEmpty
                          ? Center(
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
                                      'No audios available',
                                      style: AppTheme.titleMedium.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : ListView.builder(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              shrinkWrap: true,
                              itemCount: _azkar.length,
                              itemBuilder: (context, index) {
                                final zikr = _azkar[index];
                                final isCurrentPlaying = _currentItem?.zikr.id == zikr.id &&
                                    _playlistState == PlaylistState.playing;

                                return TweenAnimationBuilder<double>(
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
                                  child: _buildAudioListItem(zikr, isCurrentPlaying),
                                );
                              },
                            ),
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
  }

  Widget _buildPlayAllButton(int totalItems) {
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
                        : 'Play All',
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
      ),
    );
  }

  Widget _buildAudioListItem(Zikr zikr, bool isCurrentPlaying) {
    if (zikr.audio.isEmpty) return const SizedBox.shrink();

    final audioInfo = zikr.audio.first;
    final audioPath = audioInfo.shortFile ?? audioInfo.fullFileUrl;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentPlaying
            ? AppTheme.primaryGreen.withOpacity(0.1)
            : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlaying
              ? AppTheme.primaryGreen.withOpacity(0.3)
              : Colors.grey.shade200,
          width: isCurrentPlaying ? 2 : 1,
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 8,
        ),
        leading: Container(
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
        title: Text(
          zikr.title.ar,
          style: AppTheme.arabicMedium.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isCurrentPlaying
                ? AppTheme.primaryGreen
                : AppTheme.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isCurrentPlaying
                    ? AppTheme.primaryGreen.withOpacity(0.2)
                    : Colors.grey.shade200,
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
        trailing: IconButton(
          icon: Icon(
            isCurrentPlaying ? Icons.pause_circle : Icons.play_circle_outline,
            color: isCurrentPlaying
                ? AppTheme.primaryGreen
                : AppTheme.textSecondary,
            size: 32,
          ),
          onPressed: () => _playSingle(zikr),
        ),
      ),
    );
  }
}

