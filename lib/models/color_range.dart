import 'package:dcache/dcache.dart';
import 'package:onef/models/updatable_model.dart';

class ColorRange extends UpdatableModel<ColorRange> {
  final int id;

  String name;
  int color;
  int start;
  int end;

  static final factory = ColorRangeFactory();

  factory ColorRange.fromJson(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'color': color, 'start': start, 'end': end};
  }

  ColorRange({this.id, this.name, this.color, this.start, this.end});

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('name')) {
      name = json['name'];
    }

    if (json.containsKey('color')) {
      color = json['color'];
    }

    if (json.containsKey('start')) {
      start = json['start'];
    }

    if (json.containsKey('end')) {
      end = json['end'];
    }
  }
}

class ColorRangeFactory extends UpdatableModelFactory<ColorRange> {
  @override
  SimpleCache<int, ColorRange> cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  ColorRange makeFromJson(Map json) {
    return ColorRange(
        id: json['id'],
        name: json['name'],
        color: json['color'],
        start: json['start'],
        end: json['end']);
  }
}
