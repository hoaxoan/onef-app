import 'package:dcache/dcache.dart';
import 'package:onef/models/updatable_model.dart';
import 'package:onef/models/user.dart';
import 'package:onef/models/users_list.dart';

class Device extends UpdatableModel<Device> {
  final int id;

  User owner;
  String uuid;
  String name;
  DateTime created;

  static final factory = DeviceFactory();

  factory Device.fromJSON(Map<String, dynamic> json) {
    return factory.fromJson(json);
  }

  Device({this.id, this.owner, this.name, this.uuid, this.created});

  @override
  void updateFromJson(Map json) {
    if (json.containsKey('name')) {
      name = json['name'];
    }

    if (json.containsKey('uuid')) {
      uuid = json['uuid'];
    }

    if (json.containsKey('created')) {
      created = json['created'];
    }

    if (json.containsKey('owner')) {
      owner = factory.parseUser(json['owner']);
    }

    if (json.containsKey('created')) {
      created = factory.parseCreated(json['created']);
    }
  }
}

class DeviceFactory extends UpdatableModelFactory<Device> {
  @override
  SimpleCache<int, Device> cache =
      SimpleCache(storage: UpdatableModelSimpleStorage(size: 20));

  @override
  Device makeFromJson(Map json) {
    return Device(
        id: json['id'],
        name: json['name'],
        created: parseCreated(json['created']),
        owner: parseUser(json['creator']),
        uuid: json['uuid']);
  }

  User parseUser(Map userData) {
    if (userData == null) return null;
    return User.fromJson(userData);
  }

  UsersList parseUsers(List usersData) {
    if (usersData == null) return null;
    return UsersList.fromJson(usersData);
  }

  DateTime parseCreated(String created) {
    if (created == null) return null;
    return DateTime.parse(created).toLocal();
  }
}
