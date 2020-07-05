import 'package:dcache/dcache.dart';
import 'package:onef/models/category.dart';
import 'package:onef/models/color_range.dart';
import 'package:onef/models/mood.dart';
import 'package:onef/models/updatable_model.dart';
import 'package:onef/models/user.dart';

class Story extends UpdatableModel<Story> {
  final int id;

  String title;
  String description;
  String note;
  String avatar;
  bool isFavorite;

  Category category;
  Mood mood;
  ColorRange color;
  User owner;
  String uuid;
  DateTime created;
  DateTime modified;

  static final factory = StoryFactory();

  factory Story.fromJson(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'created': created?.toString(),
      'modified': modified?.toString(),
      'owner': owner?.toJson(),
      'uuid': uuid,
      'title': title,
      'description': description,
      'note': note,
      'avatar': avatar,
      'isFavorite': isFavorite,
      'category': category?.toJson(),
      'mood': mood?.toJson(),
      'color': color?.toJson()
    };
  }

  Story(
      {this.id,
        this.title,
        this.description,
        this.note,
        this.category,
        this.mood,
        this.color,
        this.owner,
        this.uuid,
        this.created,
        this.modified});

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('title')) {
      title = json['title'];
    }

    if (json.containsKey('description')) {
      description = json['description'];
    }

    if (json.containsKey('note')) {
      note = json['note'];
    }

    if (json.containsKey('avatar')) {
      avatar = json['avatar'];
    }

    if (json.containsKey('is_favorite')) isFavorite = json['is_favorite'];

    if (json.containsKey('category')) {
      category = factory.parseCategory(json['category']);
    }

    if (json.containsKey('mood')) {
      mood = factory.parseMood(json['mood']);
    }

    if (json.containsKey('owner')) {
      color = factory.parseColor(json['color']);
    }

    if (json.containsKey('uuid')) {
      uuid = json['uuid'];
    }

    if (json.containsKey('owner')) {
      owner = factory.parseUser(json['owner']);
    }

    if (json.containsKey('created')) {
      created = factory.parseCreated(json['created']);
    }

    if (json.containsKey('created')) {
      modified = factory.parseCreated(json['modified']);
    }
  }

  bool hasTitle() {
    return title != null && title.length > 0;
  }
}

class StoryFactory extends UpdatableModelFactory<Story> {
  @override
  SimpleCache<int, Story> cache =
  SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  Story makeFromJson(Map json) {
    return Story(
        id: json['id'],
        title: json['title'],
        description: json['description'],
        note: json['note'],
        category: parseCategory(json['category']),
        mood: parseMood(json['mood']),
        color: parseColor(json['color']),
        created: parseCreated(json['created']),
        modified: parseCreated(json['modified']),
        owner: parseUser(json['creator']),
        uuid: json['uuid']);
  }

  Category parseCategory(Map categoryData) {
    if (categoryData == null) return null;
    return Category.fromJson(categoryData);
  }

  Mood parseMood(Map moodData) {
    if (moodData == null) return null;
    return Mood.fromJson(moodData);
  }

  ColorRange parseColor(Map colorData) {
    if (colorData == null) return null;
    return ColorRange.fromJson(colorData);
  }

  User parseUser(Map userData) {
    if (userData == null) return null;
    return User.fromJson(userData);
  }

  DateTime parseCreated(String created) {
    if (created == null) return null;
    return DateTime.parse(created).toLocal();
  }


}
