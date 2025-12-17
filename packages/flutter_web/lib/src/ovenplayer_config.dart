/// Configuration classes for OvenPlayer
library;

/// Configuration for an OvenPlayer source
class OvenPlayerSource {
  /// Label for the source (displayed in UI)
  final String? label;

  /// Type of source: 'webrtc', 'hls', 'dash', 'mp4', etc.
  final String type;

  /// URL or path to the media file
  final String file;

  /// Frame rate (optional)
  final int? framerate;

  OvenPlayerSource({
    this.label,
    required this.type,
    required this.file,
    this.framerate,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'type': type,
      'file': file,
    };
    if (label != null) json['label'] = label;
    if (framerate != null) json['framerate'] = framerate;
    return json;
  }
}

/// WebRTC specific configuration
class OvenPlayerWebRTCConfig {
  /// Maximum number of timeout retries
  final int? timeoutMaxRetry;

  /// Connection timeout in milliseconds
  final int? connectionTimeout;

  /// Enable packet loss recovery
  final bool? recoverPacketLoss;

  /// Generate public candidate
  final bool? generatePublicCandidate;

  OvenPlayerWebRTCConfig({
    this.timeoutMaxRetry,
    this.connectionTimeout,
    this.recoverPacketLoss,
    this.generatePublicCandidate,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};
    if (timeoutMaxRetry != null) json['timeoutMaxRetry'] = timeoutMaxRetry;
    if (connectionTimeout != null) json['connectionTimeout'] = connectionTimeout;
    if (recoverPacketLoss != null) json['recoverPacketLoss'] = recoverPacketLoss;
    if (generatePublicCandidate != null) {
      json['generatePublicCandidate'] = generatePublicCandidate;
    }
    return json;
  }
}

/// Main configuration for OvenPlayer
class OvenPlayerConfig {
  /// List of media sources
  final List<OvenPlayerSource> sources;

  /// Whether to start playback automatically
  final bool? autoStart;

  /// Enable automatic fallback to next source on error
  final bool? autoFallback;

  /// Initial mute state
  final bool? mute;

  /// Initial volume (0-100)
  final int? volume;

  /// Show player controls
  final bool? controls;

  /// Time in milliseconds to hide controls after inactivity
  final int? hideControlsTimeout;

  /// Show big play button in center
  final bool? showBigPlayButton;

  /// Disable seek UI controls
  final bool? disableSeekUI;

  /// Available playback rates
  final List<double>? playbackRates;

  /// WebRTC specific configuration
  final OvenPlayerWebRTCConfig? webrtcConfig;

  /// Playlist title
  final String? title;

  /// Poster image URL
  final String? image;

  /// Width of the player (can be number or string like "100%")
  final dynamic width;

  /// Height of the player (can be number or string like "100%")
  final dynamic height;

  /// Aspect ratio (e.g., "16:9")
  final String? aspectRatio;

  OvenPlayerConfig({
    required this.sources,
    this.autoStart,
    this.autoFallback,
    this.mute,
    this.volume,
    this.controls,
    this.hideControlsTimeout,
    this.showBigPlayButton,
    this.disableSeekUI,
    this.playbackRates,
    this.webrtcConfig,
    this.title,
    this.image,
    this.width,
    this.height,
    this.aspectRatio,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'sources': sources.map((s) => s.toJson()).toList(),
    };

    if (autoStart != null) json['autoStart'] = autoStart;
    if (autoFallback != null) json['autoFallback'] = autoFallback;
    if (mute != null) json['mute'] = mute;
    if (volume != null) json['volume'] = volume;
    if (controls != null) json['controls'] = controls;
    if (hideControlsTimeout != null) {
      json['hideControlsTimeout'] = hideControlsTimeout;
    }
    if (showBigPlayButton != null) {
      json['showBigPlayButton'] = showBigPlayButton;
    }
    if (disableSeekUI != null) json['disableSeekUI'] = disableSeekUI;
    if (playbackRates != null) json['playbackRates'] = playbackRates;
    if (webrtcConfig != null) json['webrtcConfig'] = webrtcConfig!.toJson();
    if (title != null) json['title'] = title;
    if (image != null) json['image'] = image;
    if (width != null) json['width'] = width;
    if (height != null) json['height'] = height;
    if (aspectRatio != null) json['aspectRatio'] = aspectRatio;

    return json;
  }
}
