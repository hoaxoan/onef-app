import 'package:onef/models/badge.dart';
import 'package:onef/models/badges_list.dart';

class UserProfile {
  final int id;
  String name;
  String avatar;
  String cover;
  String bio;
  String url;
  String location;
  List<Badge> badges;

  UserProfile({
    this.id,
    this.name,
    this.avatar,
    this.cover,
    this.bio,
    this.url,
    this.location,
    this.badges
  });

  factory UserProfile.fromJSON(Map<String, dynamic> parsedJson) {
    return UserProfile(
      id: parsedJson['id'],
      name: parsedJson['name'],
      avatar: parsedJson['avatar'],
      cover: parsedJson['cover'],
      bio: parsedJson['bio'],
      url: parsedJson['url'],
      location: parsedJson['location'],
      badges: parseBadges(parsedJson['badges']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'avatar': avatar,
      'cover': cover,
      'bio': bio,
      'url': url,
      'location': location,
      'badges': badges?.map((Badge badge) => badge.toJson())?.toList(),
    };
  }

  static List<Badge> parseBadges(List<dynamic> badges) {
    if (badges == null) return null;
    return BadgesList.fromJson(badges).badges;
  }

  void updateFromJson(Map<String, dynamic> json) {
    if (json.containsKey('name')) name = json['name'];
    if (json.containsKey('avatar')) avatar = json['avatar'];
    if (json.containsKey('cover')) cover = json['cover'];
    if (json.containsKey('bio')) bio = json['bio'];
    if (json.containsKey('url')) url = json['url'];
    if (json.containsKey('location')) location = json['location'];
    if (json.containsKey('badges')) badges = parseBadges(json['badges']);
  }

  bool hasLocation() {
    return location != null;
  }

  bool hasUrl() {
    return url != null;
  }
}
