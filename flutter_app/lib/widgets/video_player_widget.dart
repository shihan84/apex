import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:better_player/better_player.dart';

import '../core/providers/player_provider.dart';
import '../core/models/content_model.dart';
import '../core/constants/app_constants.dart';

class VideoPlayerWidget extends StatefulWidget {
  final ContentModel content;
  final bool autoPlay;
  final bool showControls;
  final bool isFullscreen;
  final Function(ContentModel)? onContentChanged;

  const VideoPlayerWidget({
    super.key,
    required this.content,
    this.autoPlay = true,
    this.showControls = true,
    this.isFullscreen = false,
    this.onContentChanged,
  });

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late PlayerProvider _playerProvider;

  @override
  void initState() {
    super.initState();
    _playerProvider = context.read<PlayerProvider>();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    await _playerProvider.initializePlayer(
      content: widget.content,
      videos: widget.content.videos,
      audios: widget.content.audios,
      subtitles: widget.content.subtitles,
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        if (playerProvider.controller == null) {
          return _buildLoadingWidget();
        }

        return Container(
          width: double.infinity,
          height: widget.isFullscreen 
              ? MediaQuery.of(context).size.height 
              : 200,
          color: Colors.black,
          child: Stack(
            children: [
              // Video Player
              BetterPlayer(
                controller: playerProvider.controller!,
              ),
              
              // Custom Controls Overlay
              if (widget.showControls)
                _buildCustomControls(),
              
              // Loading Indicator
              if (playerProvider.isBuffering)
                _buildLoadingIndicator(),
              
              // Error Widget
              if (playerProvider.error != null)
                _buildErrorWidget(),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: double.infinity,
      height: widget.isFullscreen 
          ? MediaQuery.of(context).size.height 
          : 200,
      color: Colors.black,
      child: const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primaryColor,
        ),
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Container(
      color: Colors.black54,
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
            SizedBox(height: 16),
            Text(
              'Buffering...',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Playback Error',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to play this content',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _initializePlayer(),
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomControls() {
    return Consumer<PlayerProvider>(
      builder: (context, playerProvider, child) {
        return GestureDetector(
          onTap: () => playerProvider.toggleControls(),
          child: Container(
            color: Colors.transparent,
            child: Stack(
              children: [
                // Top Controls
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 60,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.black87,
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        // Back Button
                        IconButton(
                          onPressed: () {
                            if (widget.isFullscreen) {
                              playerProvider.toggleFullscreen();
                            } else {
                              Navigator.of(context).pop();
                            }
                          },
                          icon: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                        
                        // Title
                        Expanded(
                          child: Text(
                            playerProvider.currentContent?.title ?? '',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        
                        // Settings Button
                        IconButton(
                          onPressed: () => _showSettingsDialog(),
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Center Play/Pause Button
                Center(
                  child: GestureDetector(
                    onTap: () => playerProvider.togglePlayPause(),
                    child: Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        playerProvider.isPlaying 
                            ? Icons.pause 
                            : Icons.play_arrow,
                        color: Colors.white,
                        size: 40,
                      ),
                    ),
                  ),
                ),
                
                // Bottom Controls
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black87,
                          Colors.transparent,
                        ],
                      ),
                    ),
                    child: Column(
                      children: [
                        // Progress Bar
                        Container(
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          child: LinearProgressIndicator(
                            value: playerProvider.progress,
                            backgroundColor: Colors.white30,
                            valueColor: const AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryColor,
                            ),
                          ),
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Controls Row
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: Row(
                            children: [
                              // Play/Pause Button
                              IconButton(
                                onPressed: () => playerProvider.togglePlayPause(),
                                icon: Icon(
                                  playerProvider.isPlaying 
                                      ? Icons.pause 
                                      : Icons.play_arrow,
                                  color: Colors.white,
                                ),
                              ),
                              
                              // Skip Backward
                              IconButton(
                                onPressed: () => playerProvider.skipBackward(),
                                icon: const Icon(
                                  Icons.replay_10,
                                  color: Colors.white,
                                ),
                              ),
                              
                              // Skip Forward
                              IconButton(
                                onPressed: () => playerProvider.skipForward(),
                                icon: const Icon(
                                  Icons.forward_10,
                                  color: Colors.white,
                                ),
                              ),
                              
                              // Time Display
                              Text(
                                '${playerProvider.positionFormatted} / ${playerProvider.durationFormatted}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                              
                              const Spacer(),
                              
                              // Volume Button
                              IconButton(
                                onPressed: () => playerProvider.toggleMute(),
                                icon: Icon(
                                  playerProvider.isMuted 
                                      ? Icons.volume_off 
                                      : Icons.volume_up,
                                  color: Colors.white,
                                ),
                              ),
                              
                              // Fullscreen Button
                              IconButton(
                                onPressed: () => playerProvider.toggleFullscreen(),
                                icon: Icon(
                                  playerProvider.isFullscreen 
                                      ? Icons.fullscreen_exit 
                                      : Icons.fullscreen,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: const Text(
              'Player Settings',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Quality Selection
                ListTile(
                  title: const Text(
                    'Quality',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  subtitle: Text(
                    playerProvider.currentQuality.name.toUpperCase(),
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  onTap: () => _showQualityDialog(),
                ),
                
                // Audio Track Selection
                if (playerProvider.availableAudios.isNotEmpty)
                  ListTile(
                    title: const Text(
                      'Audio Track',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                    subtitle: Text(
                      playerProvider.currentAudio?.language.toUpperCase() ?? 'Default',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    onTap: () => _showAudioDialog(),
                  ),
                
                // Subtitle Selection
                if (playerProvider.availableSubtitles.isNotEmpty)
                  ListTile(
                    title: const Text(
                      'Subtitles',
                      style: TextStyle(color: AppTheme.textPrimary),
                    ),
                    subtitle: Text(
                      playerProvider.currentSubtitle?.language.toUpperCase() ?? 'Off',
                      style: const TextStyle(color: AppTheme.textSecondary),
                    ),
                    onTap: () => _showSubtitleDialog(),
                  ),
                
                // Playback Speed
                ListTile(
                  title: const Text(
                    'Playback Speed',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  subtitle: Text(
                    '${playerProvider.playbackSpeed}x',
                    style: const TextStyle(color: AppTheme.textSecondary),
                  ),
                  onTap: () => _showSpeedDialog(),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showQualityDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: const Text(
              'Select Quality',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: VideoQuality.values.map((quality) {
                return ListTile(
                  title: Text(
                    quality.name.toUpperCase(),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  trailing: playerProvider.currentQuality == quality
                      ? const Icon(Icons.check, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    playerProvider.changeVideoQuality(quality);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showAudioDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: const Text(
              'Select Audio Track',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: playerProvider.availableAudios.map((audio) {
                return ListTile(
                  title: Text(
                    audio.language.toUpperCase(),
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  subtitle: audio.isDefault
                      ? const Text(
                          'Default',
                          style: TextStyle(color: AppTheme.textSecondary),
                        )
                      : null,
                  trailing: playerProvider.currentAudio == audio
                      ? const Icon(Icons.check, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    playerProvider.changeAudioTrack(audio);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }

  void _showSubtitleDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          return AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: const Text(
              'Select Subtitle',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Off option
                ListTile(
                  title: const Text(
                    'Off',
                    style: TextStyle(color: AppTheme.textPrimary),
                  ),
                  trailing: playerProvider.currentSubtitle == null
                      ? const Icon(Icons.check, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    playerProvider.changeSubtitle(null);
                    Navigator.of(context).pop();
                  },
                ),
                // Subtitle options
                ...playerProvider.availableSubtitles.map((subtitle) {
                  return ListTile(
                    title: Text(
                      subtitle.language.toUpperCase(),
                      style: const TextStyle(color: AppTheme.textPrimary),
                    ),
                    subtitle: subtitle.isDefault
                        ? const Text(
                            'Default',
                            style: TextStyle(color: AppTheme.textSecondary),
                          )
                        : null,
                    trailing: playerProvider.currentSubtitle == subtitle
                        ? const Icon(Icons.check, color: AppTheme.primaryColor)
                        : null,
                    onTap: () {
                      playerProvider.changeSubtitle(subtitle);
                      Navigator.of(context).pop();
                    },
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
    );
  }

  void _showSpeedDialog() {
    showDialog(
      context: context,
      builder: (context) => Consumer<PlayerProvider>(
        builder: (context, playerProvider, child) {
          final speeds = [0.5, 0.75, 1.0, 1.25, 1.5, 2.0];
          
          return AlertDialog(
            backgroundColor: AppTheme.surfaceColor,
            title: const Text(
              'Select Playback Speed',
              style: TextStyle(color: AppTheme.textPrimary),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: speeds.map((speed) {
                return ListTile(
                  title: Text(
                    '${speed}x',
                    style: const TextStyle(color: AppTheme.textPrimary),
                  ),
                  trailing: playerProvider.playbackSpeed == speed
                      ? const Icon(Icons.check, color: AppTheme.primaryColor)
                      : null,
                  onTap: () {
                    playerProvider.setPlaybackSpeed(speed);
                    Navigator.of(context).pop();
                  },
                );
              }).toList(),
            ),
          );
        },
      ),
    );
  }
}
