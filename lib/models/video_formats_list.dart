import 'package:onef/models/video_format.dart';

class OFVideoFormatsList {
  final List<OFVideoFormat> videoFormats;

  OFVideoFormatsList({
    this.videoFormats,
  });

  factory OFVideoFormatsList.fromJson(List<dynamic> parsedJson) {
    List<OFVideoFormat> videoFormats = parsedJson
        .map((videoFormatJson) => OFVideoFormat.fromJSON(videoFormatJson))
        .toList();

    return new OFVideoFormatsList(
      videoFormats: videoFormats,
    );
  }
}
