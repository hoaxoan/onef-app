import 'package:dcache/dcache.dart';
import 'package:onef/models/updatable_model.dart';

class StoryCategory extends UpdatableModel<StoryCategory> {
  final int id;
  String name;
  String color;
  String code;
  int order;

  StoryCategory({
    this.id,
    this.name,
    this.color,
    this.code,
    this.order
  });

  static final factory = StoryCategoryFactory();

  factory StoryCategory.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return factory.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'code': code,
      'order': order
    };
  }

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('name')) {
      name = json['name'];
    }

    if (json.containsKey('color')) {
      color = json['color'];
    }

    if (json.containsKey('code')) {
      code = json['code'];
    }

    if (json.containsKey('order')) {
      order = json['order'];
    }
  }
}

class StoryCategoryFactory extends UpdatableModelFactory<StoryCategory> {
  @override
  SimpleCache<int, StoryCategory> cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  StoryCategory makeFromJson(Map json) {
    return StoryCategory(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      code: json['code'],
      order: json['order'],
    );
  }
}
