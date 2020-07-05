import 'package:dcache/dcache.dart';
import 'package:onef/models/updatable_model.dart';

class Category extends UpdatableModel<Category> {
  final int id;
  String name;
  String color;
  String code;
  int order;

  Category({
    this.id,
    this.name,
    this.color,
    this.code,
    this.order
  });

  static final factory = CategoryFactory();

  factory Category.fromJson(Map<String, dynamic> json) {
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

class CategoryFactory extends UpdatableModelFactory<Category> {
  @override
  SimpleCache<int, Category> cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  Category makeFromJson(Map json) {
    return Category(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      code: json['code'],
      order: json['order'],
    );
  }
}
