/// Event data classes for OvenPlayer events
library;

/// Player state enumeration
enum OvenPlayerState {
  idle,
  loading,
  playing,
  paused,
  error,
  complete,
}

/// Error event data
class OvenPlayerError {
  final int code;
  final String message;

  OvenPlayerError({required this.code, required this.message});

  factory OvenPlayerError.fromJson(Map<String, dynamic> json) {
    return OvenPlayerError(
      code: json['code'] as int? ?? 0,
      message: json['message'] as String? ?? '',
    );
  }
}

/// Metadata event data
class OvenPlayerMetadata {
  final int? duration;
  final int? width;
  final int? height;
  final String? mediaType;

  OvenPlayerMetadata({
    this.duration,
    this.width,
    this.height,
    this.mediaType,
  });

  factory OvenPlayerMetadata.fromJson(Map<String, dynamic> json) {
    return OvenPlayerMetadata(
      duration: json['duration'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      mediaType: json['mediaType'] as String?,
    );
  }
}

/// Time event data
class OvenPlayerTimeData {
  final double position;
  final double duration;

  OvenPlayerTimeData({required this.position, required this.duration});

  factory OvenPlayerTimeData.fromJson(Map<String, dynamic> json) {
    return OvenPlayerTimeData(
      position: (json['position'] as num?)?.toDouble() ?? 0.0,
      duration: (json['duration'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Buffer event data
class OvenPlayerBufferData {
  final double buffer;

  OvenPlayerBufferData({required this.buffer});

  factory OvenPlayerBufferData.fromJson(Map<String, dynamic> json) {
    return OvenPlayerBufferData(
      buffer: (json['buffer'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

/// Volume event data
class OvenPlayerVolumeData {
  final int volume;

  OvenPlayerVolumeData({required this.volume});

  factory OvenPlayerVolumeData.fromJson(Map<String, dynamic> json) {
    return OvenPlayerVolumeData(
      volume: json['volume'] as int? ?? 0,
    );
  }
}

/// Source change event data
class OvenPlayerSourceData {
  final int currentSource;

  OvenPlayerSourceData({required this.currentSource});

  factory OvenPlayerSourceData.fromJson(Map<String, dynamic> json) {
    return OvenPlayerSourceData(
      currentSource: json['currentSource'] as int? ?? 0,
    );
  }
}

/// Quality level data
class OvenPlayerQualityLevel {
  final int? bitrate;
  final int? width;
  final int? height;
  final String? label;
  final int index;

  OvenPlayerQualityLevel({
    this.bitrate,
    this.width,
    this.height,
    this.label,
    required this.index,
  });

  factory OvenPlayerQualityLevel.fromJson(Map<String, dynamic> json) {
    return OvenPlayerQualityLevel(
      bitrate: json['bitrate'] as int?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      label: json['label'] as String?,
      index: json['index'] as int? ?? 0,
    );
  }
}

/// Quality level change event data
class OvenPlayerQualityData {
  final int currentQuality;
  final bool isAuto;

  OvenPlayerQualityData({required this.currentQuality, this.isAuto = false});

  factory OvenPlayerQualityData.fromJson(Map<String, dynamic> json) {
    return OvenPlayerQualityData(
      currentQuality: json['currentQuality'] as int? ?? 0,
      isAuto: json['isAuto'] as bool? ?? false,
    );
  }
}
