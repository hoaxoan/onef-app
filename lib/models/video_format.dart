class OFVideoFormat {
  final int id;
  final double progress;
  final double duration;
  final String format;
  final String file;

  OFVideoFormatType type;

  OFVideoFormat(
      {this.id, this.progress, this.duration, this.format, this.file}) {
    type = OFVideoFormatType.parse(format);
  }

  factory OFVideoFormat.fromJSON(Map<String, dynamic> json) {
    return OFVideoFormat(
      id: json['int'],
      progress: json['progress']?.toDouble(),
      duration: json['duration']?.toDouble(),
      format: json['format'],
      file: json['file'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'progress': progress,
      'duration': duration,
      'format': format,
      'file': file
    };
  }
}

class OFVideoFormatType {
  final String code;

  const OFVideoFormatType._internal(this.code);

  toString() => code;

  static const mp4SD = const OFVideoFormatType._internal('mp4_sd');
  static const webmSD = const OFVideoFormatType._internal('webm_sd');

  static const _values = const <OFVideoFormatType>[
    mp4SD,
    webmSD,
  ];

  static values() => _values;

  static OFVideoFormatType parse(String string) {
    if (string == null) return null;

    OFVideoFormatType videoFormatType;
    for (var type in _values) {
      if (string == type.code) {
        videoFormatType = type;
        break;
      }
    }

    if (videoFormatType == null) {
      // Don't throw as we might introduce new medias on the API which might not be yet in code
      print('Unsupported video format type');
    }

    return videoFormatType;
  }
}
