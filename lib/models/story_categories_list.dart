import 'package:onef/models/story_category.dart';

class StoryCategoriesList {
  final List<StoryCategory> storyCategories;

  StoryCategoriesList({
    this.storyCategories,
  });

  factory StoryCategoriesList.fromJson(List<dynamic> parsedJson) {
    List<StoryCategory> storyCategories = parsedJson
        .map((storyCategoryJson) => StoryCategory.fromJson(storyCategoryJson))
        .toList();

    return new StoryCategoriesList(
      storyCategories: storyCategories,
    );
  }
}
