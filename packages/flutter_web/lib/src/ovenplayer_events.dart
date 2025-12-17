/// Event data types for OvenPlayer events

/// Player state
enum PlayerState {
  idle,
  loading,
  playing,
  paused,
  complete,
  error,
}

/// Event emitted when player state changes
class StateChangedEvent {
  final String prevState;
  final String newState;

  const StateChangedEvent({
    required this.prevState,
    required this.newState,
  });

  factory StateChangedEvent.fromJson(Map<String, dynamic> json) {
    return StateChangedEvent(
      prevState: json['prevstate'] ?? '',
      newState: json['newstate'] ?? '',
    );
  }
}

/// Event emitted when metadata changes
class MetaChangedEvent {
  final int? duration;
  final String? type;
  final dynamic data;

  const MetaChangedEvent({
    this.duration,
    this.type,
    this.data,
  });

  factory MetaChangedEvent.fromJson(Map<String, dynamic> json) {
    return MetaChangedEvent(
      duration: json['duration'],
      type: json['type'],
      data: json,
    );
  }
}

/// Event emitted during playback with time information
class TimeEvent {
  final double position;
  final double duration;

  const TimeEvent({
    required this.position,
    required this.duration,
  });

  factory TimeEvent.fromJson(Map<String, dynamic> json) {
    return TimeEvent(
      position: (json['position'] ?? 0).toDouble(),
      duration: (json['duration'] ?? 0).toDouble(),
    );
  }
}

/// Event emitted when buffer changes
class BufferChangedEvent {
  final double buffer;

  const BufferChangedEvent({
    required this.buffer,
  });

  factory BufferChangedEvent.fromJson(Map<String, dynamic> json) {
    return BufferChangedEvent(
      buffer: (json['buffer'] ?? 0).toDouble(),
    );
  }
}

/// Event emitted when volume changes
class VolumeChangedEvent {
  final int volume;

  const VolumeChangedEvent({
    required this.volume,
  });

  factory VolumeChangedEvent.fromJson(Map<String, dynamic> json) {
    return VolumeChangedEvent(
      volume: json['volume'] ?? 0,
    );
  }
}

/// Event emitted when mute state changes
class MuteEvent {
  final bool mute;

  const MuteEvent({
    required this.mute,
  });

  factory MuteEvent.fromJson(Map<String, dynamic> json) {
    return MuteEvent(
      mute: json['mute'] ?? false,
    );
  }
}

/// Event emitted when quality level changes
class QualityLevelChangedEvent {
  final int currentQuality;
  final String? type;
  final bool? isAuto;

  const QualityLevelChangedEvent({
    required this.currentQuality,
    this.type,
    this.isAuto,
  });

  factory QualityLevelChangedEvent.fromJson(Map<String, dynamic> json) {
    return QualityLevelChangedEvent(
      currentQuality: json['currentQuality'] ?? 0,
      type: json['type'],
      isAuto: json['isAuto'],
    );
  }
}

/// Event emitted when source changes
class SourceChangedEvent {
  final int currentSource;

  const SourceChangedEvent({
    required this.currentSource,
  });

  factory SourceChangedEvent.fromJson(Map<String, dynamic> json) {
    return SourceChangedEvent(
      currentSource: json['currentSource'] ?? 0,
    );
  }
}

/// Event emitted when playlist changes
class PlaylistChangedEvent {
  final int currentPlaylist;

  const PlaylistChangedEvent({
    required this.currentPlaylist,
  });

  factory PlaylistChangedEvent.fromJson(Map<String, dynamic> json) {
    return PlaylistChangedEvent(
      currentPlaylist: json['currentPlaylist'] ?? 0,
    );
  }
}

/// Event emitted when fullscreen state changes
class FullscreenChangedEvent {
  final bool fullscreen;

  const FullscreenChangedEvent({
    required this.fullscreen,
  });

  factory FullscreenChangedEvent.fromJson(Map<String, dynamic> json) {
    return FullscreenChangedEvent(
      fullscreen: json['fullscreen'] ?? false,
    );
  }
}

/// Event emitted on player errors
class ErrorEvent {
  final String? code;
  final String? message;
  final dynamic error;

  const ErrorEvent({
    this.code,
    this.message,
    this.error,
  });

  factory ErrorEvent.fromJson(Map<String, dynamic> json) {
    return ErrorEvent(
      code: json['code'],
      message: json['message'],
      error: json['error'],
    );
  }

  @override
  String toString() {
    return 'ErrorEvent{code: $code, message: $message, error: $error}';
  }
}

/// Event emitted when seek action occurs
class SeekEvent {
  final double position;

  const SeekEvent({
    required this.position,
  });

  factory SeekEvent.fromJson(Map<String, dynamic> json) {
    return SeekEvent(
      position: (json['position'] ?? 0).toDouble(),
    );
  }
}

/// Event emitted when player is resized
class ResizedEvent {
  final int width;
  final int height;

  const ResizedEvent({
    required this.width,
    required this.height,
  });

  factory ResizedEvent.fromJson(Map<String, dynamic> json) {
    return ResizedEvent(
      width: json['width'] ?? 0,
      height: json['height'] ?? 0,
    );
  }
}

/// Event emitted when playback rate changes
class PlaybackRateChangedEvent {
  final double playbackRate;

  const PlaybackRateChangedEvent({
    required this.playbackRate,
  });

  factory PlaybackRateChangedEvent.fromJson(Map<String, dynamic> json) {
    return PlaybackRateChangedEvent(
      playbackRate: (json['playbackRate'] ?? 1.0).toDouble(),
    );
  }
}

/// Event emitted when content metadata is received (e.g., SEI data)
class ContentMetaDataEvent {
  final String type;
  final dynamic data;

  const ContentMetaDataEvent({
    required this.type,
    required this.data,
  });

  factory ContentMetaDataEvent.fromJson(Map<String, dynamic> json) {
    return ContentMetaDataEvent(
      type: json['type'] ?? '',
      data: json,
    );
  }
}
