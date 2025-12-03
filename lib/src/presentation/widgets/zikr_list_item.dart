import 'package:flutter/material.dart';
import 'dart:async';
import '../../domain/models/zikr.dart';
import '../../utils/theme.dart';
import '../../data/services/audio_player_service.dart';
import 'package:just_audio/just_audio.dart';

class ZikrListItem extends StatefulWidget {
  final Zikr zikr;
  final bool isFavorite;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const ZikrListItem({
    super.key,
    required this.zikr,
    required this.isFavorite,
    required this.onTap,
    required this.onFavoriteToggle,
  });

  @override
  State<ZikrListItem> createState() => _ZikrListItemState();
}

class _ZikrListItemState extends State<ZikrListItem>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late AnimationController _playController;
  late AnimationController _pulseController;
  late Animation<double> _playScaleAnimation;
  late Animation<double> _pulseAnimation;
  
  final _audioService = AudioPlayerService();
  StreamSubscription<PlayerState>? _playerStateSubscription;
  bool _isPlaying = false;
  bool _isCurrentAudio = false;
  String? _currentAudioPath;
  
  // Static variable to track which audio is currently playing
  static String? _currentlyPlayingPath;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _playController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _playScaleAnimation = Tween<double>(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _playController, curve: Curves.easeInOut),
    );

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

    // Get current audio path for this zikr
    if (widget.zikr.audio.isNotEmpty) {
      final audioInfo = widget.zikr.audio.first;
      _currentAudioPath = audioInfo.shortFile ?? audioInfo.fullFileUrl;
    }

    // Listen to audio player state
    _playerStateSubscription = _audioService.playerStateStream.listen((state) {
      if (mounted && _currentAudioPath != null) {
        final wasPlaying = _isPlaying;
        final wasCurrent = _isCurrentAudio;
        _isPlaying = state.playing;
        
        // Reset playing path if audio stopped or completed
        if (state.processingState == ProcessingState.completed || 
            (!_isPlaying && _currentlyPlayingPath == _currentAudioPath)) {
          _currentlyPlayingPath = null;
        }
        
        // Check if this is the current audio being played
        _isCurrentAudio = _isPlaying && _currentlyPlayingPath == _currentAudioPath;
        
        if (_isCurrentAudio && !wasCurrent) {
          _pulseController.repeat(reverse: true);
        } else if (!_isCurrentAudio && wasCurrent) {
          _pulseController.stop();
          _pulseController.reset();
        }
        
        if (wasPlaying != _isPlaying || wasCurrent != _isCurrentAudio) {
          setState(() {});
        }
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _playController.dispose();
    _pulseController.dispose();
    _playerStateSubscription?.cancel();
    super.dispose();
  }

  Future<void> _handlePlayPause() async {
    if (widget.zikr.audio.isEmpty || _currentAudioPath == null) return;

    try {
      // Animate button press
      _playController.forward().then((_) {
        _playController.reverse();
      });
      
      if (_isPlaying && _isCurrentAudio) {
        // Pause current audio
        await _audioService.pause();
        _currentlyPlayingPath = null;
      } else {
        // Stop any currently playing audio
        if (_currentlyPlayingPath != null && _currentlyPlayingPath != _currentAudioPath) {
          await _audioService.stop();
        }
        
        // Play this audio
        await _audioService.playAudio(_currentAudioPath!, isLocal: true);
        _currentlyPlayingPath = _currentAudioPath;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error playing audio: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Hero(
          tag: 'zikr_${widget.zikr.id}',
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            constraints: const BoxConstraints(
              minHeight: 90,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            widget.zikr.title.ar,
                            style: AppTheme.arabicMedium.copyWith(
                              fontSize: 15,
                              color: AppTheme.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (widget.zikr.translation?.en.isNotEmpty ?? false) ...[
                            const SizedBox(height: 3),
                            Text(
                              widget.zikr.translation!.en,
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                          const SizedBox(height: 6),
                          Text(
                            widget.zikr.text,
                            style: AppTheme.arabicSmall.copyWith(
                              color: AppTheme.textSecondary,
                              fontSize: 13,
                              height: 1.5,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              // Repetition badge
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.repeat,
                                      size: 12,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 3),
                                    Text(
                                      '${widget.zikr.defaultCount}x',
                                      style: AppTheme.caption.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 11,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // Play button
                              if (widget.zikr.audio.isNotEmpty)
                                _buildPlayButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(
                            widget.isFavorite
                                ? Icons.favorite
                                : Icons.favorite_border,
                            color: widget.isFavorite
                                ? Colors.red
                                : AppTheme.textSecondary,
                            size: 20,
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 36,
                            minHeight: 36,
                          ),
                          onPressed: widget.onFavoriteToggle,
                        ),
                        const Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ],
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

  Widget _buildPlayButton() {
    return GestureDetector(
      onTap: _handlePlayPause,
      child: ScaleTransition(
        scale: _playScaleAnimation,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: _isPlaying && _isCurrentAudio
                  ? [
                      AppTheme.primaryTeal,
                      AppTheme.primaryGreen,
                    ]
                  : [
                      AppTheme.primaryGreen,
                      AppTheme.primaryTeal,
                    ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: (_isPlaying && _isCurrentAudio
                        ? AppTheme.primaryTeal
                        : AppTheme.primaryGreen)
                    .withOpacity(0.4),
                blurRadius: 12,
                offset: const Offset(0, 4),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Pulsing ring when playing
              if (_isPlaying && _isCurrentAudio)
                ScaleTransition(
                  scale: _pulseAnimation,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 2,
                      ),
                    ),
                  ),
                ),
              // Play/Pause icon
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  _isPlaying && _isCurrentAudio
                      ? Icons.pause
                      : Icons.play_arrow,
                  key: ValueKey(_isPlaying && _isCurrentAudio),
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
