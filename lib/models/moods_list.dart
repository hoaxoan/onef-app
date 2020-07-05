import 'package:onef/models/mood.dart';

class MoodsList {
  final List<Mood> moods;

  MoodsList({
    this.moods,
  });

  factory MoodsList.fromJson(List<dynamic> parsedJson) {
    List<Mood> moods = parsedJson
        .map((moodJson) => Mood.fromJson(moodJson))
        .toList();

    return new MoodsList(
      moods: moods,
    );
  }
}
