import 'dart:convert';

/// Configuration for OvenPlayer
class OvenPlayerConfig {
  /// List of media sources to play
  final List<OvenPlayerSource> sources;

  /// Configuration for WebRTC connections
  final WebRTCConfig? webrtcConfig;

  /// Enable automatic fallback to other protocols
  final bool? autoFallback;

  /// Enable automatic quality switching
  final bool? autoQuality;

  /// Initial volume (0-100)
  final int? volume;

  /// Start muted
  final bool? muted;

  /// Enable autoplay
  final bool? autoStart;

  /// Show player controls
  final bool? controls;

  /// Enable stream parsing (for SEI data)
  final ParseStreamConfig? parseStream;

  /// Show time display
  final bool? showBigPlayButton;

  /// Disable seek controls
  final bool? disableSeekUI;

  /// Image URL for poster/thumbnail
  final String? image;

  /// Watermark configuration
  final WatermarkConfig? watermark;

  /// Timecode configuration
  final TimecodeConfig? timecode;

  const OvenPlayerConfig({
    required this.sources,
    this.webrtcConfig,
    this.autoFallback,
    this.autoQuality,
    this.volume,
    this.muted,
    this.autoStart,
    this.controls,
    this.parseStream,
    this.showBigPlayButton,
    this.disableSeekUI,
    this.image,
    this.watermark,
    this.timecode,
  });

  /// Convert configuration to JSON for JavaScript interop
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'sources': sources.map((s) => s.toJson()).toList(),
    };

    if (webrtcConfig != null) json['webrtcConfig'] = webrtcConfig!.toJson();
    if (autoFallback != null) json['autoFallback'] = autoFallback;
    if (autoQuality != null) json['autoQuality'] = autoQuality;
    if (volume != null) json['volume'] = volume;
    if (muted != null) json['muted'] = muted;
    if (autoStart != null) json['autoStart'] = autoStart;
    if (controls != null) json['controls'] = controls;
    if (parseStream != null) json['parseStream'] = parseStream!.toJson();
    if (showBigPlayButton != null) json['showBigPlayButton'] = showBigPlayButton;
    if (disableSeekUI != null) json['disableSeekUI'] = disableSeekUI;
    if (image != null) json['image'] = image;
    if (watermark != null) json['watermark'] = watermark!.toJson();
    if (timecode != null) json['timecode'] = timecode!.toJson();

    return json;
  }

  String toJsonString() => jsonEncode(toJson());
}

/// Media source configuration
class OvenPlayerSource {
  /// Source type: 'webrtc', 'hls', 'dash', 'mp4', etc.
  final String type;

  /// Source URL or file path
  final String file;

  /// Label for this source
  final String? label;

  /// Optional frame rate
  final double? framerate;

  const OvenPlayerSource({
    required this.type,
    required this.file,
    this.label,
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
class WebRTCConfig {
  /// Connection timeout in milliseconds
  final int? connectionTimeout;

  /// Maximum number of retries on timeout
  final int? timeoutMaxRetry;

  /// ICE servers for WebRTC connection
  final List<IceServer>? iceServers;

  /// ICE transport policy: 'all' or 'relay'
  final String? iceTransportPolicy;

  /// Enable packet loss recovery
  final bool? recoverPacketLoss;

  /// Generate public candidate
  final bool? generatePublicCandidate;

  /// Playout delay hint in seconds
  final double? playoutDelayHint;

  const WebRTCConfig({
    this.connectionTimeout,
    this.timeoutMaxRetry,
    this.iceServers,
    this.iceTransportPolicy,
    this.recoverPacketLoss,
    this.generatePublicCandidate,
    this.playoutDelayHint,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{};

    if (connectionTimeout != null) json['connectionTimeout'] = connectionTimeout;
    if (timeoutMaxRetry != null) json['timeoutMaxRetry'] = timeoutMaxRetry;
    if (iceServers != null) json['iceServers'] = iceServers!.map((s) => s.toJson()).toList();
    if (iceTransportPolicy != null) json['iceTransportPolicy'] = iceTransportPolicy;
    if (recoverPacketLoss != null) json['recoverPacketLoss'] = recoverPacketLoss;
    if (generatePublicCandidate != null) json['generatePublicCandidate'] = generatePublicCandidate;
    if (playoutDelayHint != null) json['playoutDelayHint'] = playoutDelayHint;

    return json;
  }
}

/// ICE server configuration
class IceServer {
  /// ICE server URLs
  final List<String> urls;

  /// Username for authentication
  final String? username;

  /// Credential for authentication
  final String? credential;

  const IceServer({
    required this.urls,
    this.username,
    this.credential,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'urls': urls,
    };

    if (username != null) json['username'] = username;
    if (credential != null) json['credential'] = credential;

    return json;
  }
}

/// Parse stream configuration for extracting SEI data
class ParseStreamConfig {
  /// Enable stream parsing
  final bool enabled;

  const ParseStreamConfig({
    this.enabled = false,
  });

  Map<String, dynamic> toJson() {
    return {'enabled': enabled};
  }
}

/// Watermark configuration
class WatermarkConfig {
  /// Watermark image URL
  final String image;

  /// Watermark position
  final String? position;

  /// Watermark width
  final String? width;

  /// Watermark height
  final String? height;

  /// Opacity (0-1)
  final double? opacity;

  const WatermarkConfig({
    required this.image,
    this.position,
    this.width,
    this.height,
    this.opacity,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'image': image,
    };

    if (position != null) json['position'] = position;
    if (width != null) json['width'] = width;
    if (height != null) json['height'] = height;
    if (opacity != null) json['opacity'] = opacity;

    return json;
  }
}

/// Timecode configuration
class TimecodeConfig {
  /// Enable timecode display
  final bool visible;

  const TimecodeConfig({
    this.visible = false,
  });

  Map<String, dynamic> toJson() {
    return {'visible': visible};
  }
}
