import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:just_audio/just_audio.dart';
import '../../domain/models/zikr.dart';
import '../../utils/theme.dart';
import '../../utils/theme_extensions.dart';
import '../../data/services/audio_player_service.dart';
import '../providers/player_providers.dart';
import 'dart:math' as math;

class PlayerScreen extends ConsumerStatefulWidget {
  final Zikr zikr;

  const PlayerScreen({super.key, required this.zikr});

  @override
  ConsumerState<PlayerScreen> createState() => _PlayerScreenState();
}

class _PlayerScreenState extends ConsumerState<PlayerScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  int _currentRepetition = 0;
  StreamSubscription<PlayerState>? _playerStateSubscription;
  bool _isCompleted = false;

  @override
  void initState() {
    super.initState();
    
    // Initialize target count in provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(targetCountProvider(widget.zikr.id).notifier).state = 
          widget.zikr.defaultCount;
    });
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    _pulseController.repeat(reverse: true);
    
    // Don't auto-play - let user control playback
    _setupAudioCompletionListener();
  }

  void _setupAudioCompletionListener() {
    final audioService = ref.read(audioPlayerServiceProvider);
    _playerStateSubscription = audioService.playerStateStream.listen((state) {
      if (mounted && 
          state.processingState == ProcessingState.completed && 
          !_isCompleted) {
        _handleAudioCompletion();
      }
    });
  }

  Future<void> _handleAudioCompletion() async {
    setState(() {
      _currentRepetition++;
    });

    if (_currentRepetition < widget.zikr.defaultCount) {
      // Replay audio
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        await _playAudio();
      }
    } else {
      // All repetitions completed
      setState(() {
        _isCompleted = true;
      });
      
      // Show completion message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Text('Completed ${widget.zikr.defaultCount}x repetitions!'),
              ],
            ),
            backgroundColor: AppTheme.primaryGreen,
            duration: const Duration(seconds: 2),
          ),
        );
      }
      
      // Reset to initial state after a short delay
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        _resetToInitialState();
      }
    }
  }

  void _resetToInitialState() {
    final audioService = ref.read(audioPlayerServiceProvider);
    audioService.stop();
    
    setState(() {
      _currentRepetition = 0;
      _isCompleted = false;
    });
  }

  Future<void> _playAudio() async {
    try {
      final audioService = ref.read(audioPlayerServiceProvider);
      if (widget.zikr.audio.isNotEmpty) {
        setState(() {
          _isCompleted = false;
        });
        
        final audioInfo = widget.zikr.audio.first;
        final audioPath = audioInfo.shortFile ?? audioInfo.fullFileUrl;
        
        debugPrint('=== Playing Audio ===');
        debugPrint('Zikr ID: ${widget.zikr.id}');
        debugPrint('Zikr Title: ${widget.zikr.title.ar}');
        debugPrint('Audio Path: $audioPath');
        debugPrint('Short File: ${audioInfo.shortFile}');
        debugPrint('Full File URL: ${audioInfo.fullFileUrl}');
        
        if (audioPath.isEmpty) {
          throw Exception('No audio path available');
        }
        
        await audioService.playAudio(
          audioPath,
          isLocal: true,
        );
      }
    } catch (e) {
      debugPrint('Error playing: $e');
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
  void dispose() {
    _pulseController.dispose();
    _playerStateSubscription?.cancel();
    
    // Stop audio when leaving the screen
    // We need to do this before the widget is disposed
    final audioService = AudioPlayerService();
    audioService.stop();
    
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: AppTheme.primaryGreen),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.more_vert, color: AppTheme.primaryGreen),
            ),
            onPressed: () {},
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.primaryGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      const SizedBox(height: 20),
                      _buildTitle(),
                      const SizedBox(height: 16),
                      _buildRepetitionIndicator(),
                      const SizedBox(height: 40),
                      _buildArabicText(),
                      const SizedBox(height: 40),
                      _buildCounter(),
                      const SizedBox(height: 40),
                      _buildProgressIndicator(),
                    ],
                  ),
                ),
              ),
              _buildAudioControls(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          widget.zikr.title.ar,
          style: AppTheme.arabicLarge.copyWith(
            color: Colors.white,
            fontSize: 28,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          widget.zikr.title.en,
          style: AppTheme.titleMedium.copyWith(
            color: Colors.white.withOpacity(0.9),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildArabicText() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Text(
        widget.zikr.text,
        style: AppTheme.arabicLarge.copyWith(
          color: Colors.white,
          fontSize: 22,
          height: 2.0,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildCounter() {
    final currentCount = ref.watch(currentCountProvider(widget.zikr.id));
    final targetCount = ref.watch(targetCountProvider(widget.zikr.id));
    
    return Column(
      children: [
        Text(
          'Repetition Count',
          style: AppTheme.bodyMedium.copyWith(
            color: Colors.white.withOpacity(0.8),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCounterButton(
              icon: Icons.remove,
              onPressed: () {
                if (currentCount > 0) {
                  ref.read(currentCountProvider(widget.zikr.id).notifier).state--;
                }
              },
            ),
            const SizedBox(width: 24),
            GestureDetector(
              onTap: () {
                if (currentCount < targetCount) {
                  ref.read(currentCountProvider(widget.zikr.id).notifier).state++;
                  _animateIncrement();
                }
              },
              child: RepaintBoundary(
                child: Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (child, animation) {
                            return ScaleTransition(
                              scale: animation,
                              child: child,
                            );
                          },
                          child: Text(
                            '$currentCount',
                            key: ValueKey(currentCount),
                            style: AppTheme.headlineLarge.copyWith(
                              fontSize: 48,
                              color: AppTheme.primaryGreen,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        Text(
                          'of $targetCount',
                          style: AppTheme.caption.copyWith(
                            color: context.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 24),
            _buildCounterButton(
              icon: Icons.add,
              onPressed: () {
                ref.read(currentCountProvider(widget.zikr.id).notifier).state++;
                _animateIncrement();
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        ElevatedButton.icon(
          onPressed: () {
            ref.read(currentCountProvider(widget.zikr.id).notifier).state = 0;
          },
          icon: const Icon(Icons.refresh),
          label: const Text('Reset'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.2),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.2),
      ),
      child: IconButton(
        icon: Icon(icon),
        color: Colors.white,
        iconSize: 28,
        onPressed: onPressed,
      ),
    );
  }

  void _animateIncrement() {
    _pulseController.forward(from: 0);
  }

  Widget _buildRepetitionIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(_isCompleted ? 0.3 : 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 2,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _isCompleted ? Icons.check_circle : Icons.repeat,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            _isCompleted 
                ? 'Completed!' 
                : 'Repetition ${_currentRepetition + 1} of ${widget.zikr.defaultCount}',
            style: AppTheme.bodyMedium.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    final progress = ref.watch(progressProvider(widget.zikr.id));

    return RepaintBoundary(
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 200,
                height: 200,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 12,
                  backgroundColor: Colors.white.withOpacity(0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFFFFD700)),
                ),
              ),
              Column(
                children: [
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: AppTheme.headlineMedium.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Completed',
                    style: AppTheme.bodyMedium.copyWith(
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAudioControls() {
    final audioService = ref.watch(audioPlayerServiceProvider);
    
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          StreamBuilder<Duration?>(
            stream: audioService.durationStream,
            builder: (context, durationSnapshot) {
              return StreamBuilder<Duration>(
                stream: audioService.positionStream,
                builder: (context, positionSnapshot) {
                  final duration = durationSnapshot.data ?? Duration.zero;
                  final position = positionSnapshot.data ?? Duration.zero;
                  final progress = duration.inMilliseconds > 0
                      ? position.inMilliseconds / duration.inMilliseconds
                      : 0.0;

                  return Column(
                    children: [
                      SliderTheme(
                        data: SliderThemeData(
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 8,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 16,
                          ),
                          trackHeight: 4,
                          activeTrackColor: AppTheme.primaryGreen,
                          inactiveTrackColor: Colors.grey.shade300,
                          thumbColor: AppTheme.primaryGreen,
                          overlayColor: AppTheme.primaryGreen.withOpacity(0.2),
                        ),
                        child: Slider(
                          value: progress.clamp(0.0, 1.0),
                          onChanged: (value) {
                            final newPosition = Duration(
                              milliseconds: (value * duration.inMilliseconds).toInt(),
                            );
                            audioService.seek(newPosition);
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              _formatDuration(position),
                              style: AppTheme.caption.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                            Text(
                              _formatDuration(duration),
                              style: AppTheme.caption.copyWith(
                                color: context.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.replay_10),
                iconSize: 32,
                color: context.textSecondary,
                onPressed: () {
                  final newPosition = audioService.position - const Duration(seconds: 10);
                  audioService.seek(newPosition);
                },
              ),
              StreamBuilder<PlayerState>(
                stream: audioService.playerStateStream,
                builder: (context, snapshot) {
                  final isPlaying = snapshot.data?.playing ?? false;
                  final processingState = snapshot.data?.processingState;
                  
                  return AnimatedPlayButton(
                    isPlaying: isPlaying,
                    onPressed: () async {
                      if (isPlaying) {
                        audioService.pause();
                      } else {
                        // Check if audio is loaded
                        if (processingState == ProcessingState.idle || 
                            processingState == null ||
                            audioService.duration == Duration.zero) {
                          // Audio not loaded yet, play it
                          await _playAudio();
                        } else {
                          // Audio already loaded, just resume
                          audioService.resume();
                        }
                      }
                    },
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.forward_10),
                iconSize: 32,
                color: context.textSecondary,
                onPressed: () {
                  final newPosition = audioService.position + const Duration(seconds: 10);
                  audioService.seek(newPosition);
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}

class AnimatedPlayButton extends StatefulWidget {
  final bool isPlaying;
  final VoidCallback onPressed;

  const AnimatedPlayButton({
    super.key,
    required this.isPlaying,
    required this.onPressed,
  });

  @override
  State<AnimatedPlayButton> createState() => _AnimatedPlayButtonState();
}

class _AnimatedPlayButtonState extends State<AnimatedPlayButton>
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
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onPressed();
      },
      onTapCancel: () => _controller.reverse(),
      child: RepaintBoundary(
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              gradient: AppTheme.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryGreen.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              transitionBuilder: (child, animation) {
                return RotationTransition(
                  turns: Tween<double>(begin: 0.8, end: 1.0).animate(animation),
                  child: FadeTransition(
                    opacity: animation,
                    child: child,
                  ),
                );
              },
              child: Icon(
                widget.isPlaying ? Icons.pause : Icons.play_arrow,
                key: ValueKey(widget.isPlaying),
                color: Colors.white,
                size: 36,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
