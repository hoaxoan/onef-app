import 'package:dcache/dcache.dart';
import 'package:onef/models/updatable_model.dart';

class Hashtag extends UpdatableModel<Hashtag> {
  final int id;
  String name;
  String image;
  String color;
  String textColor;
  int postsCount;
  bool isReported;

  Hashtag({
    this.id,
    this.name,
    this.image,
    this.color,
    this.textColor,
    this.postsCount,
    this.isReported,
  });

  static final factory = HashtagFactory();

  factory Hashtag.fromJSON(Map<String, dynamic> json) {
    if (json == null) return null;
    return factory.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'color': color,
      'text_color': textColor,
      'posts_count': postsCount,
      'is_reported': isReported,
    };
  }

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('name')) {
      name = json['name'];
    }

    if (json.containsKey('is_reported')) {
      isReported = json['is_reported'];
    }

    if (json.containsKey('posts_count')) {
      postsCount = json['posts_count'];
    }
    if (json.containsKey('color')) {
      color = json['color'];
    }

    if (json.containsKey('text_color')) {
      textColor = json['text_color'];
    }

    if (json.containsKey('image')) {
      image = json['image'];
    }
  }

  bool hasImage() {
    return this.image != null;
  }

  void setIsReported(isReported) {
    this.isReported = isReported;
    notifyUpdate();
  }
}

class HashtagFactory extends UpdatableModelFactory<Hashtag> {
  @override
  SimpleCache<int, Hashtag> cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  Hashtag makeFromJson(Map json) {
    return Hashtag(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      isReported: json['is_reported'],
      textColor: json['text_color'],
      postsCount: json['posts_count'],
    );
  }
}
