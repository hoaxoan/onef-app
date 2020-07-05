import 'package:dcache/dcache.dart';
import 'package:onef/models/updatable_model.dart';

class Mood extends UpdatableModel<Mood> {
  final int id;
  String name;
  String color;
  String code;
  int order;

  Mood({
    this.id,
    this.name,
    this.color,
    this.code,
    this.order
  });

  static final factory = MoodFactory();

  factory Mood.fromJson(Map<String, dynamic> json) {
    if (json == null) return null;
    return factory.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'code': code,
      'title': order
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

class MoodFactory extends UpdatableModelFactory<Mood> {
  @override
  SimpleCache<int, Mood> cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  Mood makeFromJson(Map json) {
    return Mood(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      code: json['code'],
      order: json['order']
    );
  }
}
