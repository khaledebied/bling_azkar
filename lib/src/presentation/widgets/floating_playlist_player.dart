import 'package:flutter/material.dart';
import 'dart:async';
import '../../data/services/playlist_service.dart';
import '../../utils/theme.dart';

class FloatingPlaylistPlayer extends StatefulWidget {
  final PlaylistService playlistService;

  const FloatingPlaylistPlayer({
    super.key,
    required this.playlistService,
  });

  @override
  State<FloatingPlaylistPlayer> createState() => _FloatingPlaylistPlayerState();
}

class _FloatingPlaylistPlayerState extends State<FloatingPlaylistPlayer>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  StreamSubscription<PlaylistState>? _stateSubscription;
  StreamSubscription<PlaylistItem?>? _itemSubscription;
  StreamSubscription<PlaylistProgress>? _progressSubscription;

  PlaylistState _currentState = PlaylistState.idle;
  PlaylistItem? _currentItem;
  PlaylistProgress? _progress;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _stateSubscription = widget.playlistService.stateStream.listen((state) {
      if (mounted) {
        setState(() {
          _currentState = state;
        });
        if (state == PlaylistState.playing) {
          _pulseController.repeat(reverse: true);
        } else {
          _pulseController.stop();
          _pulseController.reset();
        }
      }
    });

    _itemSubscription = widget.playlistService.currentItemStream.listen((item) {
      if (mounted) {
        setState(() {
          _currentItem = item;
        });
      }
    });

    _progressSubscription = widget.playlistService.progressStream.listen((progress) {
      if (mounted) {
        setState(() {
          _progress = progress;
        });
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _stateSubscription?.cancel();
    _itemSubscription?.cancel();
    _progressSubscription?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (_currentState == PlaylistState.idle || _currentState == PlaylistState.completed) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryGreen,
            AppTheme.primaryTeal,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Progress bar
            if (_progress != null)
              Container(
                height: 3,
                child: LinearProgressIndicator(
                  value: _progress!.progress,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            // Player content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  // Play/Pause button with animation
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () async {
                          if (_currentState == PlaylistState.playing) {
                            await widget.playlistService.pause();
                          } else if (_currentState == PlaylistState.paused) {
                            await widget.playlistService.resume();
                          }
                        },
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.25),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            _currentState == PlaylistState.playing
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Track info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _currentItem?.zikr.title.ar ?? 'Playing...',
                          style: AppTheme.arabicMedium.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _currentItem != null && _currentItem!.totalRepetitions > 1
                                  ? 'Zikr ${(_currentItem!.index + 1)} (${_currentItem!.repetition}/${_currentItem!.totalRepetitions}) • ${widget.playlistService.currentIndex + 1}/${widget.playlistService.totalItems}'
                                  : '${widget.playlistService.currentIndex + 1} / ${widget.playlistService.totalItems}',
                              style: AppTheme.bodySmall.copyWith(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 12,
                              ),
                            ),
                            if (_progress != null) ...[
                              const SizedBox(width: 8),
                              Text(
                                '${_formatDuration(_progress!.currentPosition)} / ${_formatDuration(_progress!.totalDuration)}',
                                style: AppTheme.bodySmall.copyWith(
                                  color: Colors.white.withOpacity(0.8),
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  // Skip buttons
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await widget.playlistService.skipToPrevious();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.skip_previous,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await widget.playlistService.skipToNext();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.skip_next,
                              color: Colors.white,
                              size: 24,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            await widget.playlistService.stop();
                          },
                          borderRadius: BorderRadius.circular(20),
                          child: Container(
                            padding: const EdgeInsets.all(8),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 20,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

