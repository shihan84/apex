import 'package:json_annotation/json_annotation.dart';

part 'content_model.g.dart';

@JsonSerializable()
class ContentModel {
  final int id;
  final String title;
  final String? description;
  final String? shortDescription;
  final String? thumbnail;
  final String? poster;
  final String? banner;
  final String? trailerUrl;
  final ContentType type;
  final ContentCategory category;
  final List<String> genres;
  final List<String> languages;
  final List<String> countries;
  final int? year;
  final int? duration; // in minutes
  final String? rating;
  final double? imdbRating;
  final int? totalViews;
  final int? totalLikes;
  final bool isFeatured;
  final bool isTrending;
  final bool isNew;
  final bool isExclusive;
  final bool isDownloadable;
  final bool isLive;
  final DateTime? releaseDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<ContentVideo> videos;
  final List<ContentAudio> audios;
  final List<ContentSubtitle> subtitles;
  final List<ContentCast> cast;
  final List<ContentCrew> crew;
  final List<ContentTag> tags;
  final Map<String, dynamic> metadata;

  const ContentModel({
    required this.id,
    required this.title,
    this.description,
    this.shortDescription,
    this.thumbnail,
    this.poster,
    this.banner,
    this.trailerUrl,
    required this.type,
    required this.category,
    required this.genres,
    required this.languages,
    required this.countries,
    this.year,
    this.duration,
    this.rating,
    this.imdbRating,
    this.totalViews,
    this.totalLikes,
    required this.isFeatured,
    required this.isTrending,
    required this.isNew,
    required this.isExclusive,
    required this.isDownloadable,
    required this.isLive,
    this.releaseDate,
    required this.createdAt,
    required this.updatedAt,
    required this.videos,
    required this.audios,
    required this.subtitles,
    required this.cast,
    required this.crew,
    required this.tags,
    required this.metadata,
  });

  factory ContentModel.fromJson(Map<String, dynamic> json) => _$ContentModelFromJson(json);
  Map<String, dynamic> toJson() => _$ContentModelToJson(this);

  String get displayTitle => title;
  String get displayDescription => description ?? shortDescription ?? '';
  String get displayThumbnail => thumbnail ?? poster ?? '';
  String get displayPoster => poster ?? thumbnail ?? '';
  String get displayBanner => banner ?? poster ?? thumbnail ?? '';
  
  bool get hasTrailer => trailerUrl != null && trailerUrl!.isNotEmpty;
  bool get hasVideos => videos.isNotEmpty;
  bool get hasAudios => audios.isNotEmpty;
  bool get hasSubtitles => subtitles.isNotEmpty;
  
  String get durationFormatted {
    if (duration == null) return '';
    final hours = duration! ~/ 60;
    final minutes = duration! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }
}

@JsonSerializable()
class ContentVideo {
  final int id;
  final String url;
  final VideoQuality quality;
  final VideoFormat format;
  final String? title;
  final String? description;
  final int? duration; // in seconds
  final int? fileSize; // in bytes
  final bool isHls;
  final bool isDash;
  final bool isEmbedded;
  final String? embedCode;
  final Map<String, String> headers;
  final Map<String, dynamic> metadata;

  const ContentVideo({
    required this.id,
    required this.url,
    required this.quality,
    required this.format,
    this.title,
    this.description,
    this.duration,
    this.fileSize,
    required this.isHls,
    required this.isDash,
    required this.isEmbedded,
    this.embedCode,
    required this.headers,
    required this.metadata,
  });

  factory ContentVideo.fromJson(Map<String, dynamic> json) => _$ContentVideoFromJson(json);
  Map<String, dynamic> toJson() => _$ContentVideoToJson(this);

  String get qualityLabel {
    switch (quality) {
      case VideoQuality.auto:
        return 'Auto';
      case VideoQuality.low:
        return '480p';
      case VideoQuality.medium:
        return '720p';
      case VideoQuality.high:
        return '1080p';
      case VideoQuality.ultra:
        return '4K';
    }
  }

  String get formatLabel {
    switch (format) {
      case VideoFormat.mp4:
        return 'MP4';
      case VideoFormat.hls:
        return 'HLS';
      case VideoFormat.dash:
        return 'DASH';
      case VideoFormat.webm:
        return 'WebM';
      case VideoFormat.mkv:
        return 'MKV';
    }
  }
}

@JsonSerializable()
class ContentAudio {
  final int id;
  final String url;
  final String language;
  final AudioQuality quality;
  final AudioFormat format;
  final String? title;
  final String? description;
  final int? duration; // in seconds
  final int? fileSize; // in bytes
  final bool isDefault;
  final Map<String, dynamic> metadata;

  const ContentAudio({
    required this.id,
    required this.url,
    required this.language,
    required this.quality,
    required this.format,
    this.title,
    this.description,
    this.duration,
    this.fileSize,
    required this.isDefault,
    required this.metadata,
  });

  factory ContentAudio.fromJson(Map<String, dynamic> json) => _$ContentAudioFromJson(json);
  Map<String, dynamic> toJson() => _$ContentAudioToJson(this);
}

@JsonSerializable()
class ContentSubtitle {
  final int id;
  final String url;
  final String language;
  final String? title;
  final String? description;
  final bool isDefault;
  final Map<String, dynamic> metadata;

  const ContentSubtitle({
    required this.id,
    required this.url,
    required this.language,
    this.title,
    this.description,
    required this.isDefault,
    required this.metadata,
  });

  factory ContentSubtitle.fromJson(Map<String, dynamic> json) => _$ContentSubtitleFromJson(json);
  Map<String, dynamic> toJson() => _$ContentSubtitleToJson(this);
}

@JsonSerializable()
class ContentCast {
  final int id;
  final String name;
  final String? character;
  final String? profileImage;
  final int? order;
  final Map<String, dynamic> metadata;

  const ContentCast({
    required this.id,
    required this.name,
    this.character,
    this.profileImage,
    this.order,
    required this.metadata,
  });

  factory ContentCast.fromJson(Map<String, dynamic> json) => _$ContentCastFromJson(json);
  Map<String, dynamic> toJson() => _$ContentCastToJson(this);
}

@JsonSerializable()
class ContentCrew {
  final int id;
  final String name;
  final String role;
  final String? profileImage;
  final Map<String, dynamic> metadata;

  const ContentCrew({
    required this.id,
    required this.name,
    required this.role,
    this.profileImage,
    required this.metadata,
  });

  factory ContentCrew.fromJson(Map<String, dynamic> json) => _$ContentCrewFromJson(json);
  Map<String, dynamic> toJson() => _$ContentCrewToJson(this);
}

@JsonSerializable()
class ContentTag {
  final int id;
  final String name;
  final String? color;
  final Map<String, dynamic> metadata;

  const ContentTag({
    required this.id,
    required this.name,
    this.color,
    required this.metadata,
  });

  factory ContentTag.fromJson(Map<String, dynamic> json) => _$ContentTagFromJson(json);
  Map<String, dynamic> toJson() => _$ContentTagToJson(this);
}

// Enums
enum ContentType {
  @JsonValue('movie')
  movie,
  @JsonValue('series')
  series,
  @JsonValue('episode')
  episode,
  @JsonValue('live_tv')
  liveTv,
  @JsonValue('music')
  music,
  @JsonValue('short')
  short,
  @JsonValue('documentary')
  documentary,
  @JsonValue('trailer')
  trailer,
}

enum ContentCategory {
  @JsonValue('entertainment')
  entertainment,
  @JsonValue('news')
  news,
  @JsonValue('sports')
  sports,
  @JsonValue('kids')
  kids,
  @JsonValue('music')
  music,
  @JsonValue('education')
  education,
  @JsonValue('lifestyle')
  lifestyle,
  @JsonValue('comedy')
  comedy,
  @JsonValue('drama')
  drama,
  @JsonValue('action')
  action,
}

enum VideoQuality {
  @JsonValue('auto')
  auto,
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('ultra')
  ultra,
}

enum VideoFormat {
  @JsonValue('mp4')
  mp4,
  @JsonValue('hls')
  hls,
  @JsonValue('dash')
  dash,
  @JsonValue('webm')
  webm,
  @JsonValue('mkv')
  mkv,
}

enum AudioQuality {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('ultra')
  ultra,
}

enum AudioFormat {
  @JsonValue('mp3')
  mp3,
  @JsonValue('aac')
  aac,
  @JsonValue('wav')
  wav,
  @JsonValue('flac')
  flac,
  @JsonValue('m4a')
  m4a,
}
