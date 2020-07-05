class StoryImage {
  final String image;
  final double width;
  final double height;
  final String thumbnail;

  StoryImage({
    this.image,
    this.width,
    this.height,
    this.thumbnail,
  });

  factory StoryImage.fromJSON(Map<String, dynamic> parsedJson) {
    if (parsedJson == null) return null;
    return StoryImage(
        image: parsedJson['image'],
        thumbnail: parsedJson['thumbnail'],
        width: parsedJson['width']?.toDouble(),
        height: parsedJson['height']?.toDouble());
  }

  Map<String, dynamic> toJson() {
    return {
      'image': image,
      'width': width,
      'height': height,
      'thumbnail': thumbnail
    };
  }
}
