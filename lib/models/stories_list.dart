import 'package:onef/models/story.dart';

class StoriesList {
  final List<Story> stories;

  StoriesList({
    this.stories,
  });

  factory StoriesList.fromJson(List<dynamic> parsedJson) {
    List<Story> stories =
        parsedJson.map((storyJson) => Story.fromJson(storyJson)).toList();

    return new StoriesList(
      stories: stories,
    );
  }
}
