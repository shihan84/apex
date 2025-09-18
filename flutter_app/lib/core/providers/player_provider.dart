import 'package:flutter/foundation.dart';
import 'package:better_player/better_player.dart';

import '../models/content_model.dart';
import '../constants/app_constants.dart';

class PlayerProvider with ChangeNotifier {
  BetterPlayerController? _controller;
  ContentModel? _currentContent;
  ContentVideo? _currentVideo;
  ContentAudio? _currentAudio;
  ContentSubtitle? _currentSubtitle;
  
  bool _isPlaying = false;
  bool _isBuffering = false;
  bool _isFullscreen = false;
  bool _isControlsVisible = true;
  bool _isMuted = false;
  bool _isLooping = false;
  bool _isAutoPlay = true;
  
  double _volume = 1.0;
  double _playbackSpeed = 1.0;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  Duration _buffered = Duration.zero;
  
  VideoQuality _currentQuality = VideoQuality.auto;
  String _currentLanguage = 'en';
  
  List<ContentVideo> _availableVideos = [];
  List<ContentAudio> _availableAudios = [];
  List<ContentSubtitle> _availableSubtitles = [];
  
  // Getters
  BetterPlayerController? get controller => _controller;
  ContentModel? get currentContent => _currentContent;
  ContentVideo? get currentVideo => _currentVideo;
  ContentAudio? get currentAudio => _currentAudio;
  ContentSubtitle? get currentSubtitle => _currentSubtitle;
  
  bool get isPlaying => _isPlaying;
  bool get isBuffering => _isBuffering;
  bool get isFullscreen => _isFullscreen;
  bool get isControlsVisible => _isControlsVisible;
  bool get isMuted => _isMuted;
  bool get isLooping => _isLooping;
  bool get isAutoPlay => _isAutoPlay;
  
  double get volume => _volume;
  double get playbackSpeed => _playbackSpeed;
  Duration get position => _position;
  Duration get duration => _duration;
  Duration get buffered => _buffered;
  
  VideoQuality get currentQuality => _currentQuality;
  String get currentLanguage => _currentLanguage;
  
  List<ContentVideo> get availableVideos => _availableVideos;
  List<ContentAudio> get availableAudios => _availableAudios;
  List<ContentSubtitle> get availableSubtitles => _availableSubtitles;
  
  double get progress => _duration.inMilliseconds > 0 
      ? _position.inMilliseconds / _duration.inMilliseconds 
      : 0.0;
  
  String get positionFormatted => _formatDuration(_position);
  String get durationFormatted => _formatDuration(_duration);
  String get remainingFormatted => _formatDuration(_duration - _position);

  // Initialize player
  Future<void> initializePlayer({
    required ContentModel content,
    ContentVideo? video,
    ContentAudio? audio,
    ContentSubtitle? subtitle,
    List<ContentVideo>? videos,
    List<ContentAudio>? audios,
    List<ContentSubtitle>? subtitles,
  }) async {
    _currentContent = content;
    _availableVideos = videos ?? content.videos;
    _availableAudios = audios ?? content.audios;
    _availableSubtitles = subtitles ?? content.subtitles;
    
    // Select best video quality
    _currentVideo = video ?? _selectBestVideo();
    _currentAudio = audio ?? _selectBestAudio();
    _currentSubtitle = subtitle ?? _selectBestSubtitle();
    
    if (_currentVideo == null) return;
    
    // Dispose existing controller
    await dispose();
    
    // Create new controller
    _controller = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: _isAutoPlay,
        looping: _isLooping,
        fullScreenByDefault: false,
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControlsOnInitialize: true,
          showControls: _isControlsVisible,
          controlBarColor: Colors.black54,
          iconsColor: Colors.white,
          progressBarPlayedColor: AppConstants.primaryColor,
          progressBarHandleColor: AppConstants.primaryColor,
          progressBarBufferedColor: Colors.white30,
          progressBarBackgroundColor: Colors.white10,
          textColor: Colors.white,
          loadingWidget: const CircularProgressIndicator(
            color: AppConstants.primaryColor,
          ),
          skipBackwardIcon: Icons.replay_10,
          skipForwardIcon: Icons.forward_10,
          playIcon: Icons.play_arrow,
          pauseIcon: Icons.pause,
          fullscreenIcon: Icons.fullscreen,
          fullscreenExitIcon: Icons.fullscreen_exit,
          muteIcon: Icons.volume_off,
          unMuteIcon: Icons.volume_up,
          playbackSpeedIcon: Icons.speed,
          subtitlesIcon: Icons.subtitles,
          settingsIcon: Icons.settings,
          overflowMenuIcon: Icons.more_vert,
        ),
        eventListener: _onPlayerEvent,
      ),
    );
    
    // Setup data source
    await _setupDataSource();
    
    notifyListeners();
  }

  // Setup data source
  Future<void> _setupDataSource() async {
    if (_controller == null || _currentVideo == null) return;
    
    BetterPlayerDataSource dataSource;
    
    if (_currentVideo!.isHls) {
      dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        _currentVideo!.url,
        headers: _currentVideo!.headers,
        videoFormat: BetterPlayerVideoFormat.hls,
        liveStream: _currentContent?.isLive ?? false,
      );
    } else if (_currentVideo!.isDash) {
      dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        _currentVideo!.url,
        headers: _currentVideo!.headers,
        videoFormat: BetterPlayerVideoFormat.dash,
        liveStream: _currentContent?.isLive ?? false,
      );
    } else {
      dataSource = BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        _currentVideo!.url,
        headers: _currentVideo!.headers,
        videoFormat: BetterPlayerVideoFormat.other,
        liveStream: _currentContent?.isLive ?? false,
      );
    }
    
    await _controller!.setupDataSource(dataSource);
  }

  // Play
  Future<void> play() async {
    if (_controller != null) {
      await _controller!.play();
      _isPlaying = true;
      notifyListeners();
    }
  }

  // Pause
  Future<void> pause() async {
    if (_controller != null) {
      await _controller!.pause();
      _isPlaying = false;
      notifyListeners();
    }
  }

  // Toggle play/pause
  Future<void> togglePlayPause() async {
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  // Seek to position
  Future<void> seekTo(Duration position) async {
    if (_controller != null) {
      await _controller!.seekTo(position);
      _position = position;
      notifyListeners();
    }
  }

  // Skip forward
  Future<void> skipForward() async {
    final newPosition = _position + AppConstants.skipForwardDuration;
    if (newPosition <= _duration) {
      await seekTo(newPosition);
    }
  }

  // Skip backward
  Future<void> skipBackward() async {
    final newPosition = _position - AppConstants.skipBackwardDuration;
    if (newPosition >= Duration.zero) {
      await seekTo(newPosition);
    }
  }

  // Set volume
  Future<void> setVolume(double volume) async {
    _volume = volume.clamp(0.0, 1.0);
    if (_controller != null) {
      await _controller!.setVolume(_volume);
      _isMuted = _volume == 0.0;
      notifyListeners();
    }
  }

  // Toggle mute
  Future<void> toggleMute() async {
    if (_isMuted) {
      await setVolume(1.0);
    } else {
      await setVolume(0.0);
    }
  }

  // Set playback speed
  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    if (_controller != null) {
      await _controller!.setSpeed(speed);
      notifyListeners();
    }
  }

  // Toggle fullscreen
  Future<void> toggleFullscreen() async {
    if (_controller != null) {
      if (_isFullscreen) {
        await _controller!.exitFullScreen();
      } else {
        await _controller!.enterFullScreen();
      }
      _isFullscreen = !_isFullscreen;
      notifyListeners();
    }
  }

  // Toggle controls
  void toggleControls() {
    _isControlsVisible = !_isControlsVisible;
    if (_controller != null) {
      _controller!.showControls(_isControlsVisible);
    }
    notifyListeners();
  }

  // Toggle loop
  Future<void> toggleLoop() async {
    _isLooping = !_isLooping;
    if (_controller != null) {
      await _controller!.setLooping(_isLooping);
    }
    notifyListeners();
  }

  // Change video quality
  Future<void> changeVideoQuality(VideoQuality quality) async {
    if (_currentQuality == quality) return;
    
    _currentQuality = quality;
    final video = _selectVideoByQuality(quality);
    
    if (video != null && video != _currentVideo) {
      _currentVideo = video;
      await _setupDataSource();
      notifyListeners();
    }
  }

  // Change audio track
  Future<void> changeAudioTrack(ContentAudio audio) async {
    if (_currentAudio == audio) return;
    
    _currentAudio = audio;
    _currentLanguage = audio.language;
    notifyListeners();
  }

  // Change subtitle
  Future<void> changeSubtitle(ContentSubtitle? subtitle) async {
    if (_currentSubtitle == subtitle) return;
    
    _currentSubtitle = subtitle;
    if (subtitle != null) {
      _currentLanguage = subtitle.language;
    }
    notifyListeners();
  }

  // Select best video quality
  ContentVideo? _selectBestVideo() {
    if (_availableVideos.isEmpty) return null;
    
    // Sort by quality preference
    final sortedVideos = List<ContentVideo>.from(_availableVideos);
    sortedVideos.sort((a, b) {
      final qualityOrder = {
        VideoQuality.ultra: 4,
        VideoQuality.high: 3,
        VideoQuality.medium: 2,
        VideoQuality.low: 1,
        VideoQuality.auto: 0,
      };
      
      return (qualityOrder[b.quality] ?? 0).compareTo(qualityOrder[a.quality] ?? 0);
    });
    
    return sortedVideos.first;
  }

  // Select best audio
  ContentAudio? _selectBestAudio() {
    if (_availableAudios.isEmpty) return null;
    
    // Prefer default audio or first available
    final defaultAudio = _availableAudios.firstWhere(
      (audio) => audio.isDefault,
      orElse: () => _availableAudios.first,
    );
    
    return defaultAudio;
  }

  // Select best subtitle
  ContentSubtitle? _selectBestSubtitle() {
    if (_availableSubtitles.isEmpty) return null;
    
    // Prefer default subtitle or first available
    final defaultSubtitle = _availableSubtitles.firstWhere(
      (subtitle) => subtitle.isDefault,
      orElse: () => _availableSubtitles.first,
    );
    
    return defaultSubtitle;
  }

  // Select video by quality
  ContentVideo? _selectVideoByQuality(VideoQuality quality) {
    if (quality == VideoQuality.auto) {
      return _selectBestVideo();
    }
    
    return _availableVideos.firstWhere(
      (video) => video.quality == quality,
      orElse: () => _selectBestVideo()!,
    );
  }

  // Player event handler
  void _onPlayerEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        _duration = _controller?.videoPlayerController?.value.duration ?? Duration.zero;
        break;
      case BetterPlayerEventType.play:
        _isPlaying = true;
        break;
      case BetterPlayerEventType.pause:
        _isPlaying = false;
        break;
      case BetterPlayerEventType.seekTo:
        _position = event.parameters?['progress'] ?? Duration.zero;
        break;
      case BetterPlayerEventType.setVolume:
        _volume = event.parameters?['volume'] ?? 1.0;
        _isMuted = _volume == 0.0;
        break;
      case BetterPlayerEventType.setSpeed:
        _playbackSpeed = event.parameters?['speed'] ?? 1.0;
        break;
      case BetterPlayerEventType.bufferingStart:
        _isBuffering = true;
        break;
      case BetterPlayerEventType.bufferingEnd:
        _isBuffering = false;
        break;
      case BetterPlayerEventType.controlsVisible:
        _isControlsVisible = event.parameters?['visible'] ?? true;
        break;
      case BetterPlayerEventType.controlsHidden:
        _isControlsVisible = false;
        break;
      case BetterPlayerEventType.fullscreenChanged:
        _isFullscreen = event.parameters?['isFullscreen'] ?? false;
        break;
      case BetterPlayerEventType.progress:
        _position = event.parameters?['progress'] ?? Duration.zero;
        _duration = event.parameters?['duration'] ?? Duration.zero;
        _buffered = event.parameters?['buffered'] ?? Duration.zero;
        break;
      case BetterPlayerEventType.finished:
        _isPlaying = false;
        _position = Duration.zero;
        break;
      case BetterPlayerEventType.exception:
        _isBuffering = false;
        _isPlaying = false;
        break;
      default:
        break;
    }
    
    notifyListeners();
  }

  // Format duration
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);
    
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  // Dispose
  Future<void> dispose() async {
    if (_controller != null) {
      await _controller!.dispose();
      _controller = null;
    }
    
    _currentContent = null;
    _currentVideo = null;
    _currentAudio = null;
    _currentSubtitle = null;
    _availableVideos.clear();
    _availableAudios.clear();
    _availableSubtitles.clear();
    
    _isPlaying = false;
    _isBuffering = false;
    _isFullscreen = false;
    _isControlsVisible = true;
    _isMuted = false;
    _isLooping = false;
    
    _volume = 1.0;
    _playbackSpeed = 1.0;
    _position = Duration.zero;
    _duration = Duration.zero;
    _buffered = Duration.zero;
    
    _currentQuality = VideoQuality.auto;
    _currentLanguage = 'en';
    
    notifyListeners();
  }
}
